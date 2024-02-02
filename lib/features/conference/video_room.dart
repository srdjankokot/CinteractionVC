import 'dart:math';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/ui/widget/call_button_shape.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';

import '../../conf.dart';
import '../../core/ui/images/image.dart';
import '../../util.dart';

class VideoRoomPage extends StatefulWidget {
  final int room;
  final String displayName;

  // const VideoRoomPage(String room, String displayName, {super.key});
  const VideoRoomPage(
      {super.key, required this.room, required this.displayName});

  @override
  State<VideoRoomPage> createState() => _VideoRoomPage();
}

class _VideoRoomPage extends State<VideoRoomPage> {
  late int room;
  late String displayName;

  JanusClient? client;
  WebSocketJanusTransport? ws;
  JanusSession? session;

  bool videoEnabled = true;
  bool audioEnabled = true;
  int? myId;
  int? myPvtId;

  get screenShareId => myId! + int.parse("1");

  JanusVideoRoomPlugin? videoPlugin;
  JanusVideoRoomPlugin? remotePlugin;
  JanusVideoRoomPlugin? screenPlugin;
  late StreamRenderer localVideoRenderer;
  late StreamRenderer localScreenSharingRenderer;

  bool joined = true;
  bool screenSharing = false;
  bool front = true;
  dynamic fullScreenDialog;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  @override
  void initState() {
    super.initState();
    room = widget.room;
    displayName = widget.displayName;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (mounted) {
      await initialize();
    }
  }

  initialize() async {
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

    await joinRoom();
  }

  initLocalMediaRenderer() {
    localScreenSharingRenderer = StreamRenderer('localScreenShare');
    localVideoRenderer = StreamRenderer('local');
  }

  joinRoom() async {
    myId = DateTime.now().millisecondsSinceEpoch;
    initLocalMediaRenderer();
    videoPlugin = await attachPlugin(pop: true);
    eventMessagesHandler();

    await localVideoRenderer.init();
    localVideoRenderer.mediaStream =
        await videoPlugin?.initializeMediaDevices(simulcastSendEncodings: [
      // RTCRtpEncoding(
      //     active: true,
      //     rid: 'h',
      //     scalabilityMode: 'L1T2',
      //     maxBitrate: 256000,
      //     numTemporalLayers: 0,
      //     minBitrate: 94000,
      //     scaleResolutionDownBy: 2),
      // RTCRtpEncoding(
      //     active: true,
      //     rid: 'm',
      //     scalabilityMode: 'L1T2',
      //     maxBitrate: 2000000,
      //     minBitrate: 1000000),
      // RTCRtpEncoding(
      //     active: true,
      //     rid: 'l',
      //     scalabilityMode: 'L1T2',
      //     maxBitrate: 20000,
      //     scaleResolutionDownBy: 8),
    ], mediaConstraints: {
      'video': {
        'width': {'min': 160, 'max': 1280},
        'height': {'min': 90, 'max': 720}
      },
      'audio': true
    }

            //         mediaConstraints: {
            //   'video': {
            //     'width': {'min': 160, 'max': 320},
            //     'height': {'min': 90, 'max': 240}
            //   },
            //   'audio': true
            // }

            );
    localVideoRenderer.videoRenderer.srcObject = localVideoRenderer.mediaStream;
    localVideoRenderer.publisherName = "You";
    localVideoRenderer.publisherId = myId.toString();
    localVideoRenderer.videoRenderer.onResize = () {
      // to update widthxheight when it renders
      setState(() {});
    };
    setState(() {
      videoState.streamsToBeRendered
          .putIfAbsent('local', () => localVideoRenderer);
    });
    // setBitrate(videoPlugin?.webRTCHandle?.peerConnection, 128000);
    await checkRoom();
  }

