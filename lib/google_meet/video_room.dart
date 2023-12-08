import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:flutter/src/widgets/navigator.dart' as navigator;

import '../conf.dart';
import '../util.dart';

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
    localVideoRenderer.mediaStream = await videoPlugin?.initializeMediaDevices(
        //         simulcastSendEncodings: [
        //   RTCRtpEncoding(
        //     active: true,
        //     rid: 'h',
        //     scalabilityMode: 'L1T2',
        //     maxBitrate: 2000000,
        //     numTemporalLayers: 0,
        //     minBitrate: 1000000,
        //   ),
        //   RTCRtpEncoding(
        //       active: true,
        //       rid: 'm',
        //       scalabilityMode: 'L1T2',
        //       maxBitrate: 1000000,
        //       scaleResolutionDownBy: 2),
        //   RTCRtpEncoding(
        //       active: true,
        //       rid: 'l',
        //       scalabilityMode: 'L1T2',
        //       maxBitrate: 524288,
        //       scaleResolutionDownBy: 2),
        // ],

        mediaConstraints: {
          'video': {
            'width': {'ideal': 1280},
            'height': {'ideal': 720}
          },
          'audio': true
        });
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


    await checkRoom();
  }

  checkRoom() async{
    var exist = await videoPlugin?.exists(room);
    JanusEvent event = JanusEvent.fromJson(exist);
    if (event.plugindata?.data['exists'] == true) {
      await joinPublisher();
    } else {
      await createRoom(room);
    }
  }

  createRoom(int roomId) async {
    var created = await videoPlugin?.createRoom(room);
    JanusEvent event = JanusEvent.fromJson(created);
    if(event.plugindata?.data['videoroom'] == 'created'){
      await joinPublisher();
    }
    else{
      debugPrint('error creating room');
    }
  }


  joinPublisher() async {
    await videoPlugin?.joinPublisher(room,
        displayName: displayName, id: myId, pin: "");
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
        (await videoPlugin.configure(
            bitrate: 3000000,
            sessionDescription: await videoPlugin.createOffer(
                audioRecv: false, videoRecv: false)));
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

      debugPrint(event.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //
      //   ],
      //   title: const Text('Cinteraction Virtual Conference'),
      // ),
      body: OrientationBuilder(builder: (context, orientation) {
        var col = 2;
        if (kIsWeb) {
          col = 7;
        } else if (Platform.isAndroid) {
          col = 2;
        }
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: col,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            itemCount: videoState.streamsToBeRendered.entries.length,
            itemBuilder: (BuildContext ctx, int index) {
              List<StreamRenderer> items = videoState
                  .streamsToBeRendered.entries
                  .map((e) => e.value)
                  .toList();
              // StreamRenderer remoteStream = items[index];
              return getRendererItem(items[index]);
            });
      }),

      bottomNavigationBar: Container(
        child: Row(
          children: [
            IconButton(
                icon: const Icon(
                  Icons.call_end,
                  color: Colors.red,
                ),
                onPressed: () async {
                  callEnd().then((value) => {Navigator.of(context).pop()});
                }),
            IconButton(
                icon: Icon(
                  !screenSharing ? Icons.screen_share : Icons.stop_screen_share,
                  color: Colors.green,
                ),
                onPressed: joined
                    ? () async {
                        if (screenSharing) {
                          await disposeScreenSharing();
                          return;
                        }
                        await screenShare();
                      }
                    : null),
            IconButton(
                icon: Icon(
                  audioEnabled ? Icons.mic : Icons.mic_off,
                  color: Colors.green,
                ),
                onPressed: joined
                    ? () async {
                        setState(() {
                          audioEnabled = !audioEnabled;
                        });
                        await mute(videoPlugin?.webRTCHandle?.peerConnection,
                            'audio', audioEnabled);
                        setState(() {
                          localVideoRenderer.isAudioMuted = !audioEnabled;
                        });
                      }
                    : null),
            IconButton(
                icon: Icon(
                  videoEnabled ? Icons.videocam : Icons.videocam_off,
                  color: Colors.green,
                ),
                onPressed: joined
                    ? () async {
                        setState(() {
                          videoEnabled = !videoEnabled;
                        });
                        await mute(videoPlugin?.webRTCHandle?.peerConnection,
                            'video', videoEnabled);
                      }
                    : null),
            IconButton(
                icon: const Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                ),
                onPressed: joined ? switchCamera : null)
          ],
        ),
      ),
    );
  }

  Widget getRendererItem(StreamRenderer remoteStream) {
    // return Container(
    //   decoration: const BoxDecoration(
    //       color: Colors.orangeAccent,
    //       borderRadius: BorderRadius.all(Radius.circular(15))),
    // );
    return Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.orangeAccent,
          border: Border.all(
              color: Colors.black, width: 2, style: BorderStyle.solid),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Stack(
          children: [
            Visibility(
              visible: remoteStream.isVideoMuted == false,
              replacement: Container(
                child: Center(
                  child: Text("Video Paused By ${remoteStream.publisherName!}",
                      style: const TextStyle(color: Colors.black)),
                ),
              ),
              child: Stack(children: [
                RTCVideoView(
                  remoteStream.videoRenderer,
                  filterQuality: FilterQuality.none,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
                Visibility(
                  visible: remoteStream.publisherId != myId.toString(),
                  child: PositionedDirectional(
                      top: 120,
                      start: 20,
                      child: ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) async {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0;
                                i < remoteStream.selectedQuality.length;
                                i++) {
                              remoteStream.selectedQuality[i] = i == index;
                            }
                          });
                          await remotePlugin?.send(data: {
                            'request': "configure",
                            'mid': remoteStream.mid,
                            'substream': index
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.red[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.red[200],
                        color: Colors.red[400],
                        constraints: const BoxConstraints(
                          minHeight: 20.0,
                          minWidth: 50.0,
                        ),
                        isSelected: remoteStream.selectedQuality,
                        children: const [
                          Text('Low'),
                          Text('Medium'),
                          Text('High')
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                      '${remoteStream.videoRenderer.videoWidth}X${remoteStream.videoRenderer.videoHeight}'),
                )
              ]),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(remoteStream.publisherName!),
                  Icon(remoteStream.isAudioMuted == true
                      ? Icons.mic_off
                      : Icons.mic),
                  IconButton(
                      onPressed: () async {
                        fullScreenDialog = await showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(10),
                                insetPadding: EdgeInsets.zero,
                                content: Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.zero,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: RTCVideoView(
                                          remoteStream.videoRenderer,
                                        ),
                                      )),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              navigator.Navigator.of(context)
                                                  .pop(fullScreenDialog);
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }));
                      },
                      icon: const Icon(Icons.fullscreen)),
                ],
              ),
            )
          ],
        ));
  }
}
