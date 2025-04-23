import 'dart:async';
import 'dart:convert';

import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/chat_message.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/chat_usecases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:universal_html/html.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/extension/merge_videos.dart';
import '../../../core/io/network/models/data_channel_command.dart';
import '../../../core/janus/janus_client.dart';
import '../../../core/util/conf.dart';

import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';

import '../source/local/local_storage.dart';

import 'package:webrtc_interface/webrtc_interface.dart' as webrtcInterface;
import 'package:flutter_webrtc/flutter_webrtc.dart' as flutterWebRTC;
// import 'dart:html' as html; // For Web
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// import 'dart:js' as js;

class ConferenceRepoImpl extends ConferenceRepo {
  ConferenceRepoImpl({
    required Api api,
  }) : _api = api;

  final Api _api;

  JanusClient? client;
  WebSocketJanusTransport? ws;
  JanusSession? session;

  late StreamRenderer localVideoRenderer;
  late StreamRenderer localScreenSharingRenderer;

  int? myPvtId;

  bool joined = true;
  bool screenSharing = false;
  bool front = true;
  dynamic fullScreenDialog;

  JanusVideoRoomPlugin? videoPlugin;
  JanusVideoRoomPlugin? remotePlugin;
  JanusVideoRoomPlugin? screenPlugin;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  int room = 12344321;
  late JanusVideoRoom? roomDetails;

  final _conferenceStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();
  final _conferenceEndedStream = StreamController<String>.broadcast();
  final _conferenceChatStream = StreamController<List<ChatMessage>>.broadcast();
  final _participantsStream = StreamController<List<Participant>>.broadcast();
  final _avgEngagementStream = StreamController<int>.broadcast();
  final _talkingIdStream = StreamController<int>.broadcast();

  User? user = getIt.get<LocalStorage>().loadLoggedUser();

  late String myId = user?.id ?? "";
  late String displayName = user?.name ?? 'User $myId';

  get screenShareId => int.parse(myId) * 774352;

  int? callId;

  List<ChatMessage> messages = [];

  @override
  Future<void> initialize(
      {required int roomId, required String displayName}) async {
    room = roomId;
    this.displayName = user!.name;

    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);
    session = await client?.createSession();
    _initLocalMediaRenderer();

