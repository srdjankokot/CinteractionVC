import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/extension/color.dart';
import '../../../../../core/ui/images/image.dart';
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
                  replacement:
                      Center(child: UserImage.large([remoteStream.getUserImageDTO()]))

                  // Center(
                  //     child: CircleAvatar(
                  //       backgroundColor:
                  //       ([...ColorConstants.kStateColors]..shuffle()).first,
                  //       radius: [width, height].reduce(min) / 4,
                  //       child: Text(remoteStream.publisherName.getInitials(),
                  //           style: context.primaryTextTheme.titleLarge?.copyWith(
                  //               fontSize: [width, height].reduce(min) / 8,
                  //               fontWeight: FontWeight.bold)),
                  //     )
                  // )

                  ,
                  child: RTCVideoView(
                    remoteStream.videoRenderer,
                    placeholderBuilder: (context) {
                      return Center(
                          child: CircleAvatar(
                            backgroundColor: ColorUtil.getColorScheme(context).primaryFixed,
                            radius: [width, height].reduce(min) / 4,
                            child: Text(remoteStream.publisherName.getInitials(),
                                style: context.primaryTextTheme.titleLarge?.copyWith(
                                    fontSize: [width, height].reduce(min) / 8,
                                    fontWeight: FontWeight.bold)),
                          )

                        // Text("Video Paused By ${remoteStream.publisherName!}",
                        //     style: const TextStyle(color: ColorUtil.getColorScheme(context).surface)),
                      );
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
                        color: remoteStream.isTalking == true? ColorUtil.getColorScheme(context).error : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                ),

              ],
            ),
            // Text('${remoteStream.videoRenderer.videoWidth}:${remoteStream.videoRenderer.videoHeight}'),
            // Positioned(
            //     top: 20,
            //     right: 24,
            //     child: Row(
            //       children: [
            //         Visibility(
            //           visible: width > 200,
            //           child: EngagementProgress(
            //               engagement: remoteStream.engagement ?? 0),
            //         ),
            //       ],
            //     )),


            Positioned(
                right: 0,
                child: Row(
                  children: [
                    // EngagementProgress(
                    //     engagement: remoteStream.engagement ?? 0),
                    PopupMenuButton<String>(
                      onSelected: (e) async {
                        switch (e) {
                          case 'Mute/UnMute':
                            context.read<ConferenceCubit>().muteByID(remoteStream.id);
                            break;
                          case 'Kick':
                            context.read<ConferenceCubit>().kick(remoteStream.id);
                            break;
                          case 'UnPublish':
                            context.read<ConferenceCubit>().unPublishById(remoteStream.id);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Mute/UnMute','Kick'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                )),

            Positioned(
                left: 10,
                top: 10,
                child: Text('${remoteStream.publisherName}', style: context.textTheme.displayLarge?.copyWith(color: ColorUtil.getColorScheme(context).surface),)),


            Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    Visibility(
                        visible: remoteStream.isAudioMuted == true,
                            child:
                            imageSVGAsset('icon_microphone_disabled') as Widget),

                    Visibility(
                        visible: remoteStream.isVideoMuted == true,
                            child:
                            imageSVGAsset('icon_video_recorder_disabled') as Widget),

                       Visibility(
                        visible: remoteStream.isHandUp == true,
                            child:  Icon(Icons.waving_hand_outlined, color: ColorUtil.getColorScheme(context).surface),
                       )
                  ],
                )
            ),


            // Visibility(
            //     visible: width < 200,
            //     child: Positioned.fill(
            //       bottom: 20,
            //       child: Align(
            //           alignment: Alignment.bottomCenter,
            //           child: EngagementProgress(
            //               engagement: remoteStream.engagement ?? 0)),
            //     )),

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
            side:  BorderSide(width: 2, color: ColorUtil.getColorScheme(context).surface),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Visibility(
                visible: remoteStream.isVideoMuted == false,
                replacement:
                Center(child: UserImage.large([remoteStream.getUserImageDTO()]))
                ,
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
                child: Text('${remoteStream.publisherName}', style: context.textTheme.displayLarge?.copyWith(color: ColorUtil.getColorScheme(context).surface),)),


            Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    Visibility(
                        visible: remoteStream.isAudioMuted == true,
                        child:
                        imageSVGAsset('icon_microphone_disabled') as Widget),

                    Visibility(
                        visible: remoteStream.isVideoMuted == true,
                        child:
                        imageSVGAsset('icon_video_recorder_disabled') as Widget),

                    Visibility(
                      visible: remoteStream.isHandUp == true,
                      child:  Icon(Icons.waving_hand_outlined, color: ColorUtil.getColorScheme(context).surface),
                    )
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
}