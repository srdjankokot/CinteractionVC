import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/data_channel_command.dart';
import '../../../core/util/conf.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';

import '../source/local/local_storage.dart';

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
  late JanusVideoRoom roomDetails;

  final _conferenceStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();
  final _conferenceEndedStream = StreamController<String>.broadcast();
  final _participantsStream = StreamController<List<Participant>>.broadcast();
  final _avgEngagementStream = StreamController<int>.broadcast();

  User? user = getIt.get<LocalStorage>().loadLoggedUser();

  late int myId = user?.id ?? Random().nextInt(999999);
  late String displayName = user?.name ?? 'User $myId';

  get screenShareId => myId + int.parse("1");

  int? callId;

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

    await _startCall();
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

  _initLocalMediaRenderer() {
    print('initLocalMediaRenderer');
    localScreenSharingRenderer = StreamRenderer('localScreenShare');
    localVideoRenderer = StreamRenderer('local');
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
    if (publishers != null) {
      List<List<Map>> sources = [];
      for (Map publisher in publishers) {
        if ([myId, screenShareId].contains(publisher['id'])) {
          continue;
        }
        videoState.feedIdToDisplayStreamsMap[publisher['id']] = {
          'id': publisher['id'],
          'display': publisher['display'],
          'streams': publisher['streams']
        };
        List<Map> mappedStreams = [];
        for (Map stream in publisher['streams'] ?? []) {
          if (stream['disabled'] == true) {
            _manageMuteUIEvents(stream['mid'], stream['type'], true);
          } else {
            _manageMuteUIEvents(stream['mid'], stream['type'], false);
          }
          if (videoState.feedIdToMidSubscriptionMap[publisher['id']] != null &&
              videoState.feedIdToMidSubscriptionMap[publisher['id']]
                      ?[stream['mid']] ==
                  true) {
            continue;
          }
          stream['id'] = publisher['id'];
          stream['display'] = publisher['display'];

          mappedStreams.add(stream);
        }
        sources.add(mappedStreams);
      }
      await _subscribeTo(sources);
    }
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

      var id = event.plugindata?.data['id'];
      if (id != null) {
        StreamRenderer? renderer =
            videoState.streamsToBeRendered[id.toString()];
        renderer?.publisherName = event.plugindata?.data['display'];
        // _conferenceStream.add(videoState.streamsToBeRendered);
        _refreshStreams();
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
      print('retrying to connect publisher');
      var offer = await videoPlugin?.createOffer(
        audioRecv: false,
        videoRecv: false,
      );
      await videoPlugin?.configure(sessionDescription: offer);
    });
    screenPlugin?.renegotiationNeeded?.listen((event) async {
      if (screenPlugin?.webRTCHandle?.peerConnection?.signalingState !=
          RTCSignalingState.RTCSignalingStateStable) return;
      print('retrying to connect publisher');
      var offer =
          await screenPlugin?.createOffer(audioRecv: false, videoRecv: false);
      await screenPlugin?.configure(sessionDescription: offer);
    });

    videoPlugin?.peerConnection?.onConnectionState = (state) {
      print('peerConnection state: ${state.name}');
    };
  }

  _manageMuteUIEvents(String mid, String kind, bool muted) async {
    int? feedId = videoState.subStreamsToFeedIdMap[mid]?['feed_id'];
    if (feedId == null) {
      return;
    }
    StreamRenderer? renderer =
        videoState.streamsToBeRendered[feedId.toString()];
    print('mid: $mid muted: $muted $kind');
    // setState(() {
    if (kind == 'audio') {
      renderer?.isAudioMuted = muted;
    } else {
      renderer?.isVideoMuted = muted;
    }
    // });
    _refreshStreams();
  }

  _configureLocalVideoRenderer() async {
    await localVideoRenderer.init();
    print("media constraints");

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
          maxBitrate: 512000,
          active: true,
          scalabilityMode: 'L1T2'),
      RTCRtpEncoding(
        rid: "m",
        minBitrate: 128000,
        maxBitrate: 256000,
        active: true,
        scalabilityMode: 'L1T2',
        scaleResolutionDownBy: 2,
      ),
      RTCRtpEncoding(
        rid: "l",
        minBitrate: 96000,
        maxBitrate: 128000,
        active: true,
        scalabilityMode: 'L1T2',
        scaleResolutionDownBy: 4,
      ),
    ], mediaConstraints: {
      'video': {'width': 640, 'height': 360},
      'audio': true
    });
    localVideoRenderer.videoRenderer.srcObject = localVideoRenderer.mediaStream;
    localVideoRenderer.publisherName = "You";
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
        List<dynamic>? streams = event.plugindata?.data['streams'];
        streams?.forEach((element) {
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
          print("onMessage ${data.text}");

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
          print("messageStream ${message.text}");
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

        // manageMuteUIEvents(event.mid!, event.track!.kind!, !event.flowing!);

        int? feedId = videoState.subStreamsToFeedIdMap[event.mid]?['feed_id'];
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
          }
          if (!videoState.streamsToBeRendered.containsKey(feedId.toString()) &&
              event.flowing == true &&
              event.track?.kind == "video") {
            var localStream = StreamRenderer(feedId.toString());
            await localStream.init();
            localStream.mediaStream =
                await createLocalMediaStream(feedId.toString());
            localStream.mediaStream?.addTrack(event.track!);
            localStream.videoRenderer.srcObject = localStream.mediaStream;
            localStream.videoRenderer.onResize = () => {
                  // setState(() {})
                  // _conferenceStream.add(videoState.streamsToBeRendered)
                };
            localStream.publisherName = displayName;
            localStream.publisherId = feedId.toString();
            localStream.mid = event.mid;
            // setState(() {
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
    var payload = {
      "request": "kick",
      "room": room,
      "id": int.parse(id),
    };
    await videoPlugin?.send(data: payload);
  }

  @override
  Future<void> mute({required String kind, required bool muted}) async {
    // _getEngagement();

    var peerConnection = videoPlugin?.webRTCHandle?.peerConnection;

    var transceivers = (await peerConnection?.getTransceivers())
        ?.where((element) => element.sender.track?.kind == kind)
        .toList();
    if (transceivers?.isEmpty == true) {
      return;
    }
    await transceivers?.first.setDirection(
        !muted ? TransceiverDirection.SendOnly : TransceiverDirection.Inactive);
  }

  @override
  Future<void> ping({required String msg}) async {
    await videoPlugin?.sendData(msg);
  }

  @override
  Future<void> switchCamera() async {
    front = !front;
    await videoPlugin?.switchCamera(deviceId: await getCameraDeviceId(front));
    localVideoRenderer = StreamRenderer('local');
    await localVideoRenderer.init();
    localVideoRenderer.videoRenderer.srcObject =
        videoPlugin?.webRTCHandle!.localStream;
    localVideoRenderer.publisherName = "My Camera";
    videoState.streamsToBeRendered['local'] = localVideoRenderer;
  }

  @override
  Future<void> finishCall() async {
    _closeCall('User hanged');
  }

  Future<dynamic> _closeCall(String reason) async {
    await _endCall();

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
    screenSharing = false;
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

  _startCall() async {
    callId = await _api.startCall(streamId: room.toString(), userId: user?.id);
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
    return publishers.length < roomDetails.maxPublishers!.toInt();
  }

  _publishMyOwn() async {
    var offer =
        await videoPlugin?.createOffer(audioRecv: false, videoRecv: false);
    await videoPlugin?.configure(bitrate: 2000000, sessionDescription: offer);
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
      {required ConfigureStreamQuality quality}) async {
    var numberOfPublishers = videoState.streamsToBeRendered.length;
    // ConfigureStreamQuality.values[index];
    var streamQuality = ConfigureStreamQuality.HIGH;
    if (numberOfPublishers > 2) {
      streamQuality = ConfigureStreamQuality.MEDIUM;
    }

    if (numberOfPublishers > 3) {
      streamQuality = ConfigureStreamQuality.LOW;
    }

    for (var remoteStream in videoState.streamsToBeRendered.entries
        .map((e) => e.value)
        .toList()) {
      remoteStream.mediaStream?.getVideoTracks();

      await remotePlugin?.configure(
        streams: [
          ConfigureStream(mid: remoteStream.mid, substream: streamQuality)
        ],
      );
    }
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
      await _joinPublisher();
    } else {
      await _createRoom(room);
    }
  }

  _createRoom(int roomId) async {
    // Map<String, dynamic>? extras ={
    //   'videocodec': 'vp9'
    // };
    var created = await videoPlugin?.createRoom(room);
    JanusEvent event = JanusEvent.fromJson(created);
    if (event.plugindata?.data['videoroom'] == 'created') {
      await _joinPublisher();
    } else {
      print('error creating room');
    }
  }

  _joinPublisher() async {
    var rooms = await _listRooms();
    roomDetails = rooms!.firstWhere((r) => r.room == room);
    print('roomDetails: ${roomDetails.toJson().toString()}');

    await videoPlugin?.joinPublisher(room, displayName: displayName, id: myId);
  }

  Future<List<JanusVideoRoom>?> _listRooms() async {
    var rooms = await videoPlugin?.getRooms();
    return rooms?.list;
  }

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
    print('render command');

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
        videoState.streamsToBeRendered[command.id]?.engagement =
            command.data['engagement'] as int;
        _refreshStreams();
        break;
    }
  }

  _getEngagement() async {
    print("get engagement");

    if (engagementEnabled && !engagementInProgress) {
      engagementInProgress = true;
      var image = await localVideoRenderer.mediaStream
          ?.getVideoTracks()
          .first
          .captureFrame();

      // print(base64Encode(image!.asUint8List().toList()).toString());

      final engagement = await _api.engagement(
          averageAttention: 0,
          callId: callId,
          image: base64Encode(image!.asUint8List().toList()).toString(),
          participantId: user?.id);

      if (engagement! > 0) {
        var eng = ((engagement) * 100).toInt();
        videoState.streamsToBeRendered['local']?.engagement = eng;
        _refreshStreams();
        _calculateAverageEngagement();
        _sendMyEngagementToOthers(eng);
      }
      // else{
      //   var eng = Random().nextInt(100);
      //   videoState.streamsToBeRendered['local']?.engagement = eng;
      //   _refreshStreams();
      //   _sendMyEngagementToOthers(eng);
      // }

      print('My engagement: $engagement');
      await Future.delayed(const Duration(seconds: 3));
      engagementInProgress = false;
      _getEngagement();
    }
  }

  _sendMyEngagementToOthers(int engagement) async {
    var data = {'engagement': engagement};

    await videoPlugin?.sendData(jsonEncode(DataChannelCommand(
            command: DataChannelCmd.engagement,
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
    var avg = sum / avgInclude;
    _avgEngagementStream.add(avg as int);
  }

  bool engagementEnabled = true;
  bool engagementInProgress = false;

  @override
  Future<void> toggleEngagement({required bool enabled}) async {
    engagementEnabled = enabled;
    _getEngagement();
  }


}
