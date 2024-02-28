import 'dart:math';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/ui/widget/call_button_shape.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_cubit.dart';
import 'package:cinteraction_vc/features/conference/bloc/conference_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/ui/images/image.dart';
import '../../util.dart';

class VideoRoomPage extends StatelessWidget {
  final int room;

  const VideoRoomPage({super.key, required this.room});

  // @override
  // State<VideoRoomPage> createState() => _VideoRoomPage();

  void _onConferenceState(BuildContext context, ConferenceState state) {
    if(state.isEnded){
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    // int _numberOfStream = 1;
    // bool _isGridLayout = true;
    //

    return BlocConsumer<ConferenceCubit, ConferenceState>(builder: (context, state){
      if(state.isInitial)
      {
        return Container();
      }
      // if(state is ConferenceInProgress)
      //   {

      if(state.streamRenderers == null)
        {
          return Container();
        }

      if (state.streamRenderers!.entries.isEmpty) {
        return Container();
      }

      List<StreamRenderer> items = [];
      for (var i = 0; i < state.numberOfStreamsCopy; i++) {
        items.addAll(state.streamRenderers!.entries.map((e) => e.value).toList());
      }

      if(items.length > 2)
      {
        for(var remoteStream in items)
          {
            if(remoteStream.mid !=null){
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
                                        await context.read<ConferenceCubit>().increaseNumberOfCopies();
                                    }),
                                IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {

                                  await context.read<ConferenceCubit>().decreaseNumberOfCopies();
                                    }),
                                IconButton(
                                    icon: const Icon(
                                      Icons.layers_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => {
                                       context.read<ConferenceCubit>().changeLayout()
                                      // setState(() {
                                      //   _isGridLayout = !_isGridLayout;
                                      // })
                                    })
                              ],
                            )),
                        Positioned.fill(
                          bottom: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CallButtonShape(
                                  image: !state.audioMuted! ? imageSVGAsset('icon_microphone') as Widget: imageSVGAsset('icon_microphone_disabled') as Widget,
                                  onClickAction: () async {
                                    await context.read<ConferenceCubit>().audioMute();
                                    // setState(() {
                                    //   audioEnabled = !audioEnabled;
                                    // });
                                    // await mute(videoPlugin?.webRTCHandle?.peerConnection, 'audio', audioEnabled);
                                    // setState(() {
                                    //   localVideoRenderer.isAudioMuted =
                                    //       !audioEnabled;
                                    // });
                                  }

                              ),
                              const SizedBox(width: 20),
                              CallButtonShape(
                                  image: !state.videoMuted! ? imageSVGAsset('icon_video_recorder') as Widget: imageSVGAsset('icon_video_recorder_disabled') as Widget,
                                  onClickAction: () async {
                                    await context.read<ConferenceCubit>().videoMute();
                                    // setState(() {
                                    //   audioEnabled = !audioEnabled;
                                    // });
                                    // await mute(videoPlugin?.webRTCHandle?.peerConnection, 'audio', audioEnabled);
                                    // setState(() {
                                    //   localVideoRenderer.isAudioMuted =
                                    //       !audioEnabled;
                                    // });
                                  }
                              ),
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
                                image: imageSVGAsset('icon_phone') as Widget,
                                bgColor: ColorConstants.kPrimaryColor,
                                onClickAction: () async {
                                  await context.read<ConferenceCubit>().finishCall();
                                },
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  context.read<ConferenceCubit>().publish();
                                },
                                child: Text('Publish'),

                              ),

                              ElevatedButton(
                                onPressed: () {
                                  context.read<ConferenceCubit>().unpublish();
                                },
                                child: Text('Unpublish'),

                              ),

                              ElevatedButton(
                                onPressed: () {
                                  context.read<ConferenceCubit>().getParticipants();
                                },
                                child: Text('Get Paricipants'),

                              )
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
                                    await context.read<ConferenceCubit>().increaseNumberOfCopies();
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
                                    await context.read<ConferenceCubit>().decreaseNumberOfCopies();

                                      // setState(() {
                                      //   _numberOfStream--;
                                      // })
                                    }),
                                IconButton(
                                    icon: imageSVGAsset('icon_switch_camera')
                                    as Widget,
                                    // onPressed: joined ? switchCamera : null),
                                    onPressed:  null),
                              ],
                            ),
                            Expanded(child: getLayout(context, items, state.isGridLayout)),
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 18.0, bottom: 18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // CallButtonShape(
                                  //     image: imageSVGAsset('icon_phone') as Widget,
                                  //     bgColor: ColorConstants.kPrimaryColor,
                                  //     // onClickAction: finishCall),
                                  //     onClickAction: null),
                                  const SizedBox(width: 20),
                                  // CallButtonShape(
                                  //     image: imageSVGAsset('icon_microphone')
                                  //     as Widget,
                                  //     onClickAction: joined
                                  //         ? () async {
                                  //       // setState(() {
                                  //       //   audioEnabled = !audioEnabled;
                                  //       // });
                                  //       // await mute(
                                  //       //     videoPlugin?.webRTCHandle
                                  //       //         ?.peerConnection,
                                  //       //     'audio',
                                  //       //     audioEnabled);
                                  //       // setState(() {
                                  //       //   localVideoRenderer.isAudioMuted =
                                  //       //       !audioEnabled;
                                  //       // });
                                  //     }
                                  //         : null),
                                  const SizedBox(width: 20),
                                  // CallButtonShape(
                                  //     image: imageSVGAsset('icon_video_recorder')
                                  //     as Widget,
                                  //     onClickAction: joined
                                  //         ? () async {
                                  //       // setState(() {
                                  //       //   videoEnabled = !videoEnabled;
                                  //       // });
                                  //       // await mute(
                                  //       //     videoPlugin?.webRTCHandle
                                  //       //         ?.peerConnection,
                                  //       //     'video',
                                  //       //     videoEnabled);
                                  //     }
                                  //         : null),
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


    }, listener: _onConferenceState);

  }

  Widget getLayout(BuildContext context, List<StreamRenderer> items, bool isGrid) {
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
              .map((e) => getRendererItem(context,
              e, Random().nextInt(100), itemHeight, itemWidth))
              .toList(),
        );
      } else {
        //desktop list layout

        const double itemHeight = 89;
        const double itemWidth = 92;

        return Stack(
          children: [
            Container(
              child: getRendererItem(context, items.first, Random().nextInt(100),
                  double.maxFinite, double.maxFinite),
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
                return getRendererItem(context,
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

  Widget getRendererItem(BuildContext context, StreamRenderer remoteStream, int engagement,
      double height, double width) {
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
                  child: Text("Video Paused By ${remoteStream.publisherName!}", style: const TextStyle(color: Colors.white)),
                ),
                child: RTCVideoView(
                  remoteStream.videoRenderer,
                  filterQuality: FilterQuality.none,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
              ),

              Positioned(
                  top: 20,
                  right: 24,
                  child: EngagementProgress(engagement: engagement)),

              Positioned(
                bottom: 20,
                  right: 24,
                  child: Text(remoteStream.publisherName!, style: context.textTheme.labelSmall?.copyWith(color: Colors.white),)),

              Visibility(
                visible: remoteStream.isAudioMuted == true,
                child:  Positioned(
                  bottom: 50,
                  left: 24,
                  child: imageSVGAsset('icon_microphone_disabled') as Widget)
              ),


              Positioned(
                  bottom: 20,
                  left: 24,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ConferenceCubit>().kick(remoteStream.id);
                    },
                    child: Text('Kick'),

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
              child: RTCVideoView(
                remoteStream.videoRenderer,
                filterQuality: FilterQuality.none,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: EngagementProgress(engagement: engagement)),

          ],
        ),
      ),
    );

  }
}