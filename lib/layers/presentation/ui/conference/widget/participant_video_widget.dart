import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/util/platform/platform.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/user_avatar_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/ui/images/image.dart';
import '../../../../../core/ui/widget/call_button_shape.dart';
import '../../../../../core/ui/widget/engagement_progress.dart';
import '../../../../../core/util/util.dart';
import '../../../cubit/conference/conference_cubit.dart';

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
          final halfHeight =
              min(constraints.maxHeight, constraints.maxWidth) / 3;

          int userId = remoteStream.getUserImageDTO().id;

          var isPortrait = remoteStream.videoRenderer.videoHeight >
              remoteStream.videoRenderer.videoWidth;

          Widget userAvatar = getUserAvatar(userId, halfHeight, remoteStream);
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                child: Stack(children: [
                  Stack(
                    children: [
                      getVideoView(
                          context,
                          remoteStream.videoRenderer,
                          screenShare,
                          width,
                          height,
                          remoteStream.id,
                          remoteStream.publisherName,
                          userAvatar),
                      Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: remoteStream.isTalking == true
                                  ? Colors.white
                                  : Colors.transparent, // Border color
                              width: remoteStream.isTalking == true
                                  ? 2.0
                                  : 0.0, // Border thickness
                            ),
                            color: Colors.transparent,
                          ))
                    ],
                  ),

                  if ((remoteStream.isVideoMuted == true) && !screenShare)
                    userAvatar,

                  if (remoteStream.bitrateIsOk == false &&
                      remoteStream.isVideoMuted == false &&
                      remoteStream.lastFrameBytes != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                                height: double.maxFinite,
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: remoteStream.isTalking == true
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: remoteStream.isTalking == true
                                        ? 2.0
                                        : 0.0,
                                  ),
                                ),
                                child: (!screenShare)
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..scale(-1.0, 1.0, 1.0),
                                        // Mirror horizontally
                                        child: Image.memory(
                                          remoteStream.lastFrameBytes!,
                                          fit: isPortrait
                                              ? BoxFit.contain
                                              : BoxFit.cover,
                                        ),
                                      )
                                    : Image.memory(
                                        remoteStream.lastFrameBytes!,
                                        fit: BoxFit.contain,
                                      )),
                            Positioned(
                              child: Container(
                                width: 20,
                                height: 20,
                                color: Colors.green,
                              ),
                            )
                          ],
                        ))
                ]),
              ),
              // Text('${remoteStream.videoRenderer.videoWidth}:${remoteStream.videoRenderer.videoHeight}'),
              Positioned(
                  top: 20,
                  right: 24,
                  child: Row(
                    children: [
                      Visibility(
                          visible: width > 200 && showEngagement!,
                          child: Column(
                            spacing: 5,
                            children: [
                              EngagementProgress(
                                  engagement: remoteStream.engagement ?? 0),

                              // EngagementProgress(
                              //     engagement: remoteStream.drowsiness ?? 0)
                            ],
                          )),
                    ],
                  )),

              Positioned(
                  left: 24,
                  top: 20,
                  child: Text(
                    '${remoteStream.publisherName}',
                    style: context.textTheme.displayLarge
                        ?.copyWith(color: Colors.white),
                  )),
              Positioned(
                  bottom: 20,
                  left: 24,
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
                      ),
                    ],
                  )),

              Positioned(
                  bottom: 20,
                  right: 24,
                  child: Visibility(
                    visible: remoteStream.isSharing == true,
                    child: CallButtonShape(
                        image:
                            const Icon(Icons.screen_share, color: Colors.white)
                                as Widget,
                        onClickAction: () async {
                          await context
                              .read<ConferenceCubit>()
                              .setShareScreenId(
                                  int.parse(remoteStream.publisherId!));
                        }),
                  ))
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