  checkRoom() async {
    var exist = await videoPlugin?.exists(room);
    JanusEvent event = JanusEvent.fromJson(exist);
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
      debugPrint('error creating room');
    }
  }

  joinPublisher() async {
    await videoPlugin?.joinPublisher(room,
        displayName: context.getCurrentUser?.name, id: myId, pin: "");
  }

  attachPlugin({bool pop = false}) async {
    JanusVideoRoomPlugin? videoPlugin =
        await session?.attach<JanusVideoRoomPlugin>();
    videoPlugin?.typedMessages?.listen((event) async {
      Object data = event.event.plugindata?.data;
      if (data is VideoRoomJoinedEvent) {
        myPvtId = data.privateId;
        if (pop) {
          // Navigator.of(context).pop(joiningDialog);
        }
        {
          var offer =
              await videoPlugin.createOffer(audioRecv: false, videoRecv: false);

          debugPrint("offer: ${offer.sdp}");
          await videoPlugin.configure(
              bitrate: 128000, sessionDescription: offer);
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

  eventMessagesHandler() async {
    videoPlugin?.messages?.listen((payload) async {
      JanusEvent event = JanusEvent.fromJson(payload.event);
      List<dynamic>? publishers = event.plugindata?.data['publishers'];
      await attachSubscriberOnPublisherChange(publishers);
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
          await remotePlugin?.handleRemoteJsep(payload.jsep);
          await remotePlugin?.start(room);
        }
      });

      remotePlugin?.remoteTrack?.listen((event) async {
        print({
          'mid': event.mid,
          'flowing': event.flowing,
          'id': event.track?.id,
          'kind': event.track?.kind
        });
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
            setState(() {});
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
            localStream.videoRenderer.onResize = () => {setState(() {})};
            localStream.publisherName = displayName;
            localStream.publisherId = feedId.toString();
            localStream.mid = event.mid;
            setState(() {
              videoState.streamsToBeRendered
                  .putIfAbsent(feedId.toString(), () => localStream);
            });
          }
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

  manageMuteUIEvents(String mid, String kind, bool muted) async {
    int? feedId = videoState.subStreamsToFeedIdMap[mid]?['feed_id'];
    if (feedId == null) {
      return;
    }
    StreamRenderer? renderer =
        videoState.streamsToBeRendered[feedId.toString()];
    setState(() {
      if (kind == 'audio') {
        renderer?.isAudioMuted = muted;
      } else {
        renderer?.isVideoMuted = muted;
      }
    });
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

  mute(RTCPeerConnection? peerConnection, String kind, bool enabled) async {
    var transrecievers = (await peerConnection?.getTransceivers())
        ?.where((element) => element.sender.track?.kind == kind)
        .toList();
    if (transrecievers?.isEmpty == true) {
      return;
    }
    await transrecievers?.first.setDirection(enabled
        ? TransceiverDirection.SendOnly
        : TransceiverDirection.Inactive);
  }

  void finishCall()  {
    callEnd().then((value) => {
      Navigator.of(context).pop()
    });
  }

  Future<dynamic> callEnd() async {
    for (var feed in videoState.feedIdToDisplayStreamsMap.entries) {
      await unSubscribeTo(feed.key);
    }
    videoState.streamsToBeRendered.forEach((key, value) async {
      await value.dispose();
    });
    setState(() {
      videoState.streamsToBeRendered.clear();
      videoState.feedIdToDisplayStreamsMap.clear();
      videoState.subStreamsToFeedIdMap.clear();
      videoState.feedIdToMidSubscriptionMap.clear();
      joined = false;
      // this.screenSharing = false;
    });

    await videoPlugin?.hangup();
    if (screenSharing) {
      await screenPlugin?.hangup();
    }
    await videoPlugin?.dispose();
    await screenPlugin?.dispose();
    await remotePlugin?.dispose();
    remotePlugin = null;
  }

  screenShare() async {
    setState(() {
      screenSharing = true;
    });
    initLocalMediaRenderer();
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
    setState(() {
      videoState.streamsToBeRendered.putIfAbsent(
          localScreenSharingRenderer.id, () => localScreenSharingRenderer);
    });
    await screenPlugin?.joinPublisher(room,
        displayName: "${displayName}_screenshare", id: screenShareId, pin: "");
  }

  disposeScreenSharing() async {
    setState(() {
      screenSharing = false;
    });
    await screenPlugin?.unpublish();
    StreamRenderer? rendererRemoved;
    setState(() {
      rendererRemoved =
          videoState.streamsToBeRendered.remove(localScreenSharingRenderer.id);
    });
    await rendererRemoved?.dispose();
    await screenPlugin?.hangup();
    screenPlugin = null;
  }

  Future<void> unSubscribeTo(int id) async {
    var feed = videoState.feedIdToDisplayStreamsMap[id];
    if (feed == null) return;

    videoState.feedIdToDisplayStreamsMap.remove(id.toString());
    await videoState.streamsToBeRendered[id]?.dispose();
    setState(() {
      videoState.streamsToBeRendered.remove(id.toString());
    });
    var unsubscribeStreams = (feed['streams'] as List<dynamic>).map((stream) {
      return SubscriberUpdateStream(
          feed: id, mid: stream['mid'], crossrefid: null);
    }).toList();
    if (remotePlugin != null)
      await remotePlugin?.update(unsubscribe: unsubscribeStreams);
    videoState.feedIdToMidSubscriptionMap.remove(id);
  }

  Future<void> unSubscribeToVideo(int id) async {
    var feed = videoState.feedIdToDisplayStreamsMap[id];
    if (feed == null) return;

    // videoState.feedIdToDisplayStreamsMap.remove(id.toString());
    // await videoState.streamsToBeRendered[id]?.dispose();
    // setState(() {
    //   videoState.streamsToBeRendered.remove(id.toString());
    // });
    var unsubscribeStreams = (feed['streams'] as List<dynamic>).map((stream) {
      return SubscriberUpdateStream(
          feed: id, mid: stream['mid'], crossrefid: null);
    }).toList();

    List<SubscriberUpdateStream> list = [];
    unsubscribeStreams.forEach((element) {
      if (element.mid == '1') {
        list.add(element);
      }
    });

    if (remotePlugin != null) {
      await remotePlugin?.update(unsubscribe: list);
    }

    // videoState.feedIdToMidSubscriptionMap.remove(id);
  }

  switchCamera() async {
    setState(() {
      front = !front;
    });
    await videoPlugin?.switchCamera(deviceId: await getCameraDeviceId(front));
    localVideoRenderer = StreamRenderer('local');
    await localVideoRenderer.init();
    localVideoRenderer.videoRenderer.srcObject =
        videoPlugin?.webRTCHandle!.localStream;
    localVideoRenderer.publisherName = "My Camera";
    setState(() {
      videoState.streamsToBeRendered['local'] = localVideoRenderer;
    });
  }

  int _numberOfStream = 1;
  bool _isGridLayout = true;

  @override
  Widget build(BuildContext context) {
    if (videoState.streamsToBeRendered.entries.isEmpty) {
      return Container();
    }

    List<StreamRenderer> items = [];

    for (var i = 0; i < _numberOfStream; i++) {
      items.addAll(
          videoState.streamsToBeRendered.entries.map((e) => e.value).toList());
    }

    return Center(
      child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: ColorConstants.kBlack3,
          child: Builder(
            builder: (context) {
              if (context.isWide) {
                return Stack(
                  children: [
                    getLayout(items),
                    Positioned(
                        top: 20,
                        left: 20,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () => {
                                      setState(() {
                                        _numberOfStream++;
                                      })
                                    }),
                            IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                                onPressed: () => {
                                      setState(() {
                                        _numberOfStream--;
                                      })
                                    }),
                            IconButton(
                                icon: const Icon(
                                  Icons.layers_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () => {
                                      setState(() {
                                        _isGridLayout = !_isGridLayout;
                                      })
                                    })
                          ],
                        )),
                    Positioned.fill(
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CallButtonShape(
                              image: imageSVGAsset('icon_microphone') as Widget,
                              onClickAction: joined
                                  ? () async {
                                      setState(() {
                                        audioEnabled = !audioEnabled;
                                      });
                                      await mute(
                                          videoPlugin
                                              ?.webRTCHandle?.peerConnection,
                                          'audio',
                                          audioEnabled);
                                      setState(() {
                                        localVideoRenderer.isAudioMuted =
                                            !audioEnabled;
                                      });
                                    }
                                  : null),
                          const SizedBox(width: 20),
                          CallButtonShape(
                              image: imageSVGAsset('icon_video_recorder')
                                  as Widget,
                              onClickAction: joined
                                  ? () async {
                                      setState(() {
                                        videoEnabled = !videoEnabled;
                                      });
                                      await mute(
                                          videoPlugin
                                              ?.webRTCHandle?.peerConnection,
                                          'video',
                                          videoEnabled);
                                    }
                                  : null),
                          const SizedBox(width: 20),
                          CallButtonShape(
                              image: imageSVGAsset('icon_arrow_square_up')
                                  as Widget,
                              onClickAction: joined
                                  ? () async {
                                      if (screenSharing) {
                                        await disposeScreenSharing();
                                        return;
                                      }
                                      await screenShare();
                                    }
                                  : null),
                          const SizedBox(width: 20),
                          CallButtonShape(
                              image: imageSVGAsset('icon_user') as Widget,
                              onClickAction: joined ? switchCamera : null),
                          const SizedBox(width: 20),
                          CallButtonShape(
                              image: imageSVGAsset('icon_phone') as Widget,
                              bgColor: ColorConstants.kPrimaryColor,
                              onClickAction: finishCall),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return SafeArea(
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () => {
                                      setState(() {
                                        _numberOfStream++;
                                      })
                                    }),
                            IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                                onPressed: () => {
                                      setState(() {
                                        _numberOfStream--;
                                      })
                                    }),
                            IconButton(
                                icon: imageSVGAsset('icon_switch_camera')
                                    as Widget,
                                onPressed: joined ? switchCamera : null),
                          ],
                        ),
                        Expanded(child: getLayout(items)),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 18.0, bottom: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CallButtonShape(
                                  image: imageSVGAsset('icon_phone') as Widget,
                                  bgColor: ColorConstants.kPrimaryColor,
                                  onClickAction: finishCall),
                              const SizedBox(width: 20),
                              CallButtonShape(
                                  image: imageSVGAsset('icon_microphone')
                                      as Widget,
                                  onClickAction: joined
                                      ? () async {
                                          setState(() {
                                            audioEnabled = !audioEnabled;
                                          });
                                          await mute(
                                              videoPlugin?.webRTCHandle
                                                  ?.peerConnection,
                                              'audio',
                                              audioEnabled);
                                          setState(() {
                                            localVideoRenderer.isAudioMuted =
                                                !audioEnabled;
                                          });
                                        }
                                      : null),
                              const SizedBox(width: 20),
                              CallButtonShape(
                                  image: imageSVGAsset('icon_video_recorder')
                                      as Widget,
                                  onClickAction: joined
                                      ? () async {
                                          setState(() {
                                            videoEnabled = !videoEnabled;
                                          });
                                          await mute(
                                              videoPlugin?.webRTCHandle
                                                  ?.peerConnection,
                                              'video',
                                              videoEnabled);
                                        }
                                      : null),
                              const SizedBox(width: 20),
                              CallButtonShape(
                                  image: imageSVGAsset('icon_arrow_square_up')
                                      as Widget,
                                  onClickAction: joined
                                      ? () async {
                                          if (screenSharing) {
                                            await disposeScreenSharing();
                                            return;
                                          }
                                          await screenShare();
                                        }
                                      : null),
                              const SizedBox(width: 20),
                              CallButtonShape(
                                  image: imageSVGAsset('three_dots') as Widget,
                                  onClickAction: joined ? switchCamera : null),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          )),
    );
  }

  Widget getLayout(List<StreamRenderer> items) {
    var numberStream = items.length;
    var row = sqrt(numberStream).round();
    var col = ((numberStream) / row).ceil();

    var size = MediaQuery.of(context).size;
    // final double itemHeight = (size.height - kToolbarHeight - 24) / row;

    if (context.isWide) {
      if (_isGridLayout) {
        // desktop grid layout
        final double itemHeight = (size.height) / row;
        final double itemWidth = size.width / col;

        return Wrap(
          runSpacing: 0,
          spacing: 0,
          alignment: WrapAlignment.center,
          children: items
              .map((e) => getRendererItem(
                  e, Random().nextInt(100), itemHeight, itemWidth))
              .toList(),
        );
      } else {
        //desktop list layout

        const double itemHeight = 89;
        const double itemWidth = 92;

        return Stack(
          children: [
            Container(
              child: getRendererItem(items.first, Random().nextInt(100),
                  double.maxFinite, double.maxFinite),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 55),
              child: SizedBox(
                width: 100,
                height: MediaQuery.of(context).size.height - 156,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(3),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: getRendererItem(items[index],
                          Random().nextInt(100), itemHeight, itemWidth),
                    );
                  },
                ),
              ),
            ),
          ],
        );
        return Container();
      }
    } else {
      final double itemWidth = size.width;
      //Mobile layout
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return getRendererItem(
                    items[index],
                    Random().nextInt(100),
                    (constraints.minHeight) /
                        (items.length > 3 ? 3 : items.length),
                    itemWidth);
              });
        },
      );
    }

    return const Text("NO LAYOUT");
  }

  Widget getRendererItem(StreamRenderer remoteStream, int engagement,
      double height, double width) {
    debugPrint('getRendererItem: ${remoteStream.publisherName!} $engagement');

    if (context.isWide) {
      return SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            RTCVideoView(
              remoteStream.videoRenderer,
              filterQuality: FilterQuality.none,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
            Positioned(
                top: 20,
                right: 24,
                child: EngagementProgress(engagement: engagement))

            // Positioned(
            //   bottom: 20,
            //     right: 24,
            //     child: Text(remoteStream.publisherName!))
          ],
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: RTCVideoView(
                remoteStream.videoRenderer,
                filterQuality: FilterQuality.none,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: EngagementProgress(engagement: engagement)),
          ],
        ),
      ),
    );

    return SizedBox(
      height: height,
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            RTCVideoView(
              remoteStream.videoRenderer,
              filterQuality: FilterQuality.none,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),

            if (context.isWide)
              Positioned(
                  top: 20,
                  right: 24,
                  child: EngagementProgress(engagement: engagement))
            else
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: EngagementProgress(engagement: engagement)),
            // Positioned(
            //   bottom: 20,
            //     right: 24,
            //     child: Text(remoteStream.publisherName!))
          ],
        ),
      ),
    );
  }
}