    await _configureConnection();
    await _joinRoom();
  }

  @override
  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream() {
    return _conferenceStream.stream;
  }

  @override
  Stream<List<Participant>> getSubscribersStream() {
    return _participantsStream.stream;
  }

  @override
  Stream<String> getConferenceEndedStream() {
    return _conferenceEndedStream.stream;
  }

  @override
  Stream<int> getAvgEngagementStream() {
    return _avgEngagementStream.stream;
  }

  @override
  Stream<List<ChatMessage>> getConferenceMessagesStream() {
    return _conferenceChatStream.stream;
  }

  _initLocalMediaRenderer() {
    print('initLocalMediaRenderer');
    localScreenSharingRenderer =
        StreamRenderer('localScreenShare', 'local_screenshare');
    localVideoRenderer = StreamRenderer('local', 'local');
  }

  _configureConnection() async {
    videoPlugin = await _attachPlugin(pop: true);
    _eventMessagesHandler();
    await _configureLocalVideoRenderer();
  }

  _attachPlugin({bool pop = false}) async {
    JanusVideoRoomPlugin? videoPlugin =
        await session?.attach<JanusVideoRoomPlugin>();

    videoPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        await videoPlugin.initDataChannel();

        myPvtId = data.privateId;
        if (pop) {
          // Navigator.of(context).pop(joiningDialog);
        }
        {
          _canBePublished().then((value) async {
            if (value) {
              await _publishMyOwn();
              _getEngagement();
            }
          });
        }
      }
      if (data is VideoRoomLeavingEvent) {
        print('unscubscribing');
        _unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        _unSubscribeTo(data.unpublished);
      }
      videoPlugin.handleRemoteJsep(event.jsep);
    });

    return videoPlugin;
  }

  _attachSubscriberOnPublisherChange(List<dynamic>? publishers) async {
    if (publishers == null) {
      return;
    }

    print('PUBLISHER CHANGE: publishers: ${publishers}');

    List<List<Map>> sources = [];
    for (Map publisher in publishers) {
      if ([myId, screenShareId.toString()].contains(publisher['id'])) {
        print('PUBLISHER CHANGE: publishers: its me');
        continue;
      }
      videoState.feedIdToDisplayStreamsMap[publisher['id']] = {
        'id': publisher['id'],
        'display': publisher['display'],
        'streams': publisher['streams']
      };
      List<Map> mappedStreams = [];
      for (Map stream in publisher['streams'] ?? []) {
        // if (stream['disabled'] == true) {
        //   _manageMuteUIEvents(stream['mid'], stream['type'], true);
        // } else {
        //   _manageMuteUIEvents(stream['mid'], stream['type'], false);
        // }
        if (videoState.feedIdToMidSubscriptionMap[publisher['id']] != null &&
            videoState.feedIdToMidSubscriptionMap[publisher['id']]
                    ?[stream['mid']] ==
                true) {
          print('PUBLISHER CHANGE: publishers streams : ${publisher['id']}');
          continue;
        }
        stream['id'] = publisher['id'];
        stream['display'] = publisher['display'];

        mappedStreams.add(stream);
      }
      sources.add(mappedStreams);
    }

    print('subscribing_test: $sources');
    await _subscribeTo(sources);
  }

  _eventMessagesHandler() async {
    videoPlugin?.messages?.listen((payload) async {
      print('eventMessagesHandlerTest: $payload');

      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await _attachSubscriberOnPublisherChange(publishers);

      var kicked = event.plugindata?.data['kicked'];
      if (kicked != null) {
        _unSubscribeTo(kicked);
      }

      var unpublished = event.plugindata?.data['unpublished'];
      if (unpublished != null) {
        if (unpublished == 'ok') {
          _cleanupWebRTC();
        }
      }

      var leaving = event.plugindata?.data['leaving'];
      if (leaving == 'ok') {
        _closeCall(event.plugindata?.data['reason']);
      }

      var pluginData = event.plugindata;
      if (pluginData != null) {
        var data = pluginData.data;
        if (data != null) {
          var dataMap = data as Map<String, dynamic>;
          if (dataMap.containsKey('display')) {
            var id = dataMap['id'];
            StreamRenderer? renderer =
                videoState.streamsToBeRendered[id.toString()];
            renderer?.publisherName = dataMap['display'];
            _refreshStreams();
            return;
          }

          // {event: {janus: event, session_id: 8890060192473935, sender: 4573435648381413, plugindata: {plugin: janus.plugin.videoroom, data: {videoroom: event, room: 1234, id: 57, mid: 1, moderation: muted}}}, jsep: null}
          // {event: {janus: event, session_id: 8890060192473935, sender: 4573435648381413, plugindata: {plugin: janus.plugin.videoroom, data: {videoroom: event, room: 1234, id: 57, mid: 1, moderation: unmuted}}}, jsep: null}
          if (dataMap.containsKey('moderation')) {
            var moderation = dataMap['moderation'];
            print('moderation: $moderation');
            if (moderation == 'muted' || moderation == 'unmuted') {
              var id = '${dataMap['id']}';
              var mid = dataMap['mid'];
              var kind = mid == '0' ? 'audio' : 'video';
              var muted = moderation == 'muted';
              _manageMuteUIEvents(id, kind, muted);
            }
          }

          if (data.containsKey("videoroom")) {
            var videoroom = dataMap['videoroom'];
            if (data.containsKey("id")) {
              var id = dataMap['id'];
              if (videoroom == "talking") {
                _manageTalkingEvents(id, true);
              }
              if (videoroom == "stopped-talking") {
                _manageTalkingEvents(id, false);
              }
            }
          }
        }
      }
    });

    screenPlugin?.messages?.listen((payload) async {
      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await _attachSubscriberOnPublisherChange(publishers);
    });

    videoPlugin?.renegotiationNeeded?.listen((event) async {
      if (videoPlugin?.webRTCHandle?.peerConnection?.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) return;
      // print('retrying to connect publisher');
      var offer = await videoPlugin?.createOffer(
        audioRecv: false,
        videoRecv: false,
      );
      await videoPlugin?.configure(sessionDescription: offer);
    });
    screenPlugin?.renegotiationNeeded?.listen((event) async {
      if (screenPlugin?.webRTCHandle?.peerConnection?.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) return;
      // print('retrying to connect publisher');
      var offer =
          await screenPlugin?.createOffer(audioRecv: false, videoRecv: false);
      await screenPlugin?.configure(sessionDescription: offer);
    });

    videoPlugin?.peerConnection?.onConnectionState = (state) {
      // print('peerConnection state: ${state.name}');
    };
  }

  _manageTalkingEvents(int feedId, bool talking) async {
    var id = user?.id == feedId.toString() ? "local" : feedId.toString();
    StreamRenderer? renderer = videoState.streamsToBeRendered[id];
    if (renderer == null) {
      return;
    }
    _startRecord(renderer.mediaStream!);
    renderer.isTalking = talking;
    _refreshStreams();
  }

  _manageMuteUIEvents(String mid, String kind, bool muted) async {
    var feedId = mid;
    // int? feedId = videoState.subStreamsToFeedIdMap[mid]?['feed_id'];
    // if (feedId == null) {
    //   return;
    // }
    StreamRenderer? renderer =
        videoState.streamsToBeRendered[feedId.toString()];

    // setState(() {
    if (renderer == null) {
      return;
    }

    if (renderer.publisherName.toLowerCase().contains('screenshare')) {
      return;
    }

    if (kind == 'audio') {
      if (renderer.isAudioMuted == muted) {
        return;
      }

      renderer.isAudioMuted = muted;
    } else {
      if (renderer.isVideoMuted == muted) {
        return;
      }
      renderer.isVideoMuted = muted;
    }
    // });
    print('feedId: $feedId mid: $mid muted: $muted $kind');
    _refreshStreams();
  }

  _configureLocalVideoRenderer() async {
    await localVideoRenderer.init();
    // localVideoRenderer.mediaStream = await videoPlugin?.initializeMediaDevices(
    //     simulcastSendEncodings: getSimulcastSendEncodings(),
    //     mediaConstraints: {
    //       'video': {'width': 640, 'height': 360},
    //       'audio': true
    //     });

    localVideoRenderer.mediaStream =
        await videoPlugin?.initializeMediaDevices(simulcastSendEncodings: [
      RTCRtpEncoding(
        rid: "h",
        minBitrate: 256000,
        // 256 kbps
        maxBitrate: 512000,
        // 512 kbps
        active: true,
        scalabilityMode: 'L2T2',
      ),
      RTCRtpEncoding(
        rid: "m",
        minBitrate: 128000,
        // 128 kbps
        maxBitrate: 256000,
        // 256 kbps
        active: true,
        scalabilityMode: 'L2T2',
        scaleResolutionDownBy: 2, // 240p
      ),
      RTCRtpEncoding(
        rid: "l",
        minBitrate: 64000,
        // 64 kbps
        maxBitrate: 128000,
        // 128 kbps
        active: true,
        scalabilityMode: 'L2T2',
        scaleResolutionDownBy: 4, // 180p
      ),
    ], mediaConstraints: {
      'video': {'width': 1280, 'height': 720},
      // 720p max for higher quality
      'audio': true,
    });
    localVideoRenderer.videoRenderer.srcObject = localVideoRenderer.mediaStream;
    localVideoRenderer.publisherName = displayName;
    localVideoRenderer.publisherId = myId.toString();
    localVideoRenderer.videoRenderer.onResize = () {
      // to update widthxheight when it renders
    };

    Map<dynamic, StreamRenderer> renderers = {};
    renderers.addAll(videoState.streamsToBeRendered);

    videoState.streamsToBeRendered.clear();
    videoState.streamsToBeRendered
        .putIfAbsent('local', () => localVideoRenderer);
    videoState.streamsToBeRendered.addAll(renderers);

    // _conferenceStream.add(videoState.streamsToBeRendered);
    _refreshStreams();
  }

  _subscribeTo(List<List<Map>> sources) async {
    if (sources.isEmpty) {
      return;
    }
    if (remotePlugin == null) {
      remotePlugin = await session?.attach<JanusVideoRoomPlugin>();
      remotePlugin?.messages?.listen((payload) async {
        JanusEvent event = JanusEvent.fromJson(payload.event);
        // print('object $payload');
        List<dynamic>? streams = event.plugindata?.data['streams'];
        streams?.forEach((element) {
          print('substreams: ${element['mid']} ${element['feed_id']} ');

          videoState.subStreamsToFeedIdMap[element['mid']] = element;
          // to avoid duplicate subscriptions
          if (videoState.feedIdToMidSubscriptionMap[element['feed_id']] == null)
            videoState.feedIdToMidSubscriptionMap[element['feed_id']] = {};
          videoState.feedIdToMidSubscriptionMap[element['feed_id']]
              [element['mid']] = true;
        });
        if (payload.jsep != null) {
          await remotePlugin?.initDataChannel();
          await remotePlugin?.handleRemoteJsep(payload.jsep);
          await remotePlugin?.start(room);
        }
      });

      remotePlugin?.webRTCHandle!.peerConnection!.onDataChannel = (channel) {
        print("LISTEN CHANNNEL: ${channel.label} ");
        channel.onBufferedAmountLow = (currentAmount) {
          print("onBufferedAmountLow ${currentAmount.toString()}");
        };

        channel.onBufferedAmountChange = (currentAmount, changedAmount) {
          print("onBufferedAmountChange ${currentAmount.toString()}");
        };

        channel.onMessage = (data) {
          // print("onMessage ${data.text}");

          try {
            Map<String, dynamic> result = jsonDecode(data.text);
            var command = DataChannelCommand.fromJson(result);
            _renderCommand(command);
          } on Exception catch (_) {
            print(data.text);
          }
        };

        channel.onDataChannelState = (state) {
          print("onDataChannelState ${state.name}");
        };

        channel.stateChangeStream.listen((state) {
          print("stateChangeStream ${state.name}");
        });

        channel.messageStream.listen((message) {
          // print("messageStream ${message.text}");
        });
      };

      remotePlugin?.remoteTrack?.listen((event) async {
        // print(event);
        print({
          'mid': event.mid,
          'flowing': event.flowing,
          'id': event.track?.id,
          'kind': event.track?.kind
        });

        // _manageMuteUIEvents(event.mid!, event.track!.kind!, !event.flowing!);

        int? feedId = videoState.subStreamsToFeedIdMap[event.mid]?['feed_id'];

        _manageMuteUIEvents('$feedId', event.track!.kind!, !event.flowing!);

        String? displayName =
            videoState.feedIdToDisplayStreamsMap[feedId]?['display'];
        if (feedId != null) {
          if (videoState.streamsToBeRendered.containsKey(feedId.toString()) &&
              event.flowing == true &&
              event.track?.kind == "audio") {
            var existingRenderer =
                videoState.streamsToBeRendered[feedId.toString()];
            existingRenderer?.mediaStream?.addTrack(event.track!);
            existingRenderer?.videoRenderer.srcObject =
                existingRenderer.mediaStream;
            existingRenderer?.videoRenderer.muted = false;

            // setState(() {});
            // _conferenceStream.add(videoState.streamsToBeRendered);
            _refreshStreams();
          }
          if (!videoState.streamsToBeRendered.containsKey(feedId.toString()) &&
              event.flowing == true &&
              event.track?.kind == "video") {
            var localStream = StreamRenderer(feedId.toString(), 'local');
            await localStream.init();
            localStream.mediaStream =
                await flutterWebRTC.createLocalMediaStream(feedId.toString());
            localStream.mediaStream?.addTrack(event.track!);
            localStream.videoRenderer.srcObject = localStream.mediaStream;
            localStream.videoRenderer.onResize = () => {
                  // setState(() {})
                  // _conferenceStream.add(videoState.streamsToBeRendered)
                  _refreshStreams()
                };
            localStream.publisherName = displayName!;
            localStream.publisherId = feedId.toString();
            localStream.mid = event.mid;
            // setState(() {

            localStream.mediaStream?.getAudioTracks().forEach((element) {
              element.onMute = () {
                print('onMute');
              };
            });
            videoState.streamsToBeRendered
                .putIfAbsent(feedId.toString(), () => localStream);
            // _conferenceStream.add(videoState.streamsToBeRendered);

            _refreshStreams();
            // });
          }

          // _conferenceStream.add(videoState.streamsToBeRendered);
        }
      });
      List<PublisherStream> streams = sources
          .map((e) => e.map((e) => PublisherStream(
              feed: e['id'], mid: e['mid'], simulcast: e['simulcast'])))
          .expand((element) => element)
          .toList();

      await remotePlugin?.joinSubscriber(room, streams: streams, pin: "");
      return;
    }
    List<Map>? added, removed;
    for (var streams in sources) {
      for (var stream in streams) {
        // If the publisher is VP8/VP9 and this is an older Safari, let's avoid video
        if (stream['disabled'] != null) {
          print("Disabled stream:");
          // Unsubscribe
          if (removed == null) removed = [];
          removed.add({
            'feed': stream['id'], // This is mandatory
            'mid': stream['mid'] // This is optional (all streams, if missing)
          });
          videoState.feedIdToMidSubscriptionMap[stream['id']]
              ?.remove(stream['mid']);
          videoState.feedIdToMidSubscriptionMap.remove(stream['id']);
          continue;
        }
        if (videoState.feedIdToMidSubscriptionMap[stream['id']] != null &&
            videoState.feedIdToMidSubscriptionMap[stream['id']]
                    [stream['mid']] ==
                true) {
          print("Already subscribed to stream, skipping:");
          continue;
        }

        // Subscribe
        if (added == null) added = [];

        added.add({
          'feed': stream['id'], // This is mandatory
          'mid': stream['mid'] // This is optional (all streams, if missing)
        });

        if (videoState.feedIdToMidSubscriptionMap[stream['id']] == null)
          videoState.feedIdToMidSubscriptionMap[stream['id']] = {};
        videoState.feedIdToMidSubscriptionMap[stream['id']][stream['mid']] =
            true;
      }
    }
    if ((added == null || added.length == 0) &&
        (removed == null || removed.length == 0)) {
      // Nothing to do
      return;
    }
    await remotePlugin?.update(
        subscribe: added
            ?.map((e) => SubscriberUpdateStream(
                feed: e['feed'], mid: e['mid'], crossrefid: null))
            .toList(),
        unsubscribe: removed
            ?.map((e) => SubscriberUpdateStream(
                feed: e['feed'], mid: e['mid'], crossrefid: null))
            .toList());
  }

  Future<void> _unSubscribeTo(int id) async {
    print('unsubscribed: $id');
    var feed = videoState.feedIdToDisplayStreamsMap[id];
    if (feed == null) return;

    videoState.feedIdToDisplayStreamsMap.remove(id.toString());
    await videoState.streamsToBeRendered[id]?.dispose();
    // setState(() {
    videoState.streamsToBeRendered.remove(id.toString());
    // });
    var unsubscribeStreams = (feed['streams'] as List<dynamic>).map((stream) {
      return SubscriberUpdateStream(
          feed: id, mid: stream['mid'], crossrefid: null);
    }).toList();
    if (remotePlugin != null) {
      print('remote plugin unsbscribed: ${unsubscribeStreams}');
      await remotePlugin?.update(unsubscribe: unsubscribeStreams);
    }
    videoState.feedIdToMidSubscriptionMap.remove(id);

    // _conferenceStream.add(videoState.streamsToBeRendered);
    _refreshStreams();
  }

  ///
  /// InCall actions
  ///
  @override
  Future<void> kick({required String id}) async {
    StreamRenderer? renderer = videoState.streamsToBeRendered[id];
    if (renderer == null) {
      return;
    }
    _startRecord(renderer.mediaStream!);
    // var payload = {
    //   "request": "kick",
    //   "room": room,
    //   "id": int.parse(id),
    // };
    // await videoPlugin?.send(data: payload);
  }

  @override
  Future<void> mute({required String kind, required bool muted}) async {
    var payload = {
      "request": "moderate",
      "room": room,
      "id": int.parse(myId),
      "mid": kind == 'video' ? '1' : '0',
      "mute": muted
    };
    await videoPlugin?.send(data: payload);
    localVideoRenderer.mediaStream
        ?.getTracks()
        .where((element) => element.kind == kind)
        .toList()
        .forEach((element) {
      print('mid: ${element.id}');
      element.enabled = !muted;
    });

    if (kind == 'audio') {
      localVideoRenderer.isAudioMuted = muted;
    } else {
      localVideoRenderer.isVideoMuted = muted;
    }

    _refreshStreams();
    _getEngagement();
  }

  @override
  Future<void> ping({required String msg}) async {
    await videoPlugin?.sendData(msg);
  }

  @override
  Future<void> switchCamera() async {
    front = !front;
    await videoPlugin?.switchCamera(deviceId: await getCameraDeviceId(front));
    localVideoRenderer = StreamRenderer('local', 'local');
    await localVideoRenderer.init();
    localVideoRenderer.videoRenderer.srcObject =
        videoPlugin?.webRTCHandle!.localStream;
    localVideoRenderer.publisherName = "My Camera";
    videoState.streamsToBeRendered['local'] = localVideoRenderer;
  }

  @override
  Future<void> shareScreen(MediaStream? mediaStream) async {
    if (mediaStream == null) {
      _disposeScreenSharing();
      return;
    }

    screenSharing = true;
    // _initLocalMediaRenderer();
    screenPlugin = await session?.attach<JanusVideoRoomPlugin>();
    screenPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        myPvtId = data.privateId;
        (await screenPlugin?.configure(
            bitrate: 3000000,
            sessionDescription: await screenPlugin?.createOffer(
                audioRecv: false, videoRecv: false)));
      }
      if (data is VideoRoomLeavingEvent) {
        _unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        _unSubscribeTo(data.unpublished);
      }
      screenPlugin?.handleRemoteJsep(event.jsep);
    });
    await localScreenSharingRenderer.init();
    localScreenSharingRenderer.publisherId = myId.toString();

    // localScreenSharingRenderer.mediaStream = await screenPlugin
    //     ?.initializeMediaDevices(
    //         mediaConstraints: {'video': true, 'audio': true},
    //         useDisplayMediaDevices: true);

    //safari require action from a user gesture
    localScreenSharingRenderer.mediaStream = mediaStream;
    screenPlugin?.webRTCHandle!.localStream = mediaStream;
    screenPlugin?.webRTCHandle!.localStream!
        .getTracks()
        .forEach((element) async {
      await screenPlugin?.webRTCHandle!.peerConnection!
          .addTrack(element, screenPlugin!.webRTCHandle!.localStream!);
    });

    localScreenSharingRenderer.videoRenderer.srcObject =
        localScreenSharingRenderer.mediaStream;
    localScreenSharingRenderer.publisherName = "Your Screenshare";

    //stop sharing from chrome interface
    localScreenSharingRenderer.mediaStream?.getVideoTracks()[0].onEnded = () {
      _disposeScreenSharing();
    };

    videoState.streamsToBeRendered.putIfAbsent(
        localScreenSharingRenderer.id, () => localScreenSharingRenderer);

    _refreshStreams();

    await screenPlugin?.joinPublisher(room,
        displayName: "${displayName}_screenshare", id: screenShareId, pin: "");
  }

  _disposeScreenSharing() async {
    // setState(() {
    screenSharing = false;
    // });
    await screenPlugin?.unpublish();
    StreamRenderer? rendererRemoved;
    // setState(() {
    rendererRemoved =
        videoState.streamsToBeRendered.remove(localScreenSharingRenderer.id);
    // });
    await rendererRemoved?.dispose();
    await screenPlugin?.hangup();
    screenPlugin = null;
    _refreshStreams();
  }

  @override
  Future<void> finishCall() async {
    _closeCall('User hanged');
  }

  Future<dynamic> _closeCall(String reason) async {
    await _endCall();
    await getIt.get<ChatCubit>().loadChats(1, 20);

    for (var feed in videoState.feedIdToDisplayStreamsMap.entries) {
      await _unSubscribeTo(feed.key);
    }
    videoState.streamsToBeRendered.forEach((key, value) async {
      await value.dispose();
    });
    // setState(() {
    videoState.streamsToBeRendered.clear();
    videoState.feedIdToDisplayStreamsMap.clear();
    videoState.subStreamsToFeedIdMap.clear();
    videoState.feedIdToMidSubscriptionMap.clear();
    joined = false;
    // screenSharing = false;
    engagementEnabled = false;
    // });

    await videoPlugin?.hangup();
    if (screenSharing) {
      await screenPlugin?.hangup();
    }
    await videoPlugin?.dispose();
    await screenPlugin?.dispose();
    await remotePlugin?.dispose();
    remotePlugin = null;

    session?.dispose();

    _conferenceEndedStream.add(reason);
  }

  Future<bool> _endCall() async {
    return await _api.endCall(callId: callId, userId: user?.id);
  }

  /// End InCall actions

  ///
  /// Stream actions
  ///

  @override
  Future<void> publish() async {
    _canBePublished().then((value) async {
      if (value) {
        await videoPlugin?.initializeWebRTCStack();
        await _configureLocalVideoRenderer();
        await _publishMyOwn();
        await videoPlugin?.initDataChannel();
      }
    });
  }

  @override
  Future<void> publishById({required String id}) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.publish, id: id).toJson()));
  }

  @override
  Future<void> unPublishById({required String id}) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.unPublish, id: id)
            .toJson()));
  }

  @override
  Future<void> unPublish() async {
    await videoPlugin?.unpublish();
  }

  Future<bool> _canBePublished() async {
    var participants = await getParticipants();
    var publishers = participants.where((element) => element.publisher);
    print('Number of publishers ${publishers.length}');

    var max = roomDetails?.maxPublishers!.toInt() ?? maxPublishersDefault;

    return publishers.length < max;
  }

  _publishMyOwn() async {
    var offer =
        await videoPlugin?.createOffer(audioRecv: false, videoRecv: false);
    await videoPlugin?.configure(bitrate: 2000000, sessionDescription: offer);

    for (var audioTrack in localVideoRenderer.mediaStream!.getAudioTracks()) {
      print('${audioTrack.id} audio track');
      _addOnEndedToTrack(audioTrack);
    }
  }

  _addOnEndedToTrack(MediaStreamTrack track) {
    track.onEnded ??= () => _replaceAudioTrack();
  }

  _replaceAudioTrack() async {
    print('track is ended');
    var stream = await flutterWebRTC.navigator.mediaDevices
        .getUserMedia({'audio': true});
    var audioTrack = stream.getAudioTracks()[0];

    // audioTrack.onEnded = () =>_replaceAudioTrack();
    _addOnEndedToTrack(audioTrack);

    List<RTCRtpSender>? senders =
        await videoPlugin?.webRTCHandle?.peerConnection?.senders;
    senders?.forEach((sender) async {
      if (sender.track?.kind == 'audio') {
        await sender.replaceTrack(audioTrack);
        print('${sender.track?.label} track is replaced');
      }
    });
  }

  _unPublish() async {
    await videoPlugin?.unpublish();
  }

  @override
  Future<List<Participant>> getParticipants() async {
    var payload = {"request": "listparticipants", "room": room};
    Map participants = await videoPlugin?.send(data: payload);
    JanusEvent event = JanusEvent.fromJson(participants);

    List<Participant> subscribers = [];

    for (var par in event.plugindata?.data['participants']) {
      var participant = Participant.fromJson(par as Map<String, dynamic>);
      // if(!participant.publisher){
      subscribers.add(participant);
      // }
    }
    _participantsStream.add(subscribers);

    return subscribers;
  }

  @override
  Future<void> changeSubStream(
      {required ConfigureStreamQuality quality,
      required StreamRenderer remoteStream}) async {
    // var numberOfPublishers = videoState.streamsToBeRendered.length;
    // ConfigureStreamQuality.values[index];
    // var streamQuality = ConfigureStreamQuality.HIGH;
    // if (numberOfPublishers > 2) {
    //   streamQuality = ConfigureStreamQuality.MEDIUM;
    // }
    //
    // if (numberOfPublishers > 3) {
    //   streamQuality = ConfigureStreamQuality.LOW;
    // }

    // for (var remoteStream in videoState.streamsToBeRendered.entries
    //     .map((e) => e.value)
    //     .toList()) {
    //   await remotePlugin?.configure(
    //     streams: [
    //       ConfigureStream(mid: remoteStream.mid, substream: quality)
    //     ],
    //   );
    changeSubstream(remoteStreamId: remoteStream.id, substream: 1);
    remoteStream.subStreamQuality = quality;
    // }
  }

  @override
  Future<void> changeSubstream(
      {required String remoteStreamId, required int substream}) async {
    print('changedSubstream for mid=$remoteStreamId to $substream');
    await remotePlugin?.send(data: {
      'request': "configure",
      'mid': remoteStreamId,
      'substream': substream
    });
  }

  ///End Stream actions

  _refreshStreams() {
    _conferenceStream.add(videoState.streamsToBeRendered);
  }

  _joinRoom() async {
    await _checkRoom();
  }

  _checkRoom() async {
    var exist = await videoPlugin?.exists(room);
    JanusEvent event = JanusEvent.fromJson(exist);
    print('room is exist: ${event.plugindata}');
    if (event.plugindata?.data['exists'] == true) {
      print('try to join publisher');

      // var payload = {
      //   "request": "edit",
      //   "room": room,
      //   "audiolevel_event" : true,
      //   "secret" : ""
      // };
      //
      // await videoPlugin?.send(data: payload);
      await _joinPublisher();
    } else {
      print('need to create the room');
      await _createRoom(room);
    }
  }

  _createRoom(int roomId) async {
    Map<String, dynamic>? extras = {
      'publishers': maxPublishersDefault,
      'audiolevel_event': true,
      'audio_active_packets': 25,
      'audio_level_average': 35,
      'audio_level_threshold': 10
    };
    var created = await videoPlugin?.createRoom(room, extras: extras);
    JanusEvent event = JanusEvent.fromJson(created);
    if (event.plugindata?.data['videoroom'] == 'created') {
      await _joinPublisher();
    } else {
      print('error creating room');
    }
  }

  _joinPublisher() async {
    roomDetails = await _getRoomDetails(room);
    await videoPlugin?.joinPublisher(room,
        displayName: displayName, id: int.parse(myId));
  }

  Future<JanusVideoRoom?> _getRoomDetails(int roomId) async {
    var payload = {"request": "list"};
    Map allRooms = await videoPlugin?.send(data: payload);
    JanusEvent event = JanusEvent.fromJson(allRooms);

    for (var r in event.plugindata?.data['list']) {
      var room = JanusVideoRoom.fromJson(r as Map<String, dynamic>);
      if (room.room == roomId) {
        return room;
      }
    }
    return null;
  }

  // Future<List<JanusVideoRoom>> _listRooms() async {
  //   print('get all rooms');
  //   var payload = {"request": "list"};
  //   Map allRooms = await videoPlugin?.send(data: payload);
  //   JanusEvent event = JanusEvent.fromJson(allRooms);
  //
  //   List<JanusVideoRoom> rooms = [];
  //
  //   for (var room in event.plugindata?.data['list']) {
  //     var participant = JanusVideoRoom.fromJson(room as Map<String, dynamic>);
  //     rooms.add(participant);
  //   }
  //   return rooms;
  // }

  _cleanupWebRTC() async {
    StreamRenderer? rendererRemoved;
    rendererRemoved =
        videoState.streamsToBeRendered.remove(localVideoRenderer.id);
    await rendererRemoved?.dispose();

    localVideoRenderer.dispose();

    var config = videoPlugin?.webRTCHandle;
    if (config!.localStream != null) {
      config.localStream?.getAudioTracks().forEach((element) async {
        await element.stop();
      });

      config.localStream?.getVideoTracks().forEach((element) async {
        await element.stop();
      });
    }

    await config.peerConnection?.close();
    config.peerConnection = null;
    config.localStream?.dispose();

    _refreshStreams();
  }

  _renderCommand(DataChannelCommand command) {
    // print('render command');

    switch (command.command) {
      case DataChannelCmd.unPublish:
        if (command.id == myId.toString()) {
          _unPublish();
        }
        break;

      case DataChannelCmd.publish:
        if (command.id == myId.toString()) {
          print('publish myself');
          publish();
        }
        break;

      case DataChannelCmd.engagement:
        // print('engagement received ${command.data['engagement']}');
        videoState.streamsToBeRendered[command.id]?.engagement =
            command.data['engagement'] as int;
        _refreshStreams();
        break;

      case DataChannelCmd.message:
        print('message received ${command.data['message']}');
        messages.add(ChatMessage(
            message: command.data['message'],
            displayName: command.data['displayName'],
            time: DateTime.parse(command.data['time']),
            avatarUrl: command.data['avatarUrl'],
            seen: false));
        _conferenceChatStream.add(messages);
        break;
    }
  }

  _getEngagement() async {
    return;

    if (engagementIsRunning || (localVideoRenderer.isVideoMuted ?? false))
      return;

    engagementIsRunning = true;

    try {
      var image = await localVideoRenderer.mediaStream
          ?.getVideoTracks()
          .first
          .captureFrame();

      var img = base64Encode(image!.asUint8List().toList()).toString();

      //make image 256x256
      // final decoded = decodePng(image!.asUint8List());
      // final resized = copyResizeCropSquare(decoded!,  256);
      // final resizedByteData = encodePng(resized);
      // var img = base64Encode(resizedByteData);

      final engagement = await _api.getEngagement(
          averageAttention: 0,
          callId: callId,
          image: img,
          participantId: user?.id);

      // var engagement = Random().nextDouble() * (0.85 - 0.4) + 0.4;

      if (engagement! > 0) {
        var eng = ((engagement) * 100).toInt();
        videoState.streamsToBeRendered['local']?.engagement = eng;
        _refreshStreams();
        _calculateAverageEngagement();
        _sendMyEngagementToOthers(eng);
        await _sendMyEngagementToServer(engagement);
      }
    } finally {
      engagementIsRunning = false;
      if (engagementEnabled) {
        await Future.delayed(const Duration(seconds: 3));
        _getEngagement();
      }
    }
  }

  _sendMyEngagementToServer(double engagement) async {
    await _api.sendEngagement(
        engagement: engagement, userId: user!.id.toString(), callId: callId);
  }

  _sendMyEngagementToOthers(int engagement) async {
    var data = {'engagement': engagement};

    await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
            command: DataChannelCmd.engagement,
            id: user!.id.toString(),
            data: data)
        .toJson()));
  }

  _broadcastMessage(String msg) async {
    var data = {
      "message": msg,
      'displayName': user!.name,
      'time': DateTime.now().toIso8601String(),
      'avatarUrl': user!.imageUrl
    };

    await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
            command: DataChannelCmd.message,
            id: user!.id.toString(),
            data: data)
        .toJson()));
  }

  _calculateAverageEngagement() {
    var sum = 0;
    var avgInclude = 0;
    for (var videoStream in videoState.streamsToBeRendered.values) {
      if (videoStream.engagement != null) {
        if (videoStream.engagement! > 0) {
          avgInclude++;
          sum = sum + videoStream.engagement!;
        }
      }
    }
    double avg = sum / avgInclude;
    _avgEngagementStream.add(avg.toInt());
  }

  bool engagementEnabled = true;
  bool engagementIsRunning = false;

  @override
  Future<void> toggleEngagement({required bool enabled}) async {
    engagementEnabled = enabled;
    _getEngagement();
  }

  @override
  Future<ApiResponse<bool>> sendMessage(String msg,
      {List<PlatformFile>? uploadedFiles}) async {
    messages.add(ChatMessage(
      files: uploadedFiles,
      message: msg,
      displayName: 'Me',
      time: DateTime.now(),
      avatarUrl: user!.imageUrl,
      seen: true,
    ));
    _conferenceChatStream.add(messages);
    await _broadcastMessage(msg);
    return ApiResponse(response: true);
  }

  List<flutterWebRTC.MediaRecorder> recorderList = [];
  var currentIndexRecording = "";
  bool recording = false;
  List<dynamic> blobs = []; // Store video blobs
  List<Future<void>> stopFutures = [];

  // flutterWebRTC.MediaRecorder? mediaRecorder;

  Future<void> startRecordStream(flutterWebRTC.MediaStream stream) async {
    flutterWebRTC.MediaRecorder? mediaRecorder = flutterWebRTC.MediaRecorder();
    try {
      print("mediaRecorder: $mediaRecorder");
      mediaRecorder.startWeb(stream, mimeType: 'video/webm;codecs=vp8,opus');
      recorderList.add(mediaRecorder);
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  _startRecord(flutterWebRTC.MediaStream stream) async {
    try {
      if (stream.id != currentIndexRecording && recording) {
        await stopRecord();
        print('=============================');
        print(stream.id);
        print('=============================');
        startRecordStream(stream);
        currentIndexRecording = stream.id;
      }
    } catch (e) {
      print("Error starting recording: $e");
      return false;
    }
  }

  Future<StreamRenderer> getItemByIndex(int index) async {
    Map<dynamic, StreamRenderer> streams = await _conferenceStream.stream.first;
    if (index < 0 || index >= streams.length) {
      throw RangeError("Index out of range");
    }
    return streams.values.elementAt(index);
  }

  @override
  Future<bool> startRecording() async {
    try {
      recorderList = [];
      blobs = [];
      currentIndexRecording = "";
      recording = true;

      StreamRenderer stream = await getItemByIndex(0);
      _startRecord(stream.mediaStream!);
      return true;
    } catch (e) {
      print("Error starting recording: $e");
      recording = false;
      return false;
    }
  }

  stopRecord() async {
    print('===============_stopRecord_==============');
    if (recorderList.isNotEmpty) {
      for (var recorder in List.from(recorderList)) {
        stopFutures.add(recorder.stop().then((blob) {
          blobs.add(blob); // Add the actual Blob, not a URL
          recorderList.remove(recorder);
          print('=============== blob: $blob ==============');
          print('=============== recorderList.remove ==============');
        }));
      }
    }

    await Future.wait(stopFutures).then((v) {
      print('===============_stopRecord_ finish ==============');
    }); // Ensure all recordings are stopped
  }

  @override
  Future<void> stopRecording() async {
    await stopRecord();
    recording = false;
    if (blobs.isNotEmpty) {
      mergeVideos(blobs);
    } else {
      print("Not enough videos to merge.");
    }
    // }
  }

  Future<List<Uint8List>> fetchVideoData(List<String> urls) async {
    return await Future.wait(urls.map((url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          print("Success to fetch video: $url");
          return response.bodyBytes;
        } else {
          print("Failed to fetch video: $url");
          throw Exception('Failed to load file');
        }
      } catch (e) {
        print("Error fetching video from $url: $e");
        rethrow;
      }
    }));
  }

  Future<Uint8List> fetchDataFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes; // Return the byte data of the file
    } else {
      throw Exception('Failed to load file from URL');
    }
  }

  // void mergeVideos(List<dynamic> blobs) {
  //   // final js.JsArray blobArray = js.JsArray.from(blobs);

  //   // Call the JavaScript function directly
  //   // js.context.callMethod('concatenateVideos', [blobArray]);
  // }

  void downloadRecording(String blob) async {
    print("Recording downloaded.");

    final Uri url = Uri.parse(blob);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $blob');
    }
  }

  @override
  Future<MeetingDto?> startCall() async {
    var res = await _api.startCall(streamId: room.toString(), userId: user?.id);
    callId = res.response?.callId;
    return res.response;
  }

