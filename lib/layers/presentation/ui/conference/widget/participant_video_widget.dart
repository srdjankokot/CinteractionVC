import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/ui/images/image.dart';
import '../../../../../core/ui/widget/engagement_progress.dart';
import '../../../../../core/util/util.dart';

class ParticipantVideoWidget extends StatelessWidget {
  const ParticipantVideoWidget(
      {super.key,
      required this.remoteStream,
      required this.height,
      required this.width,
      this.showEngagement = true});

  final StreamRenderer remoteStream;
  final double height;
  final double width;
  final bool? showEngagement;

  @override
  Widget build(BuildContext context) {
    var screenShare =
        remoteStream.publisherName.toLowerCase().contains('screenshare');
    if (context.isWide) {
      return SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Stack(
              children: [
                Visibility(
                  visible: remoteStream.isVideoMuted == false,
                  replacement: Center(
                      child: CircleAvatar(
                        backgroundColor:
                        ([...ColorConstants.kStateColors]..shuffle()).first,
                        radius: [width, height].reduce(min) / 4,
                        child: Text(remoteStream.publisherName.getInitials(),
                            style: context.primaryTextTheme.titleLarge?.copyWith(
                                fontSize: [width, height].reduce(min) / 8,
                                fontWeight: FontWeight.bold)),
                      )

                    // Text("Video Paused By ${remoteStream.publisherName!}",
                    //     style: const TextStyle(color: Colors.white)),
                  ),
                  child: RTCVideoView(
                    remoteStream.videoRenderer,
                    placeholderBuilder: (context) {
                      return Text('data');
                    },
                    filterQuality: FilterQuality.none,
                    objectFit: screenShare
                        ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                        : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: !screenShare,
                  ),
                ),

                // Border overlay (doesn't affect video size)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: remoteStream.isTalking == true? Colors.red : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                ),

              ],
            ),
            // Text('${remoteStream.videoRenderer.videoWidth}:${remoteStream.videoRenderer.videoHeight}'),
            Positioned(
                top: 20,
                right: 24,
                child: Row(
                  children: [
                    Visibility(
                      visible: width > 200,
                      child: EngagementProgress(
                          engagement: remoteStream.engagement ?? 0),
                    ),
                  ],
                )),



            Visibility(
                visible: remoteStream.isAudioMuted == true,
                child: Positioned(
                    bottom: 50,
                    left: 24,
                    child:
                        imageSVGAsset('icon_microphone_disabled') as Widget)),
            Visibility(
                visible: width < 200,
                child: Positioned.fill(
                  bottom: 20,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: EngagementProgress(
                          engagement: remoteStream.engagement ?? 0)),
                )),
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
              child: Visibility(
                visible: remoteStream.isVideoMuted == false,
                replacement: Center(
                    child: CircleAvatar(
                  backgroundColor:
                      ([...ColorConstants.kStateColors]..shuffle()).first,
                  radius: [width, height].reduce(min) / 4,
                  child: Text(remoteStream.publisherName.getInitials(),
                      style: context.primaryTextTheme.titleLarge?.copyWith(
                          fontSize: [width, height].reduce(min) / 8,
                          fontWeight: FontWeight.bold)),
                )

                    // Text("Video Paused By ${remoteStream.publisherName!}",
                    //     style: const TextStyle(color: Colors.white)),
                    ),
                child: RTCVideoView(
                  remoteStream.videoRenderer,
                  placeholderBuilder: (context) {
                    return Text('data');
                  },
                  filterQuality: FilterQuality.none,
                  objectFit: screenShare
                      ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                      : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: !screenShare,
                ),
              ),
            ),
            Positioned(
                right: 0,
                child: Row(
                  children: [
                    EngagementProgress(
                        engagement: remoteStream.engagement ?? 0),
                    PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return {'Kick', 'UnPublish'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
