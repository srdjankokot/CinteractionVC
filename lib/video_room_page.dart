import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cinteraction_vc/janus_client/model/room_audio_mute_req.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cinteraction_vc/janus_client/janus_client_plugin.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:random_string/random_string.dart';
import 'conf.dart';
import 'package:http/http.dart' as http;

import 'image_data.dart';

class VideoRoomPage extends StatefulWidget {
  final String room;
  final String displayName;

  const VideoRoomPage(this.room, this.displayName, {Key key}) : super(key: key);

  @override
  _VideoRoomPage createState() => _VideoRoomPage(int.parse(room), displayName);
}

class _VideoRoomPage extends State<VideoRoomPage> {
  int room = 1234567;
  int maxRenderer = 3;
  String displayName = 'Srdjan';

  bool videoEnabled = true;
  bool audioEnabled = true;

  _VideoRoomPage(this.room, this.displayName);

  String pluginName = 'janus.plugin.videoroom';

  JanusSignal _janusSignal;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream _localStream;

  String opaqueId = 'videoroomtest-${randomString(12)}';
  Map<int, JanusConnection> peerConnectionMap = <int, JanusConnection>{};

  String dataMsg = "";

  int selfHandleId = -1;

  int _mypvtid;
  int _myid;

  Timer timer;

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    peerConnectionMap?.forEach((key, jc) => jc.disConnect());
    _localRenderer?.dispose();
    _localStream?.dispose();
    _janusSignal?.disconnect();
    _janusSignal = null;
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _janusSignal = JanusSignal.getInstance(
        url: url, apiSecret: apiSecret, withCredentials: withCredentials);
    // Customize janus callback event processing
    onMessage();
    _initRenderers();
    if (displayName == 'bot') {
      // sendEngagementPeriodically();
      timer = Timer.periodic(const Duration(seconds: 2),
          (Timer t) => sendEngagementPeriodically());
    }
  }

  /// Initialize view
  void _initRenderers() async {
    await _localRenderer.initialize();
    _localStream = await createStream();
    _localRenderer.srcObject = _localStream;
    /*
    * 1.connect websocket server，success
    * 2.janus create session, success
    * 3.janus attach plugin,success
    * 4.janus videoroom join
    * 5.janus createOffer createAnswer
    * 6.janus trickle ice
    */
    connect();
    createSession();
    setState(() {});
  }

  ///　janus signaling event processing
  void onMessage() {
    _janusSignal.notifyTalking = (feedId) => {debugPrint("$feedId")};

    _janusSignal.onMessage =
        (JanusHandle handle, Map plugin, Map jsep, JanusHandle feedHandle) {
      String videoroom = plugin['videoroom'];
      if (videoroom == 'joined') {
        handle.onJoined(handle);
        _mypvtid = plugin['private_id'];
        _myid = plugin['id'];
      }

      if (videoroom == 'event') {
        var peer = peerConnectionMap[plugin['id']];
        if (peer != null) {
          if (plugin['mid'] == '1') {
            //video
            peer.video = plugin['moderation'] == 'unmuted';
            peerConnectionMap[plugin['id']] = peer;
            setState(() {});
          } else if (plugin['mid'] == '0') {
            //audio
            peer.audio = plugin['moderation'] == 'unmuted';
            peerConnectionMap[plugin['id']] = peer;
            setState(() {});
          }
        }
      }

      List<dynamic> publishers = plugin['publishers'];

      if (publishers != null && publishers.isNotEmpty) {
        for (var publisher in publishers) {
          int feed = publisher['id'];
          String display = publisher['display'];

          debugPrint(
              'stop1====>${_janusSignal.sessionId}==$feed==$displayName===$display');
          if (_janusSignal.sessionId == feed && displayName == display) {
            debugPrint(
                'stop2====>${_janusSignal.sessionId}==$feed==$displayName===$display');
            continue;
          }

          _janusSignal.attach(
              plugin: pluginName,
              opaqueId: opaqueId,
              success: (Map<String, dynamic> data) {
                debugPrint('attach data: $data');

                Map<String, dynamic> body = {
                  "request": "join",
                  'room': room,
                  "ptype": "subscriber",
                  'feed': feed,
                  'data': true,
                };

                if (_mypvtid != null) {
                  body['private_id'] = _mypvtid;
                }
                _janusSignal.joinRoom(
                    data: data,
                    body: body,
                    feedId: feed,
                    display: display,
                    onRemoteJsep:
                        (JanusHandle handle, Map<String, dynamic> jsep) {
                      // Subscribe to remote media and request to add the remote stream to the local. After receiving the event callback, execute onRemoteJsep
                      subscriberHandleRemoteJsep(handle, jsep);
                    },
                    onLeaving: (
                      JanusHandle handle,
                    ) {
                      // Remove remote media
                      peerConnectionMap[handle.feedId]?.disConnect();
                      peerConnectionMap.remove(handle.feedId);
                      setState(() {});
                    });
              },
              error: (Map<String, dynamic> data) {});
        }
      }

      if (feedHandle != null) {
        feedHandle.onLeaving(feedHandle);
      }
      // jsep：sdp carried by event
      if (jsep != null) {
        handle.onRemoteJsep(handle, jsep);
      }
      return;
    };
  }

  /// Connect to websocket server
  void connect() async {
    _janusSignal.connect();
  }

  /// janus create
  /// janus attach
  /// join room

  void createSession() {
    _janusSignal.createSession(success: (Map<String, dynamic> data) {
      attachPlugin();
    }, error: (Map<String, dynamic> data) {
      debugPrint('createSession failed...');
    });
  }

  void attachPlugin() {
    _janusSignal.attach(
        plugin: pluginName,
        opaqueId: opaqueId,
        success: (Map<String, dynamic> attachData) {
          // this.joinRoom(data);
          checkRoom(attachData);
        },
        error: (Map<String, dynamic> data) {
          debugPrint('createSession failed...');
        });
  }

  /// Check does room already exist
  void checkRoom(Map<String, dynamic> attachData) {
    _janusSignal.videoRoomHandle(
        req: RoomReq(request: 'exists', room: room).toMap(),
        success: (data) {
          debugPrint('exists room=====>>>>>>$data');
          if (null != data['plugindata']['data'] &&
              data['plugindata']['data']['exists']) {
            listRoom();
            joinRoom(attachData);
          } else {
            createRoom(attachData);
          }
        },
        error: (data) {
          print('find room error========>$data');
        });
  }

  void listRoom() {
    _janusSignal.videoRoomHandle(
        req: RoomReq(request: 'list', room: room).toMap(),
        success: (data) {
          debugPrint('exists room=====>>>>>>$data');
        },
        error: (data) {
          print('find room error========>$data');
        });
  }

  void editBitrateToRoom() {
    _janusSignal.videoRoomHandle(
        req: RoomReq(
                request: 'edit',
                room: room,
                bitrate: 128000,
                publishers: 60,
                firFreq: 10)
            .toMapNew(),
        success: (data) {
          debugPrint('exists room=====>>>>>>$data');
          listRoom();
        },
        error: (data) {
          print('find room error========>$data');
        });
  }

  void changeVideoCodec() {
    _janusSignal.videoRoomHandle(
        req: RoomReq(
            request: 'edit',
            room: room,
            bitrate: 128000,
            publishers: 60,
            firFreq: 10)
            .toMapNew(),
        success: (data) {
          debugPrint('exists room=====>>>>>>$data');
          listRoom();
        },
        error: (data) {
          print('find room error========>$data');
        });
  }

  void createRoom(Map<String, dynamic> attachData) {
    _janusSignal.videoRoomHandle(
        req: RoomReq(
                request: 'create', room: room, description: 'this is my room')
            .toMap(),
        success: (data) {
          debugPrint('create room=====>>>>>>$data');
          joinRoom(attachData);
        },
        error: (data) {
          print('create room error========>$data');
        });
  }

  /// join room
  void joinRoom(Map<String, dynamic> data) {
    Map<String, dynamic> body = {
      "request": "join",
      "room": room,
      "ptype": "publisher",
      "display": displayName,
      'secret': '',
      'pin': ''
    };

    _janusSignal.joinRoom(
        data: data,
        body: body,
        display: displayName,
        onJoined: (handle) {
          //　createOffer
          onPublisherJoined(handle);
        },
        onRemoteJsep: (handle, jsep) {
          onPublisherRemoteJsep(handle, jsep);
        });
  }

  /// Create peer connection, associate media information, send sdp(createOffer)
  void onPublisherJoined(JanusHandle handle) async {
    selfHandleId = handle.handleId;
    _localStream ??= await createStream();
    JanusConnection jc = await createJanusConnection(handle: handle);
    debugPrint('selfHandleId====>$selfHandleId');
    // createOffer
    Map body = {
      "request": "configure",
      "audio": true,
      "video": true,
      "data": true
    };
    RTCSessionDescription sdp = await jc.createOffer();

    Map<String, dynamic> jsep = sdp.toMap();
    _janusSignal.sendMessage(handleId: handle.handleId, body: body, jsep: jsep);
  }

  /// Processing remote media information received by remote publishers
  /// Create Peer-to-Peer Links Associated Media Data sdp(createOffer)
  void onPublisherRemoteJsep(JanusHandle handle, Map jsep) {
    JanusConnection jc = peerConnectionMap[handle.feedId];
    jc.setRemoteDescription(jsep);
  }

  /// Observers process remote media information
  void subscriberHandleRemoteJsep(
      JanusHandle handle, Map<String, dynamic> jsep) async {
    _localStream ??= await createStream();
    JanusConnection jc = await createJanusConnection(handle: handle);
    jc.setRemoteDescription(jsep);

    RTCSessionDescription sdp = await jc.createAnswer();
    Map body = {"request": "start", "room": room};
    _janusSignal.sendMessage(
        handleId: handle.handleId, body: body, jsep: sdp.toMap());
  }

  /// Create peer connection
  Future<JanusConnection> createJanusConnection(
      {@required JanusHandle handle}) async {
    JanusConnection jc = JanusConnection(
        handleId: handle.handleId,
        iceServers: iceServers,
        display: handle.display);

    debugPrint(
        'Create peer connection===>${peerConnectionMap.length} ====${handle.handleId}');

    peerConnectionMap[handle.feedId] = jc;

    await jc.initConnection();

    // jc.addLocalStream(_localStream);
    jc.addLocalTrack(_localStream);
    jc.onDataChannel = (channel) {
      channel.onDataChannelState = (state) {
        debugPrint("on data channel ${state.name}");
      };

      channel.onMessage = (data) {
        debugPrint("on data channel ${data.text}");
        dataMsg = data.text;
        setState(() {});
      };
    };

    jc.onAddStream = (connection, stream) {
      if (stream.getVideoTracks().isNotEmpty) {
        connection.remoteStream = stream;
        connection.remoteRenderer.srcObject = stream;
        setState(() {});
      }
    };
    jc.onIceCandidate = (connection, candidate) {
      Map candidateMap =
          candidate != null ? candidate.toMap() : {"completed": true};
      _janusSignal.trickleCandidate(
          handleId: handle.handleId, candidate: candidateMap);
    };

    return jc;
  }

  /// Create local stream
  Future<MediaStream> createStream() async {
    // var constraints = navigator.mediaDevices.getSupportedConstraints();

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'width': {'max': 320},
          'height': {'max': 240},
          'frameRate': {'max': 15, 'min': 5},
        },
        'facingMode': 'user',
        'optional': [],
      }
      // "audio": true,
      // "video": {"width": "320", "height": "240"}
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    // MediaStream stream = await MediaDevices.getUserMedia(mediaConstraints); //deprecated
    return stream;
  }

  /// leave room
  void leave() {
    if (peerConnectionMap.length == 1) {
      _janusSignal.videoRoomHandle(
          req: RoomReq(request: 'destroy', room: room).toMap(),
          success: (data) {
            debugPrint('leave destroy room success====$data>');
            _janusSignal.sendMessage(
              handleId: selfHandleId,
              body: RoomLeaveReq().toMap(),
            );
          },
          error: (data) {
            debugPrint('leave destroy room ====$data>');
          });
    } else {
      _janusSignal.sendMessage(
        handleId: selfHandleId,
        body: RoomLeaveReq().toMap(),
      );
    }
    Navigator.of(context).pop();
  }

  void mute(bool muted, String mid) {
    _janusSignal.sendMessage(
        handleId: selfHandleId,
        body: RoomAudioMuteReq(mute: muted, id: _myid, room: room, mid: mid)
            .toMap());

    peerConnectionMap[_janusSignal.sessionId]
        .mute(mid == "1" ? "video" : "audio", muted);
  }

  // final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Engagement: $dataMsg'),
        // leading:
        // IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => {leave()},
        // ),
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        var col = 2;
        if (kIsWeb) {
          col = 7;
        } else if (Platform.isAndroid) {
          col = 2;
        }

        List<Widget> list = getListOfRenderWidgets(orientation);
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: col,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (BuildContext ctx, int index) {
              return list[index];
            });
      }),
      bottomNavigationBar: Row(
        children: [
          IconButton(
              icon: const Icon(
                Icons.call_end,
                color: Colors.red,
              ),
              onPressed: () async {
                leave();
              }),
          IconButton(
              icon: Icon(
                audioEnabled ? Icons.mic : Icons.mic_off,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  audioEnabled = !audioEnabled;
                });

                mute(!audioEnabled, "0");
              }),
          IconButton(
              icon: Icon(
                videoEnabled ? Icons.videocam_sharp : Icons.videocam_off,
                color: Colors.green,
              ),
              onPressed: () {
                videoEnabled = !videoEnabled;
                mute(!videoEnabled, "1");
                setState(() {});
              }),

          // SizedBox(
          //   height: 30,
          //   width: 500,
          //   child:   TextField(
          //     controller: messageController,
          //     textAlign: TextAlign.left,
          //     decoration: const InputDecoration(
          //       border: InputBorder.none,
          //       hintText: 'PLEASE ENTER YOUR MESSAGE',
          //       hintStyle: TextStyle(color: Colors.grey),
          //     ),
          //   ),
          // )
          // ,

          // IconButton(
          //     icon: const Icon(
          //       Icons.message,
          //       color: Colors.green,
          //     ),
          //     onPressed: () {
          //       peerConnectionMap[_janusSignal.sessionId].sendMessage(messageController.text);
          //     })
        ],
      ),
    );
  }

  Random random = Random();

  void sendEngagementPeriodically() async {

    // var value = random.nextDouble() * (1 - 0) + 0;
    // dataMsg = value.toStringAsFixed(2);
    // peerConnectionMap[_janusSignal.sessionId].sendMessage(dataMsg);
    //
    // setState(() {});

    callApi();
  }

  void callApi() async {
    var callId = random.nextInt(10000);

    List<ImageData> images = await getImagesFromStreams(callId);

    if (images.isNotEmpty) {
      var jsonImages = jsonEncode(images.map((e) => e.toJson()).toList());
        // debugPrint(jsonImages);


        String body = jsonEncode(<String, dynamic>{
          'images': jsonImages,
        });

        debugPrint(body);

      final response = await  http.post(
        Uri.parse('https://server.institutonline.ai:55622/engagement/rank'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 9|Ga1985vwcyNBISTL8qdZJAfsDg9JZlUYG3CBO8oo'
        },
        body: jsonEncode(ImageDataList(images)),
      );
      if (response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        // return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);


        Map valueMap = json.decode(response.body);
        debugPrint(valueMap.toString());
        // List<Engagement> posts = List<Engagement>.from(l.map((model)=> Engagement.fromJson(model)));

        double engagementSum = 0;

        List<dynamic> list = valueMap['engagements'];

        for(var value in list){
          debugPrint(value.toString());
          engagementSum += value["engagement_rank"];
        }

        dataMsg = (engagementSum / list.length).toStringAsFixed(2);
        peerConnectionMap[_janusSignal.sessionId].sendMessage(dataMsg);
        setState(() {});
        // Map valueMap = json.decode(response.body);
        // EngagementResponse engagementResponse = EngagementResponse.fromJson(valueMap);




      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.

        throw Exception('Failed to create album.');

      }
    }
  }

  Future<List<ImageData>> getImagesFromStreams(int callId) async {
    List<ImageData> list = [];
    for (var peerConnection in peerConnectionMap.entries) {
      if (_janusSignal.sessionId != peerConnection.key) {
        MediaStreamTrack track = peerConnection.value.remoteRenderer.srcObject
            .getVideoTracks()
            .first;
        final buffer = await track.captureFrame();
        Uint8List image = buffer.asUint8List();
        list = [...list, ImageData(callId, peerConnection.key, uint8ListTob64(image))];
      }
    }

    // if (list.isNotEmpty) {
    //   var jsonImages = jsonEncode(list.map((e) => e.toJson()).toList());
    //   debugPrint(jsonImages);
    // }

    return list;
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    // String header = "data:image/png;base64,";
    return base64String;
  }

  List<Widget> getListOfRenderWidgets(orientation) {
    List<Widget> list = List.empty();

    if (_localRenderer != null) {
      list = [
        ...list,
        _buildVideoWidget(
            orientation, _localRenderer, "Me", videoEnabled, audioEnabled)
      ];
    }

    for (var peerConnection in peerConnectionMap.entries) {
      // if (list.length <= maxRenderer) {
      if (_janusSignal.sessionId != peerConnection.key) {
        // for(int i = 0; i<20; i++)
        //   {
        list = [
          ...list,
          _buildVideoWidget(
              orientation,
              peerConnection.value.remoteRenderer,
              peerConnection.value.display,
              peerConnection.value.video,
              peerConnection.value.audio)
        ];
        // }
      }
      // } else {
      //   continue;
      // }
    }
    return list;
  }

  Widget _buildVideoWidget(orientation, RTCVideoRenderer renderer,
      String display, bool video, bool audio) {
    Uint8List image;

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
          color: Colors.orangeAccent,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Stack(
        children: [
          Center(
              child: video
                  ? RTCVideoView(
                      renderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : const Text('Video is disabled')),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(5),
                child:
                    Text(display, style: const TextStyle(color: Colors.white)),
              )),
          Positioned(
            top: 0,
            left: 0,
            child: TextButton(
                onPressed: () => getFrameFromStream(renderer),
                child: const Text("GET FRAME")),
          ),
          Positioned(
              bottom: 10,
              left: 0,
              child: Icon(
                !audio ? Icons.mic_off : Icons.mic,
                color: Colors.green,
              )),
          Positioned(
              bottom: 30,
              left: 0,
              child: Icon(
                !video ? Icons.videocam_off : Icons.videocam_sharp,
                color: Colors.green,
              ))
        ],
      ),
    );
  }

  Future<void> getFrameFromStream(RTCVideoRenderer renderer) async {
    MediaStreamTrack track = renderer.srcObject.getVideoTracks().first;
    final buffer = await track.captureFrame();
    Uint8List data = buffer.asUint8List();

    if (!mounted) return;
    showDialog(context: context, builder: (_) => ImageDialog(data));
  }

  Future<Uint8List> getFrame(RTCVideoRenderer renderer) async {
    MediaStreamTrack track = renderer.srcObject.getVideoTracks().first;
    final buffer = await track.captureFrame();
    Uint8List data = buffer.asUint8List();

    return data;
  }
}

class ImageDialog extends StatelessWidget {
  final Uint8List image;

  const ImageDialog(this.image, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Center(
            child: Image.memory(
      image,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    )));

    // Container(
    //   width: 200,
    //   height: 200,
    //   decoration: BoxDecoration(
    //       image: DecorationImage(image: image, fit: BoxFit.cover)),
    // ),
    // );
  }
}