// void createBlob(Uint8List videoData) {
//   final blob = html.Blob([videoData], 'video/mp4');
//   final url = html.Url.createObjectUrlFromBlob(blob);
//   print("Blob URL created: $url");
// }

// Future<void> mergeFiles(List<Uint8List> fileDataList) async {
//   try {
//     // Create temporary files from byte data for FFmpegKit
//     List<String> tempFilePaths = [];
//
//     for (var i = 0; i < fileDataList.length; i++) {
//       final tempFile = await createTempFile(fileDataList[i]);
//       tempFilePaths.add(tempFile);
//     }
//
//     // Construct the FFmpeg command for merging
//     final inputFiles = tempFilePaths.map((path) => "-i $path").join(" ");
//     final outputFile = 'output_combined.mp4';
//
//     final command = "ffmpeg $inputFiles -filter_complex \"concat=n=${fileDataList.length}:v=1:a=1\" -y $outputFile";
//
//     final session = await FFmpegKit.execute(command);
//
//     // Check for successful execution
//     final returnCode = await session.getReturnCode();
//     if (returnCode!.isValueSuccess()) {
//       print("Merge successful!");
//     } else {
//       print("Merge failed: $returnCode");
//     }
//   } catch (e) {
//     print('Error during merge: $e');
//   }
// }
//
//
// // Helper function to create a temporary file from byte data
// Future<String> createTempFile(Uint8List data) async {
//   final tempDirectory = await getTemporaryDirectory();
//    File(data, '${tempDirectory.path}/tempfile_${DateTime.now().millisecondsSinceEpoch}.mp4');
//   // await tempFile.writeAsBytes(data);
//   return '${tempDirectory.path}/tempfile_${DateTime.now().millisecondsSinceEpoch}.mp4';
// }
}
