import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/core/util/platform/platform.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    var screenShare = remoteStream.publisherName.toLowerCase().contains('screenshare');
    if (context.isWide) {
      return SizedBox(
        height: height,
        width: width,
        child: LayoutBuilder(builder: (context, constraints) {
          final halfHeight = min(constraints.maxHeight, constraints.maxWidth)  / 3;

          int userId = remoteStream.getUserImageDTO().id;
          
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(2),
                child: Stack(
                  children: [
                    Visibility(
                        visible: remoteStream.isVideoMuted == false,
                        replacement: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.6,
                                colors: [
                                  ColorConstants.getShadedColor(userId, amount: 0.6),
                                  ColorConstants.getRandomColor(userId),
                                ],
                              ),

                              border: Border.all(
                                color: remoteStream.isTalking == true
                                    ? ColorConstants.kPrimaryColor
                                    : Colors.white, // Border color
                                width: 2.0, // Border thickness
                              ),
                            ),
                            child: Center(
                                child: UserImage.size([remoteStream.getUserImageDTO()], halfHeight))),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.6,
                                colors: [
                                  ColorConstants.getShadedColor(userId, amount: 0.6),
                                  ColorConstants.getRandomColor(userId),
                                ],
                              ),

                              border: Border.all(
                                color: remoteStream.isTalking == true
                                    ? Colors.red
                                    : Colors.white, // Border color
                                width: 2.0, // Border thickness
                              ),
                            ),
                            child: getVideoView(
                                context,
                                remoteStream.videoRenderer,
                                screenShare,
                                width,
                                height,
                                remoteStream.id,
                                remoteStream.publisherName))),
                  ],
                ),
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
              Positioned(
                  left: 10,
                  top: 10,
                  child: Text(
                    '${remoteStream.publisherName}',
                    style: context.textTheme.displayLarge
                        ?.copyWith(color: Colors.white),
                  )),
              Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Visibility(
                          visible: remoteStream.isAudioMuted == true,
                          child: imageSVGAsset('icon_microphone_disabled')
                              as Widget),
                      Visibility(
                          visible: remoteStream.isVideoMuted == true,
                          child: imageSVGAsset('icon_video_recorder_disabled')
                              as Widget),
                      Visibility(
                        visible: remoteStream.isHandUp == true,
                        child: const Icon(Icons.waving_hand_outlined,
                            color: Colors.white),
                      )
                    ],
                  )),
            ],
          );
        }),
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
                    child: UserImage.large([remoteStream.getUserImageDTO()])),
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
            // Positioned(
            //     right: 0,
            //     child: Row(
            //       children: [
            //         EngagementProgress(
            //             engagement: remoteStream.engagement ?? 0),
            //         PopupMenuButton<String>(
            //           onSelected: (e) async {
            //             switch (e) {
            //               case 'Kick':
            //                 context.read<ConferenceCubit>().kick(remoteStream.id);
            //                 break;
            //               case 'UnPublish':
            //                 context.read<ConferenceCubit>().unPublishById(remoteStream.id);
            //                 break;
            //             }
            //           },
            //           itemBuilder: (BuildContext context) {
            //             return {'Kick', 'UnPublish'}.map((String choice) {
            //               return PopupMenuItem<String>(
            //                 value: choice,
            //                 child: Text(choice),
            //               );
            //             }).toList();
            //           },
            //         ),
            //       ],
            //     )),

            Positioned(
                left: 10,
                top: 10,
                child: Text(
                  '${remoteStream.publisherName}',
                  style: context.textTheme.displayLarge
                      ?.copyWith(color: Colors.white),
                )),

            Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    Visibility(
                        visible: remoteStream.isAudioMuted == true,
                        child: imageSVGAsset('icon_microphone_disabled')
                            as Widget),
                    Visibility(
                        visible: remoteStream.isVideoMuted == true,
                        child: imageSVGAsset('icon_video_recorder_disabled')
                            as Widget),
                    Visibility(
                      visible: remoteStream.isHandUp == true,
                      child: const Icon(Icons.waving_hand_outlined,
                          color: Colors.white),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
