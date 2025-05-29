import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../../assets/colors/Colors.dart';

Widget rtcVideoWidget(BuildContext context, RTCVideoRenderer renderer, bool screenshare, double width, double height, String id, String publisherName)
{
  var isPortrait = renderer.videoHeight > renderer.videoWidth;

  return ClipRRect(
    borderRadius: BorderRadius.circular(17), // match this to parent’s radius
    child: RTCVideoView(
      renderer,
      placeholderBuilder: (context) {
        return Center(
          child: CircleAvatar(
            backgroundColor: ([...ColorConstants.kStateColors]..shuffle()).first,
            radius: [width, height].reduce(min) / 4,
            child: Text(
              publisherName.getInitials(),
              style: context.primaryTextTheme.titleLarge?.copyWith(
                fontSize: [width, height].reduce(min) / 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      filterQuality: FilterQuality.none,
      objectFit: (screenshare || isPortrait)
          ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
          : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: !screenshare,
    ),
  );

}
