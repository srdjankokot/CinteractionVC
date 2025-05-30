import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../layers/data/dto/chat/chat_detail_dto.dart';
import '../../layers/presentation/ui/profile/ui/widget/user_image.dart';
import '../janus/janus_client.dart';

class StreamRenderer {
  RTCVideoRenderer videoRenderer = RTCVideoRenderer();
  MediaStream? mediaStream;
  String id;
  String? publisherId;
  String publisherName;
  int? engagement;
  int? drowsiness;
  String? audioMid;
  String? videoMid;
  bool? initialSet;
  bool? isAudioMuted;
  bool? isHandUp;
  String? imageUrl;
  // List<bool> selectedQuality = [false, false, true];
  bool? isVideoMuted;
  bool? isSharing;
  bool? isVideoFlowing;
  bool? mirrorVideo = false;
  ConfigureStreamQuality subStreamQuality = ConfigureStreamQuality.HIGH;
  // bool? isTalking;


  UserImageDto getUserImageDTO()
  {
    return UserImageDto(
        id: int.parse(publisherId??"0"),
        name: publisherName,
        imageUrl: imageUrl ?? ""
    );
  }
  
  
  Future<void> dispose() async {
    if(!isRendererDisposed(videoRenderer))
      {
        await stopAllTracks(mediaStream);
        videoRenderer.srcObject = null;
        await videoRenderer.dispose();
      }
  }

  Future<void> disposeVideo() async {
    if(!isRendererDisposed(videoRenderer))
    {
      await stopVideoTracks(mediaStream);
      videoRenderer.srcObject = null;
      await videoRenderer.dispose();
    }
  }


  bool? _isTalking;
  bool? get isTalking => _isTalking;
  DateTime? talkingStartTime = DateTime.now();

  set isTalking(bool? value) {
    if (value == true && _isTalking != true) {
      // it just switched to true — record time
      talkingStartTime = DateTime.now();
      // print("Talking started at: $talkingStartTime");
    }
    _isTalking = value;
  }




  bool isRendererDisposed(RTCVideoRenderer renderer) {
    return renderer.textureId == null;
  }

  StreamRenderer(this.id, this.publisherName);

  Future<void> init() async {

    print("init streamRenderer $id");


    mediaStream = await createLocalMediaStream('mediaStream_$id');
    isAudioMuted = false;
    isVideoMuted = false;
    isSharing = false;
    initialSet = false;
    isVideoFlowing = true;
    isTalking = false;
    isHandUp = false;
    videoRenderer = RTCVideoRenderer();
    await videoRenderer.initialize();
    videoRenderer.srcObject = mediaStream;
  }
}


class Publisher{
  int id;
  String displayName;
  List<PStream> streams;

  Publisher({
    required this.id,
    required this.displayName,
    required this.streams,
  });


  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      displayName: json['display'],
      streams: (json['streams'] as List)
          .map((stream) => PStream.fromJson(stream as Map<String, dynamic>))
          .toList(),
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'streams': streams.map((stream) => stream.toJson()).toList(),
  };

}

class PStream{
  String type;
  int minindex;
  String mid;
  String? codec;
  bool? fec;
  bool? talking;
  bool? moderated;
  bool? simulcast;

  PStream({
    required this.type,
    required this.minindex,
    required this.mid,
  });

  factory PStream.fromJson(Map<String, dynamic> json) {
    return PStream(
      type: json['type'],
      minindex: json['mindex'],
      mid: json['mid'],
    );
  }


  Map<String, dynamic> toJson() => {
    'type': type,
    'minindex': minindex,
    'mid': mid,
  };
}


class VideoRoomPluginStateManager {
  Map<String, StreamRenderer> streamsToBeRendered = {}; //streams sends to ui to be rendered
  Map<int, Publisher> feedIdToDisplayStreamsMap = {}; //store id, displayName, streams from publishers
  Map<dynamic, dynamic> feedIdToMidSubscriptionMap = {}; //feed id as a key, mid as a value
  Map<dynamic, dynamic> subStreamsToFeedIdMap = {}; //
  Map<int, int> lastSpeakingTimeMap = {};

  reset() {
    streamsToBeRendered.clear();
    feedIdToDisplayStreamsMap.clear();
    subStreamsToFeedIdMap.clear();
    feedIdToMidSubscriptionMap.clear();
  }
}