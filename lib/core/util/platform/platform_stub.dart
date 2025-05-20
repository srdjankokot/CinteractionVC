import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../assets/colors/Colors.dart';
import '../util.dart';

void redirectToDesktopApp() {
  // Do nothing or show alternative message
  print("Not on web, no redirection needed.");
}

void startMeetOnDesktop(int roomId)
{

}

Widget getVideoView(BuildContext context, RTCVideoRenderer renderer, bool mirror, double width, double height, String id, String publisherName)
{
  return RTCVideoView(
    renderer,
    placeholderBuilder: (context) {
      return Center(
          child: CircleAvatar(
            backgroundColor:
            ([...ColorConstants.kStateColors]..shuffle()).first,
            radius: [width, height].reduce(min) / 4,
            child: Text(publisherName.getInitials(),
                style: context.primaryTextTheme.titleLarge?.copyWith(
                    fontSize: [width, height].reduce(min) / 8,
                    fontWeight: FontWeight.bold)),
          )

        // Text("Video Paused By ${remoteStream.publisherName!}",
        //     style: const TextStyle(color: Colors.white)),
      );
    },
    filterQuality: FilterQuality.none,
    objectFit: mirror
        ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
        : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    mirror: !mirror,
  );
}


Future<ByteBuffer?> captureFrameFromVideo(StreamRenderer renderer) async {
  var image = await renderer.mediaStream
      ?.getVideoTracks()
      .first
      .captureFrame();

  return image;
}
