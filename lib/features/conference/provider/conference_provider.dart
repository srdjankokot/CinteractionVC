import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cinteraction_vc/core/io/network/models/data_channel_command.dart';
import 'package:cinteraction_vc/util.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../conf.dart';
import '../../../core/io/network/models/participant.dart';

import 'package:http/http.dart' as http;

class ConferenceProvider {
  ConferenceProvider();

  JanusClient? client;
  WebSocketJanusTransport? ws;

  // RestJanusTransport? http;
  JanusSession? session;

  late StreamRenderer localVideoRenderer;
  late StreamRenderer localScreenSharingRenderer;

  // int? myId;
  int myId = DateTime.now().millisecondsSinceEpoch;
  int? myPvtId;

  bool joined = true;
  bool screenSharing = false;
  bool front = true;
  dynamic fullScreenDialog;

  get screenShareId => myId + int.parse("1");

  JanusVideoRoomPlugin? videoPlugin;
  JanusVideoRoomPlugin? remotePlugin;
  JanusVideoRoomPlugin? screenPlugin;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  // int room = 6108560605;
  int room = 12344321;
  late JanusVideoRoom roomDetails;

  // int room = 7956726554;
  String displayName = 'User ${Random().nextInt(100)}';

  final _conferenceStream =
      StreamController<Map<dynamic, StreamRenderer>>.broadcast();
  final _conferenceEndedStream = StreamController<String>.broadcast();
  final _participantsStream = StreamController<List<Participant>>.broadcast();

  Stream<Map<dynamic, StreamRenderer>> getConferenceStream() =>
      _conferenceStream.stream;

  Stream<String> getConferenceEndedStream() => _conferenceEndedStream.stream;

  Stream<List<Participant>> getParticipantStream() =>
      _participantsStream.stream;

  Future<void> initialize(int roomId, String displayName) async {
    room = roomId;
    this.displayName = displayName;
    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);
    session = await client?.createSession();
    initLocalMediaRenderer();

