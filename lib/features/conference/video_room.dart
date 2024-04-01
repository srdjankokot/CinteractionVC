import 'dart:math';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/ui/widget/call_button_shape.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_cubit.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:janus_client/janus_client.dart';
import '../../core/ui/images/image.dart';
import '../../util.dart';

class VideoRoomPage extends StatelessWidget {


  const VideoRoomPage({super.key});

  // @override
  // State<VideoRoomPage> createState() => _VideoRoomPage();

  void _onConferenceState(BuildContext context, ConferenceState state) {
    if (state.isEnded) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // int _numberOfStream = 1;
    // bool _isGridLayout = true;
    //

    return BlocConsumer<ConferenceCubit, ConferenceState>(
        builder: (context, state) {
          if (state.isInitial) {
            return Container();
          }
          // if(state is ConferenceInProgress)
          //   {

          if (state.streamRenderers == null) {
            return Container();
          }

          if (state.streamRenderers!.entries.isEmpty) {
            return Container();
          }

          List<StreamRenderer> items = [];
          for (var i = 0; i < state.numberOfStreamsCopy; i++) {
            items.addAll(
                state.streamRenderers!.entries.map((e) => e.value).toList());
          }

          var subscribers = state.streamSubscribers?.toList();

          if (items.length > 2) {
            for (var remoteStream in items) {
              if (remoteStream.mid != null) {
                //index 0 is the lowest
                // context.read<ConferenceCubit>().changeSubstream(remoteStream.mid!, 0);
              }
            }
          }

          return Material(
            child: Center(
              child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: ColorConstants.kBlack3,
                  child: Builder(
                    builder: (context) {
                      if (context.isWide) {
                        return Stack(
                          children: [
                            getLayout(context, items, state.isGridLayout),
                            Positioned(
                                top: 20,
                                left: 20,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .increaseNumberOfCopies();
                                        }),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .decreaseNumberOfCopies();
                                        }),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.layers_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => {
                                              context
                                                  .read<ConferenceCubit>()
                                                  .changeLayout()
                                              // setState(() {
                                              //   _isGridLayout = !_isGridLayout;
                                              // })
                                            }),

                                    ElevatedButton(onPressed: (){
                                      context
                                          .read<ConferenceCubit>()
                                          .changeSubStream(ConfigureStreamQuality.HIGH);
                                    }, child: Text('High')),


                                    ElevatedButton(onPressed: (){
                                      context
                                          .read<ConferenceCubit>()
                                          .changeSubStream(ConfigureStreamQuality.MEDIUM);
                                    }, child: Text('Medium')),


                                    ElevatedButton(onPressed: (){
                                      context
                                          .read<ConferenceCubit>()
                                          .changeSubStream(ConfigureStreamQuality.LOW);
                                    }, child: Text('Low')),

                                  ],
                                )),
                            Positioned.fill(
                              bottom: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CallButtonShape(
                                      image: !state.audioMuted!
                                          ? imageSVGAsset('icon_microphone')
                                              as Widget
                                          : imageSVGAsset(
                                                  'icon_microphone_disabled')
                                              as Widget,
                                      onClickAction: () async {
                                        await context
                                            .read<ConferenceCubit>()
                                            .audioMute();
                                        // setState(() {
                                        //   audioEnabled = !audioEnabled;
                                        // });
                                        // await mute(videoPlugin?.webRTCHandle?.peerConnection, 'audio', audioEnabled);
                                        // setState(() {
                                        //   localVideoRenderer.isAudioMuted =
                                        //       !audioEnabled;
                                        // });
                                      }),
                                  const SizedBox(width: 20),
                                  CallButtonShape(
                                      image: !state.videoMuted!
                                          ? imageSVGAsset('icon_video_recorder')
                                              as Widget
                                          : imageSVGAsset(
                                                  'icon_video_recorder_disabled')
                                              as Widget,
                                      onClickAction: () async {
                                        await context
                                            .read<ConferenceCubit>()
                                            .videoMute();
                                        // setState(() {
                                        //   audioEnabled = !audioEnabled;
                                        // });
                                        // await mute(videoPlugin?.webRTCHandle?.peerConnection, 'audio', audioEnabled);
                                        // setState(() {
                                        //   localVideoRenderer.isAudioMuted =
                                        //       !audioEnabled;
                                        // });
                                      }),
                                  const SizedBox(width: 20),
                                  // CallButtonShape(
                                  //     image: imageSVGAsset('icon_arrow_square_up')
                                  //     as Widget,
                                  //     onClickAction: joined
                                  //         ? () async {
                                  //       // if (screenSharing) {
                                  //       //   await disposeScreenSharing();
                                  //       //   return;
                                  //       // }
                                  //       // await screenShare();
                                  //     }
                                  //         : null),
                                  // const SizedBox(width: 20),
                                  // CallButtonShape(
                                  //     image: imageSVGAsset('icon_user') as Widget,
                                  //     // onClickAction: joined ? switchCamera : null),
                                  //     onClickAction: joined ? null : null),
                                  // const SizedBox(width: 20),
                                  CallButtonShape(
                                    image:
                                        imageSVGAsset('icon_phone') as Widget,
                                    bgColor: ColorConstants.kPrimaryColor,
                                    onClickAction: () async {
                                      await context
                                          .read<ConferenceCubit>()
                                          .finishCall();
                                    },
                                  ),

                                  const SizedBox(width: 20),

                                  PopupMenuButton<String>(
                                  padding: const EdgeInsets.all(0),
                                    icon: Container(
                                      width: 53,
                                      height: 53,
                                      decoration: const ShapeDecoration(
                                        color: ColorConstants.kWhite30,
                                        shape:  OvalBorder(),
                                      ),
                                      child: const Icon(Icons.list),
                                    ),

                                    onOpened: () {
                                      context.read<ConferenceCubit>().getParticipants();
                                    },

                                    onSelected: (e) async {
                                      await context
                                          .read<
                                          ConferenceCubit>()
                                          .publishById(e);
                                    },

                                    itemBuilder: (BuildContext context) {
                                      return subscribers!.map((e) {
                                        return PopupMenuItem<String>(
                                          enabled: !e.publisher,
                                          value: e.id.toString(),
                                          child: Text(e.display),
                                        );
                                      }).toList();
                                    },
                                  ),

                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     context.read<ConferenceCubit>().publish();
                                  //   },
                                  //   child: Text('Publish'),
                                  //
                                  // ),
                                  //
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     context.read<ConferenceCubit>().unpublish();
                                  //   },
                                  //   child: Text('Unpublish'),

                                  // ),

                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     context.read<ConferenceCubit>().getParticipants();
                                  //   },
                                  //   child: Text('Get Paricipants'),

                                  // )
                                ],
                              ),
                            ),

                          ],
                        );
                      } else {
                        return SafeArea(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .increaseNumberOfCopies();
                                          // setState(() {
                                          //   _numberOfStream++;
                                          // })
                                        }),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .decreaseNumberOfCopies();

                                          // setState(() {
                                          //   _numberOfStream--;
                                          // })
                                        }),
                                    IconButton(
                                        icon:
                                            imageSVGAsset('icon_switch_camera')
                                                as Widget,
                                        onPressed: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .switchCamera();
                                        }),
                                  ],
                                ),
                                Expanded(
                                    child: getLayout(
                                        context, items, state.isGridLayout)),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ElevatedButton(
                                      //   onPressed: () {
                                      //     context.read<ConferenceCubit>().publish();
                                      //   },
                                      //   child: Text('Publish'),
                                      //
                                      // ),
                                      //
                                      // ElevatedButton(
                                      //   onPressed: () {
                                      //     context.read<ConferenceCubit>().unpublish();
                                      //   },
                                      //   child: Text('Unpublish'),
                                      //
                                      // ),
                                      CallButtonShape(
                                        image: imageSVGAsset('icon_phone')
                                            as Widget,
                                        bgColor: ColorConstants.kPrimaryColor,
                                        onClickAction: () async {
                                          await context
                                              .read<ConferenceCubit>()
                                              .finishCall();
                                        },
                                      ),

                                      const SizedBox(width: 20),
                                      CallButtonShape(
                                          image: !state.audioMuted!
                                              ? imageSVGAsset('icon_microphone')
                                                  as Widget
                                              : imageSVGAsset(
                                                      'icon_microphone_disabled')
                                                  as Widget,
                                          onClickAction: () async {
                                            await context
                                                .read<ConferenceCubit>()
                                                .audioMute();
                                          }),
                                      const SizedBox(width: 20),
                                      CallButtonShape(
                                          image: !state.videoMuted!
                                              ? imageSVGAsset(
                                                      'icon_video_recorder')
                                                  as Widget
                                              : imageSVGAsset(
                                                      'icon_video_recorder_disabled')
                                                  as Widget,
                                          onClickAction: () async {
                                            await context
                                                .read<ConferenceCubit>()
                                                .videoMute();
                                          }),
                                      // const SizedBox(width: 20),
                                      // CallButtonShape(
                                      //     image: imageSVGAsset('icon_arrow_square_up')
                                      //     as Widget,
                                      //     onClickAction: joined
                                      //         ? () async {
                                      //       // if (screenSharing) {
                                      //       //   await disposeScreenSharing();
                                      //       //   return;
                                      //       // }
                                      //       // await screenShare();
                                      //     }
                                      //         : null),
                                      const SizedBox(width: 20),
                                      // CallButtonShape(
                                      //     image: imageSVGAsset('three_dots') as Widget,
                                      //     // onClickAction: joined ? switchCamera : null),
                                      //     onClickAction: joined ? null : null),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  )),
            ),
          );
          // }
        },
        listener: _onConferenceState);
  }

  Widget getLayout(
      BuildContext context, List<StreamRenderer> items, bool isGrid) {
    var numberStream = items.length;
    var row = sqrt(numberStream).round();
    var col = ((numberStream) / row).ceil();

    var size = MediaQuery.of(context).size;
    // final double itemHeight = (size.height - kToolbarHeight - 24) / row;

    if (context.isWide) {
      if (isGrid) {
        // desktop grid layout
        final double itemHeight = (size.height) / row;
        final double itemWidth = size.width / col;

        return Wrap(
          runSpacing: 0,
          spacing: 0,
          alignment: WrapAlignment.center,
          children: items
              .map((e) => getRendererItem(
                  context, e, Random().nextInt(100), itemHeight, itemWidth))
              .toList(),
        );
      } else {
        //desktop list layout

        const double itemHeight = 89;
        const double itemWidth = 92;

        return Stack(
          children: [
            Container(
              child: getRendererItem(context, items.first,
                  Random().nextInt(100), double.maxFinite, double.maxFinite),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 55),
              child: SizedBox(
                width: 100,
                height: MediaQuery.of(context).size.height - 156,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(3),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: getRendererItem(context, items[index],
                          Random().nextInt(100), itemHeight, itemWidth),
                    );
                  },
                ),
              ),
            ),
          ],
        );
        return Container();
      }
    } else {
      final double itemWidth = size.width;
      //Mobile layout
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return getRendererItem(
                    context,
                    items[index],
                    Random().nextInt(100),
                    (constraints.minHeight) /
                        (items.length > 3 ? 3 : items.length),
                    itemWidth);
              });
        },
      );
    }

    return const Text("NO LAYOUT");
  }

  void handleClick(BuildContext context, String value, String id) {
    switch (value) {
      case 'Kick':
        context.read<ConferenceCubit>().kick(id);
        break;
      case 'UnPublish':
        context.read<ConferenceCubit>().unPublishById(id);
        break;
    }
  }

  Widget getRendererItem(BuildContext context, StreamRenderer remoteStream,
      int engagement, double height, double width) {
    // debugPrint('getRendererItem: ${remoteStream.publisherName!} $engagement');

    if (context.isWide) {
      return SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Visibility(
              visible: remoteStream.isVideoMuted == false,
              replacement: Center(
                child: Text("Video Paused By ${remoteStream.publisherName!}",
                    style: const TextStyle(color: Colors.white)),
              ),
              child: RTCVideoView(
                remoteStream.videoRenderer,
                filterQuality: FilterQuality.none,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),

            Text('${remoteStream.videoRenderer.videoWidth}:${remoteStream.videoRenderer.videoHeight}'),

            Positioned(
                top: 20,
                right: 24,
                child: Row(
                  children: [
                    EngagementProgress(engagement: engagement),
                    Visibility(
                      visible: remoteStream.publisherName != 'You',
                      child: PopupMenuButton<String>(
                        onSelected: (item) {
                          handleClick(context, item, remoteStream.id);
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Kick', 'UnPublish'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    )
                  ],
                )),

            // Positioned(
            //     top: 20,
            //     right: 24,
            //     child: EngagementProgress(engagement: engagement)),

            Positioned(
                bottom: 20,
                right: 24,
                child: Text(
                  remoteStream.publisherName!,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: Colors.white),
                )),

            Visibility(
                visible: remoteStream.isAudioMuted == true,
                child: Positioned(
                    bottom: 50,
                    left: 24,
                    child:
                        imageSVGAsset('icon_microphone_disabled') as Widget)),

            //
            // Positioned(
            //     bottom: 60,
            //     left: 24,
            //     child: ElevatedButton(
            //       onPressed: () {
            //         context.read<ConferenceCubit>().unPublishById(remoteStream.id);
            //       },
            //       child: const Text('UnPublish'),
            //
            //     ),),
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
              child: RTCVideoView(
                remoteStream.videoRenderer,
                filterQuality: FilterQuality.none,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),
            Positioned.fill(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    EngagementProgress(engagement: engagement),
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
