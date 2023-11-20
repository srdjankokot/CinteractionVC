import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cinteraction_vc/janus_client/janus_client_plugin.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:random_string/random_string.dart';
import 'conf.dart';

class VideoRoomPage extends StatefulWidget {
  final String room;
  final String displayName;

  const VideoRoomPage(this.room, this.displayName, {Key key}) : super(key: key);

  @override
  _VideoRoomPage createState() => _VideoRoomPage(int.parse(room), displayName);
}

class _VideoRoomPage extends State<VideoRoomPage> {
  int room = 1234567;
  String displayName = 'Srdjan';

  _VideoRoomPage(this.room, this.displayName);

  String pluginName = 'janus.plugin.videoroom';

  JanusSignal _janusSignal;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream _localStream;

  String opaqueId = 'videoroomtest-${randomString(12)}';
  Map<int, JanusConnection> peerConnectionMap = <int, JanusConnection>{};

  int selfHandleId = -1;

  int _mypvtid;

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _janusSignal = JanusSignal.getInstance(url: url, apiSecret: apiSecret, withCredentials: withCredentials);
    // Customize janus callback event processing
    onMessage();
    _initRenderers();
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
    _janusSignal.onMessage = (JanusHandle handle, Map plugin, Map jsep, JanusHandle feedHandle) {
      String videoroom = plugin['videoroom'];
      if (videoroom == 'joined') {
        handle.onJoined(handle);
        _mypvtid = plugin['private_id'];
      }

      List<dynamic> publishers = plugin['publishers'];
      if (publishers != null && publishers.isNotEmpty) {
        for (var publisher in publishers) {
          int feed = publisher['id'];
          String display = publisher['display'];

          debugPrint('stop1====>${_janusSignal.sessionId}==$feed==$displayName===$display');
          if (_janusSignal.sessionId == feed && displayName == display) {
            debugPrint('stop2====>${_janusSignal.sessionId}==$feed==$displayName===$display');
            continue;
          }

          _janusSignal.attach(
              plugin: pluginName,
              opaqueId: opaqueId,
              success: (Map<String, dynamic> data) {
                Map<String, dynamic> body = {
                  "request": "join",
                  'room': room,
                  "ptype": "subscriber",
                  'feed': feed
                };

                if (_mypvtid != null) {
                  body['private_id'] = _mypvtid;
                }
                _janusSignal.joinRoom(
                    data: data,
                    body: body,
                    feedId: feed,
                    display: display,
                    onRemoteJsep:(JanusHandle handle, Map<String, dynamic> jsep) {
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
            // listRoom();
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

  void createRoom(Map<String, dynamic> attachData) {
    _janusSignal.videoRoomHandle(
        req: RoomReq(request: 'create', room: room, description: 'this is my room').toMap(),
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
    Map body = {"request": "configure", "audio": true, "video": true};
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

    debugPrint( 'Create peer connection===>${peerConnectionMap.length} ====${handle.handleId}');

    peerConnectionMap[handle.feedId] = jc;
    await jc.initConnection();

    // jc.addLocalStream(_localStream);
    jc.addLocalTrack(_localStream);
    jc.onAddStream = (connection, stream) {
      if (stream.getVideoTracks().isNotEmpty) {
        connection.remoteStream = stream;
        connection.remoteRenderer.srcObject = stream;
        setState(() {});
      }
    };
    jc.onIceCandidate = (connection, candidate) {
      Map candidateMap = candidate != null ? candidate.toMap() : {"completed": true};
      _janusSignal.trickleCandidata(handleId: handle.handleId, candidate: candidateMap);
    };

    return jc;
  }

  /// Create local stream
  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '1280',
          // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinteraction VC"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {
            leave()
          },
        ),
        actions: [
          TextButton(onPressed: editBitrateToRoom, child: const Text("BitRate"))
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        var col = 2;
        if (kIsWeb) {
          col = 7;
        } else if (Platform.isAndroid) {
          col = 2;
        }

        var keys = peerConnectionMap.keys.toList();

        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: col,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            itemCount: peerConnectionMap.length,
            itemBuilder: (BuildContext ctx, int index) {
              var value = peerConnectionMap[keys[index]];
              if (keys[index] != _janusSignal.sessionId) {
                return _buildVideoWidget(orientation, value.remoteRenderer, value.display);
              }

              return _buildVideoWidget(
                  orientation, _localRenderer, displayName);
            });

      }),
    );
  }


  Widget _buildVideoWidget(
      orientation, RTCVideoRenderer renderer, String display) {
    return Container(
      color: Colors.orangeAccent,
      margin: const EdgeInsets.all(5.0),
      child: Center(
        child: RTCVideoView(renderer,
            filterQuality: FilterQuality.medium,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
      ),
    );
  }
}