    await configureConnection();
    await joinRoom();
  }

  initLocalMediaRenderer() {
    print('initLocalMediaRenderer');
    localScreenSharingRenderer = StreamRenderer('localScreenShare');
    localVideoRenderer = StreamRenderer('local');
  }

  changeSubstream(String remoteStreamId, int substream) async {
    print('changedSubstream for mid=$remoteStreamId to $substream');
    await remotePlugin?.send(data: {
      'request': "configure",
      'mid': remoteStreamId,
      'substream': substream
    });
  }

  joinRoom() async {
    await checkRoom();
  }

  configureConnection() async {
    // myId = DateTime.now().millisecondsSinceEpoch;
    videoPlugin = await attachPlugin(pop: true);
    // initLocalMediaRenderer();
    eventMessagesHandler();
    await configureLocalVideoRenderer();
  }

  List<RTCRtpEncoding> getSimulcastSendEncodings() {
    List<RTCRtpEncoding> list = List.empty(growable: true);

    // [
    // RTCRtpEncoding(active: true, rid: '0',scalabilityMode: 'L1T2',maxBitrate: 2000000, numTemporalLayers: 0, minBitrate: 1000000),
    // RTCRtpEncoding(active: true, rid: '1',scalabilityMode: 'L1T2', maxBitrate: 1000000, scaleResolutionDownBy: 2),
    // RTCRtpEncoding(active: true, rid: '2',scalabilityMode: 'L1T2', maxBitrate: 524288,  scaleResolutionDownBy: 3),
    // RTCRtpEncoding(active: true, rid: '3',scalabilityMode: 'L1T2', maxBitrate: 256000,  scaleResolutionDownBy: 4),
    // RTCRtpEncoding(active: true, rid: '4',scalabilityMode: 'L1T2', maxBitrate: 128000,  scaleResolutionDownBy: 5),
    // RTCRtpEncoding(active: true, rid: '5',scalabilityMode: 'L1T2', maxBitrate: 96000,  scaleResolutionDownBy: 8),
    // ]

    if (true) //check does platform support
    {
      list.add(RTCRtpEncoding(
        rid: "h",
        minBitrate: 128000,
        maxBitrate: 128000,
        active: true,
        scalabilityMode: 'L1T2',
        scaleResolutionDownBy: 8,
      ));

      list.add(RTCRtpEncoding(
          rid: "m",
          minBitrate: 512000,
          maxBitrate: 512000,
          active: true,
          scalabilityMode: 'L1T2'));

      list.add(RTCRtpEncoding(
        rid: "l",
        minBitrate: 256000,
        maxBitrate: 256000,
        active: true,
        scalabilityMode: 'L1T2',
        scaleResolutionDownBy: 6,
      ));
    }

    return list;
  }

  changeSubStream() async {
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

  changeSubStreamToAll(ConfigureStreamQuality quality) async {
    for (var remoteStream in videoState.streamsToBeRendered.entries
        .map((e) => e.value)
        .toList()) {

      await remotePlugin?.configure(
        streams: [
          ConfigureStream(mid: remoteStream.mid, substream: quality)
        ],
      );
    }
  }

  configureLocalVideoRenderer() async {
    await localVideoRenderer.init();
    print("media constraints");

    // localVideoRenderer.mediaStream = await videoPlugin?.initializeMediaDevices(
    //     simulcastSendEncodings: getSimulcastSendEncodings(),
    //     mediaConstraints: {
    //       'video': {'width': 640, 'height': 360},
    //       'audio': true
    //     });


    localVideoRenderer.mediaStream = await videoPlugin?.initializeMediaDevices(simulcastSendEncodings: [
      RTCRtpEncoding(rid: "h", minBitrate: 256000, maxBitrate: 512000, active: true, scalabilityMode: 'L1T2'),
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
    refreshStreams();
  }

  attachPlugin({bool pop = false}) async {
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
          canBePublished().then((value) async {
            if (value) {
              await _publishMyOwn();
            }
          });
        }
      }
      if (data is VideoRoomLeavingEvent) {
        unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        unSubscribeTo(data.unpublished);
      }
      videoPlugin.handleRemoteJsep(event.jsep);
    });

    return videoPlugin;
  }

  Future<void> unSubscribeTo(int id) async {
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
    refreshStreams();
  }

  subscribeTo(List<List<Map>> sources) async {
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
            renderCommand(command);
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
            refreshStreams();
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

  eventMessagesHandler() async {
    videoPlugin?.messages?.listen((payload) async {
      print('eventMessagesHandlerTest: $payload');

      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await attachSubscriberOnPublisherChange(publishers);

      var kicked = event.plugindata?.data['kicked'];
      if (kicked != null) {
        unSubscribeTo(kicked);
      }

      var unpublished = event.plugindata?.data['unpublished'];
      if (unpublished != null) {
        if (unpublished == 'ok') {
          cleanupWebRTC();
        }
      }

      var leaving = event.plugindata?.data['leaving'];
      if (leaving == 'ok') {
        callEnd(event.plugindata?.data['reason']);
      }

      var id = event.plugindata?.data['id'];
      if (id != null) {
        StreamRenderer? renderer =
            videoState.streamsToBeRendered[id.toString()];
        renderer?.publisherName = event.plugindata?.data['display'];
        // _conferenceStream.add(videoState.streamsToBeRendered);
        refreshStreams();
      }
    });

    screenPlugin?.messages?.listen((payload) async {
      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await attachSubscriberOnPublisherChange(publishers);
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

  Future<List<JanusVideoRoom>?> listRooms() async {
    // "request" : "list"
    var rooms = await videoPlugin?.getRooms();
    return rooms?.list;
  }

  kick(String id) async {
    // listRooms();

    // videoPlugin?.editRoom(room, newPublisher: 9);
    var payload = {
      "request": "kick",
      "room": room,
      "id": int.parse(id),
    };
    await videoPlugin?.send(data: payload);
  }

  checkRoom() async {
    var exist = await videoPlugin?.exists(room);
    JanusEvent event = JanusEvent.fromJson(exist);
    print('room is exist: ${event.plugindata}');
    if (event.plugindata?.data['exists'] == true) {
      await joinPublisher();
    } else {
      await createRoom(room);
    }
  }

  createRoom(int roomId) async {
    // Map<String, dynamic>? extras ={
    //   'videocodec': 'vp9'
    // };
    var created = await videoPlugin?.createRoom(room);
    JanusEvent event = JanusEvent.fromJson(created);
    if (event.plugindata?.data['videoroom'] == 'created') {
      await joinPublisher();
    } else {
      print('error creating room');
    }
  }

  joinPublisher() async {
    var rooms = await listRooms();
    roomDetails = rooms!.firstWhere((r) => r.room == room);
    print('roomDetails: ${roomDetails.toJson().toString()}');

    await videoPlugin?.joinPublisher(room, displayName: displayName, id: myId);
  }

  ping(String msg) async {
    await videoPlugin?.sendData(msg);
  }

  unPublishById(String id) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.unPublish, id: id)
            .toJson()));
  }

  publishById(String id) async {
    await videoPlugin?.sendData(jsonEncode(
        DataChannelCommand(command: DataChannelCmd.publish, id: id).toJson()));
  }

  unPublish() async {
    await videoPlugin?.unpublish();
  }

  cleanupWebRTC() async {
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

    if (config != null) {
      await config.peerConnection?.close();
      config.peerConnection = null;
      config.localStream?.dispose();
    }

    // _conferenceStream.add(videoState.streamsToBeRendered);
    refreshStreams();
  }

  Future<List<Participant>> getParticipants() async {
    // var participantss = await  videoPlugin?.getRoomParticipants(room);
    // print('srdjan ${participantss?.participants?.first.display}');
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

  refreshStreams() {
    // changeSubStream();
    _conferenceStream.add(videoState.streamsToBeRendered);
  }

  publish() async {
    canBePublished().then((value) async {
      if (value) {
        await videoPlugin?.initializeWebRTCStack();
        await configureLocalVideoRenderer();
        await _publishMyOwn();
        await videoPlugin?.initDataChannel();
      }
    });
  }

  _publishMyOwn() async {
    // await videoPlugin?.publishMedia();

    var offer =
        await videoPlugin?.createOffer(audioRecv: false, videoRecv: false);
    await videoPlugin?.configure(bitrate: 2000000, sessionDescription: offer);
  }

  // Function to check network speed(Future Method)
  Future<void> checkNetworkSpeed() async {
    const url =
        'https://drive.google.com/file/d/1lEn1DtJQW6-nTcoS_FG7-EB3Kamy0147/view?usp=sharing';
    final stopwatch = Stopwatch()..start();
    try {
      Map<String, String> headers = {"Accept": "text/html,application/xml"};
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final elapsed = stopwatch.elapsedMilliseconds;
        final speedInKbps =
            ((response.bodyBytes.length / 1024) / (elapsed / 1000)) *
                8; // Calculate download speed in Kbps

        print('Download speed: ${speedInKbps.toStringAsFixed(2)} Kbps');
        // Show download speed in an AlertDialog
      } else {
        // Show an error dialog if the download failed
        print("checkNetworkSpeed error");
      }
    } catch (e) {
      // Show an error dialog in case of an exception
      print("checkNetworkSpeed ${e.toString()}");
    }
  }

  attachSubscriberOnPublisherChange(List<dynamic>? publishers) async {
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
            manageMuteUIEvents(stream['mid'], stream['type'], true);
          } else {
            manageMuteUIEvents(stream['mid'], stream['type'], false);
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
      await subscribeTo(sources);
    }
  }

  manageMuteUIEvents(String mid, String kind, bool muted) async {
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
    // _conferenceStream.add(videoState.streamsToBeRendered);
    refreshStreams();
  }

  setBitrate(RTCPeerConnection? peerConnection, int bitrate) async {
    var senders = await peerConnection?.getSenders();
    var sender = senders![1];
    var params = sender.parameters;

    params.encodings![0].maxBitrate = bitrate;
    params.encodings![0].minBitrate = (bitrate / 2) as int?;
    params.encodings![0].maxFramerate = 15;
    sender.setParameters(params);
  }

  mute(String kind, bool muted) async {
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

  Future<dynamic> callEnd(String reason) async {
    for (var feed in videoState.feedIdToDisplayStreamsMap.entries) {
      await unSubscribeTo(feed.key);
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

  Future<bool> canBePublished() async {
    var participants = await getParticipants();
    var publishers = participants.where((element) => element.publisher);
    print('Number of publishers ${publishers.length}');
    return publishers.length < roomDetails.maxPublishers!.toInt();
  }

  screenShare() async {
    // setState(() {
    //   screenSharing = true;
    // });
    screenPlugin = await session?.attach<JanusVideoRoomPlugin>();
    screenPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        myPvtId = data.privateId;

        canBePublished();
        // (await screenPlugin?.configure(
        //     // bitrate: 3000000,
        //     sessionDescription: await screenPlugin?.createOffer(
        //         audioRecv: false, videoRecv: false)));
      }
      if (data is VideoRoomLeavingEvent) {
        unSubscribeTo(data.leaving!);
      }
      if (data is VideoRoomUnPublishedEvent) {
        unSubscribeTo(data.unpublished);
      }
      screenPlugin?.handleRemoteJsep(event.jsep);
    });
    await localScreenSharingRenderer.init();
    localScreenSharingRenderer.publisherId = myId.toString();
    localScreenSharingRenderer.mediaStream = await screenPlugin
        ?.initializeMediaDevices(
            mediaConstraints: {'video': true, 'audio': true},
            useDisplayMediaDevices: true);
    localScreenSharingRenderer.videoRenderer.srcObject =
        localScreenSharingRenderer.mediaStream;
    localScreenSharingRenderer.publisherName = "Your Screenshare";
    // setState(() {
    videoState.streamsToBeRendered.putIfAbsent(
        localScreenSharingRenderer.id, () => localScreenSharingRenderer);
    // _conferenceStream.add(videoState.streamsToBeRendered);
    refreshStreams();
    // });
    await screenPlugin?.joinPublisher(room,
        displayName: "${displayName}_screenshare", id: screenShareId, pin: "");
  }

  disposeScreenSharing() async {
    // setState(() {
    //   screenSharing = false;
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
  }

  Future<void> unSubscribeToVideo(int id) async {
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

    List<SubscriberUpdateStream> list = [];
    for (var element in unsubscribeStreams) {
      if (element.mid == '1') {
        list.add(element);
      }
    }

    if (remotePlugin != null) {
      await remotePlugin?.update(unsubscribe: list);
    }

    videoState.feedIdToMidSubscriptionMap.remove(id);
  }

  switchCamera() async {
    // setState(() {
    front = !front;
    // });
    await videoPlugin?.switchCamera(deviceId: await getCameraDeviceId(front));
    localVideoRenderer = StreamRenderer('local');
    await localVideoRenderer.init();
    localVideoRenderer.videoRenderer.srcObject =
        videoPlugin?.webRTCHandle!.localStream;
    localVideoRenderer.publisherName = "My Camera";
    // setState(() {
    videoState.streamsToBeRendered['local'] = localVideoRenderer;
    // });
  }

  renderCommand(DataChannelCommand command) {
    print('render command');

    switch (command.command) {
      case DataChannelCmd.unPublish:
        if (command.id == myId.toString()) {
          unPublish();
        }
        break;

      case DataChannelCmd.publish:
        if (command.id == myId.toString()) {
          print('publish myself');
          publish();
        }
        break;
    }
  }
}
