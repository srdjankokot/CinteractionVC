import 'dart:io';
import 'dart:math';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/widget/call_button_shape.dart';
import 'package:cinteraction_vc/core/ui/widget/engagement_progress.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/chat_usecases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/chat_details_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/chat_message_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/navigation/route.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/util/util.dart';
import '../../cubit/conference/conference_cubit.dart';
import '../../cubit/conference/conference_state.dart';

class VideoRoomPage extends StatelessWidget {
   VideoRoomPage({super.key});

  OverlayEntry? _overlayEntry;
  final List<String> _messages = [];


  Widget _buildToast(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  void showTopOverlay(BuildContext context, String message) {
    _messages.add(message);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            bottom: 100,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _messages.map((msg) => _buildToast(msg)).toList(),
              ),
            ),
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }

    // Auto remove each message after delay
    Future.delayed(const Duration(seconds: 2)).then((_) {
      _messages.remove(message);
      if (_messages.isEmpty) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      } else {
        _overlayEntry?.markNeedsBuild(); // Update the list
      }
    });
  }

  void _onConferenceState(BuildContext context, ConferenceState state) async {
    if (state.error != null) {
      context.showSnackBarMessage(state.error ?? 'Error', isError: true);
    }

    if (state.isEnded) {
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        print("No route to pop.");
        AppRoute.home.pushReplacement(context);
      }
      AppRoute.home.pushReplacement(context);
    }

    if (state.isCallStarted && state.chatId != null) {
      context.read<ChatCubit>().load(true, state.chatId ?? 0);
    }

    if (state.toastMessage!=null) {

      showTopOverlay( context, state.toastMessage!);

      // OverlayEntry overlayEntry = OverlayEntry(
      //   builder: (context) => Positioned(
      //     right: 20,
      //     bottom: 100,
      //     child: Material(
      //       color: Colors.transparent,
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //         decoration: BoxDecoration(
      //           color: Colors.black87,
      //           borderRadius: BorderRadius.circular(8),
      //         ),
      //         child: Text(
      //           state.toastMessage!,
      //           style: const TextStyle(color: Colors.white),
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      //
      // Overlay.of(context).insert(overlayEntry);
      //
      // await Future.delayed(const Duration(milliseconds: 1500));
      // overlayEntry.remove();

      // context.showSnackBarMessage(
      //   state.toastMessage!,
      //   isError: false,
      // );

      // Clear the toast message
      context.read<ConferenceCubit>().clearToast();
    }
  }

  @override
  Widget build(BuildContext context) {



    double chatContainedWidth = 400;
    TextEditingController messageFieldController = TextEditingController();
    final ScrollController chatController = ScrollController();
    FocusNode messageFocusNode = FocusNode();






    return BlocConsumer<ConferenceCubit, ConferenceState>(
        builder: (context, state) {
          if (state.isInitial) {
            return Container();
          }

          if (state.streamRenderers == null) {
            return Container();
          }

          if (state.streamRenderers!.entries.isEmpty) {
            return Container();
          }

          if (state.messages != null) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (chatController.hasClients) {
                chatController.jumpTo(chatController.position.maxScrollExtent);
              }
            });
          }

          List<StreamRenderer> items = [];
          List<StreamRenderer> audioItems = [];
          for (var i = 0; i < state.numberOfStreamsCopy; i++) {

            items.addAll(state.streamRenderers!.entries.map((e) => e.value).toList());
            //   print(state.streamRenderers!.entries.last.value.mediaStream?.getTracks());
            // items.addAll(
            //   state.streamRenderers!.entries
            //       .where((e) => e.value.mediaStream?.getVideoTracks().isNotEmpty == true)
            //       .map((e) => e.value)
            //       .toList(),
            // );

              // print(items.length);

          }

          var subscribers = state.streamSubscribers?.toList();

          var borderWidth =
              state.recording == RecordingStatus.recording ? 3.0 : 0.0;

          bool showingChat = state.showingChat;

          return Scaffold(
            body: Material(
              child: Center(
                child: Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    // color: ColorConstants.kBlack3,
                    decoration: BoxDecoration(
                      color: ColorConstants.kBlack3, // Background color
                      border: Border.all(
                        color: ColorConstants.kPrimaryColor, // Border color
                        width: borderWidth, // Border width
                      ), // Rounded corners
                    ),
                    child: Builder(
                      builder: (context) {
                        if (context.isWide) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            double expandedHeight = constraints.maxHeight;
                                            return  getLayout(context, items, state.isGridLayout,
                                                borderWidth, expandedHeight);
                                          },
                                        ),
                                      ),



                                      Container(
                                        height: 80,
                                        color: ColorConstants.kBlack3,
                                        child:  Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                                  }),
                                              const SizedBox(width: 20),
                                              CallButtonShape(
                                                  image: !state.videoMuted
                                                      ? imageSVGAsset('icon_video_recorder')
                                                  as Widget
                                                      : imageSVGAsset(
                                                      'icon_video_recorder_disabled')
                                                  as Widget,
                                                  onClickAction: () async {
                                                    await context
                                                        .read<ConferenceCubit>()
                                                        .videoMute();
                                                  }),
                                              const SizedBox(width: 20),
                                              CallButtonShape(
                                                  image:
                                                  imageSVGAsset('icon_arrow_square_up')
                                                  as Widget,
                                                  bgColor: state.screenShared
                                                      ? ColorConstants.kPrimaryColor
                                                      : ColorConstants.kWhite30,
                                                  onClickAction: () async {
                                                    if (state.screenShared) {
                                                      await context
                                                          .read<ConferenceCubit>()
                                                          .shareScreen(null);
                                                    } else {
                                                      await context
                                                          .read<ConferenceCubit>()
                                                          .shareScreen(await navigator
                                                          .mediaDevices
                                                          .getDisplayMedia({
                                                        'video': true,
                                                        'audio': true
                                                      }));
                                                    }
                                                  }),

                                              const SizedBox(width: 20),

                                              Stack(children: [
                                                CallButtonShape(
                                                  image: imageSVGAsset('icon_message')
                                                  as Widget,
                                                  bgColor: ColorConstants.kPrimaryColor
                                                      .withOpacity(0.4),
                                                  onClickAction: () async {
                                                    await context
                                                        .read<ConferenceCubit>()
                                                        .toggleChatWindow();
                                                  },
                                                ),
                                                BlocBuilder<ChatCubit, ChatState>(
                                                  builder: (context, state) {
                                                    final int unread = state.unreadMessages;

                                                    if (showingChat || unread == 0) {
                                                      return const SizedBox.shrink();
                                                    }

                                                    return Positioned(
                                                      right: 5,
                                                      top: 2,
                                                      child: AnimatedOpacity(
                                                        opacity: 1,
                                                        duration: const Duration(
                                                            milliseconds: 250),
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.redAccent,
                                                            borderRadius:
                                                            BorderRadius.circular(12),
                                                          ),
                                                          constraints: const BoxConstraints(
                                                            minWidth: 20,
                                                            minHeight: 16,
                                                          ),
                                                          child: Text(
                                                            unread > 99
                                                                ? '99+'
                                                                : unread.toString(),
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )

                                                // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                                //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                                              ]),
                                              const SizedBox(width: 20),
                                              // ElevatedButton(
                                              //     onPressed: () async {
                                              //       await context.read<ConferenceCubit>().recordingMeet();
                                              //     },
                                              //
                                              //     child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
                                              //     transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                              //     child:
                                              //
                                              //
                                              //
                                              //       ,
                                              //     )
                                              //
                                              // )

                                              CallButtonShape(
                                                // image: state.recording ? const Icon(Icons.stop, size: 30, color: Colors.red): const  Icon(Icons.fiber_manual_record, size: 30, color: Colors.red),
                                                image: state.recording ==
                                                    RecordingStatus.notRecording
                                                    ? const Icon(Icons.fiber_manual_record,
                                                    size: 30, color: Colors.red)
                                                    : state.recording ==
                                                    RecordingStatus.loading
                                                    ? const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                )
                                                    : const Icon(Icons.stop,
                                                    size: 30, color: Colors.red),
                                                onClickAction: () async {
                                                  await context
                                                      .read<ConferenceCubit>()
                                                      .recordingMeet();
                                                },
                                              ),

                                              const SizedBox(width: 20),
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

                                              // const SizedBox(width: 20),

                                              // CallButtonShape(
                                              //     image: state.engagementEnabled
                                              //         ? const Icon(Icons.image)
                                              //         : const Icon(Icons.image_not_supported),
                                              //     onClickAction: () async {
                                              //       await context
                                              //           .read<ConferenceCubit>()
                                              //           .toggleEngagement();
                                              //     }),
                                              //

                                              const SizedBox(width: 20),

                                    PopupMenuButton<String>(
                                      padding: const EdgeInsets.all(0),
                                      icon: Container(
                                        width: 53,
                                        height: 53,
                                        decoration: const ShapeDecoration(
                                          color: ColorConstants.kWhite30,
                                          shape: OvalBorder(),
                                        ),
                                        child: const Icon(Icons.list),
                                      ),
                                      onOpened: () {
                                        context
                                            .read<ConferenceCubit>()
                                            .getParticipants();
                                      },
                                      onSelected: (e) async {
                                        await context
                                            .read<ConferenceCubit>()
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

                                              // CallButtonShape(
                                              //     image: imageSVGAsset('icon_user') as Widget,
                                              //     // onClickAction: joined ? switchCamera : null),
                                              //     onClickAction: joined ? null : null),
                                              // const SizedBox(width: 20),

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
                                  ),
                                ),
                              // Positioned(
                              //   bottom: 20,
                              //   right: 24,
                              //   child: EngagementProgress(
                              //     engagement: state.avgEngagement ?? 0,
                              //     width: 266,
                              //     height: 28,
                              //   ),
                              // ),

                              AnimatedPositioned(
                                top: 0,
                                bottom: 0,
                                right:
                                    state.showingChat ? 0 : -chatContainedWidth,
                                duration: const Duration(milliseconds: 250),
                                child: Container(
                                  width: chatContainedWidth,
                                  height: double.maxFinite,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(23.0),
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Chat messages',
                                                style: context
                                                    .titleTheme.titleMedium,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                context
                                                    .read<ConferenceCubit>()
                                                    .toggleChatWindow();
                                              },
                                            )
                                          ],
                                        ),
                                        Expanded(
                                            child: BlocConsumer<ChatCubit,
                                                ChatState>(
                                          builder: (context, state) {
                                            return ChatDetailsWidget(state);
                                          },
                                          listener: (BuildContext context,
                                              ChatState state) {},
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        } else {
                          return SafeArea(
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        // IconButton(
                                        //     icon: const Icon(
                                        //       Icons.add,
                                        //       color: Colors.white,
                                        //     ),
                                        //     onPressed: () async {
                                        //       await context
                                        //           .read<ConferenceCubit>()
                                        //           .increaseNumberOfCopies();
                                        //       // setState(() {
                                        //       //   _numberOfStream++;
                                        //       // })
                                        //     }),
                                        // IconButton(
                                        //     icon: const Icon(
                                        //       Icons.remove,
                                        //       color: Colors.white,
                                        //     ),
                                        //     onPressed: () async {
                                        //       await context
                                        //           .read<ConferenceCubit>()
                                        //           .decreaseNumberOfCopies();
                                        //
                                        //       // setState(() {
                                        //       //   _numberOfStream--;
                                        //       // })
                                        //     }),
                                        IconButton(
                                            icon: imageSVGAsset(
                                                'icon_switch_camera') as Widget,
                                            onPressed: () async {
                                              await context
                                                  .read<ConferenceCubit>()
                                                  .switchCamera();
                                            }),
                                      ],
                                    ),
                                    Expanded(
                                      child: getLayout(context, items,
                                          state.isGridLayout, borderWidth, 0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18.0, bottom: 18.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              image: !state.audioMuted
                                                  ? imageSVGAsset(
                                                      'icon_microphone') as Widget
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
                                              image: !state.videoMuted
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

                                          Stack(children: [
                                            CallButtonShape(
                                              image: imageSVGAsset('icon_message')
                                                  as Widget,
                                              bgColor: ColorConstants
                                                  .kPrimaryColor
                                                  .withOpacity(0.4),
                                              onClickAction: () async {
                                                await context
                                                    .read<ConferenceCubit>()
                                                    .toggleChatWindow();
                                              },
                                            ),
                                            //         Expanded(
                                            //     child: BlocConsumer<ChatCubit,
                                            //         ChatState>(
                                            //   builder: (context, state) {
                                            //     return ChatDetailsWidget(state);
                                            //   },
                                            //   listener: (BuildContext context,
                                            //       ChatState state) {},
                                            // )),
                                            BlocConsumer<ChatCubit, ChatState>(
                                              listener: (context, state) {
                                                print(
                                                    'unreadChatMess: ${state.unreadMessages}');
                                              },
                                              builder: (context, state) {
                                                final unreadMessages = state
                                                    .chatMessages!
                                                    .where((msg) =>
                                                        msg.seen == false)
                                                    .toList();

                                                return Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: AnimatedOpacity(
                                                    opacity:
                                                        unreadMessages.isNotEmpty
                                                            ? 1
                                                            : 0,
                                                    duration: const Duration(
                                                        milliseconds: 250),
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration:
                                                          const ShapeDecoration(
                                                        color: Colors
                                                            .red, // crveni badge
                                                        shape: OvalBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                            // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                            //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                                          ]),

                                          // CallButtonShape(
                                          //     image: imageSVGAsset('three_dots') as Widget,
                                          //     // onClickAction: joined ? switchCamera : null),
                                          //     onClickAction: joined ? null : null),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedPositioned(
                                    bottom: state.showingChat
                                        ? 0
                                        : -MediaQuery.of(context).size.height *
                                            0.8,
                                    right: 0,
                                    left: 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: BlocConsumer<ChatCubit, ChatState>(
                                      builder: (context, state) {
                                        return ChatDetailsWidget(state);
                                      },
                                      listener: (BuildContext context,
                                          ChatState state) {},
                                    )

                                    // Container(
                                    //   width: double.maxFinite,
                                    //   height:
                                    //       MediaQuery.of(context).size.height * 0.8,
                                    //   color: Colors.white,
                                    //   child: Padding(
                                    //     padding: EdgeInsets.only(
                                    //         bottom: MediaQuery.of(context)
                                    //                 .viewInsets
                                    //                 .bottom +
                                    //             23,
                                    //         top: 23,
                                    //         right: 23,
                                    //         left: 23),
                                    //     child: Column(
                                    //       // crossAxisAlignment: CrossAxisAlignment.start,
                                    //       children: [
                                    //         Row(
                                    //           children: [
                                    //             Expanded(
                                    //               child: Text(
                                    //                 'Chat messages',
                                    //                 style: context
                                    //                     .titleTheme.titleMedium,
                                    //               ),
                                    //             ),
                                    //             IconButton(
                                    //               icon: const Icon(Icons.close),
                                    //               onPressed: () {
                                    //                 context
                                    //                     .read<ConferenceCubit>()
                                    //                     .toggleChatWindow();
                                    //               },
                                    //             )
                                    //           ],
                                    //         ),
                                    //         Expanded(
                                    //           child: Container(
                                    //             child: state.messages == null
                                    //                 ? const Center(
                                    //                     child: Text('No Messages'))
                                    //                 : ListView.builder(
                                    //                     controller: chatController,
                                    //                     itemCount:
                                    //                         state.messages?.length,
                                    //                     itemBuilder:
                                    //                         (BuildContext context,
                                    //                             int index) {
                                    //                       return VisibilityDetector(
                                    //                           key: Key(
                                    //                               index.toString()),
                                    //                           onVisibilityChanged:
                                    //                               (VisibilityInfo
                                    //                                   info) {
                                    //                             // print('${state.messages![int.parse('${(info.key as ValueKey).value}')]} (message seen)');
                                    //                             context
                                    //                                 .read<
                                    //                                     ConferenceCubit>()
                                    //                                 .chatMessageSeen(
                                    //                                     index);
                                    //                           },
                                    //                           child: ChatMessageWidget(
                                    //                               message: state
                                    //                                       .messages![
                                    //                                   index]));
                                    //                     },
                                    //                   ),
                                    //           ),
                                    //         ),
                                    //         const SizedBox(
                                    //           height: 5,
                                    //         ),
                                    //         Row(
                                    //           children: [
                                    //             Expanded(
                                    //               child: TextField(
                                    //                 textInputAction:
                                    //                     TextInputAction.go,
                                    //                 focusNode: messageFocusNode,
                                    //                 onSubmitted: (value) {
                                    //                   sendMessage();
                                    //                 },
                                    //                 controller:
                                    //                     messageFieldController,
                                    //                 decoration: InputDecoration(
                                    //                     hintText: "Send a message",
                                    //                     suffixIcon: IconButton(
                                    //                       onPressed: () {
                                    //                         sendMessage();
                                    //                       },
                                    //                       icon: imageSVGAsset(
                                    //                               'icon_send')
                                    //                           as Widget,
                                    //                     )),
                                    //               ),
                                    //             )
                                    //           ],
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    ),
                              ],
                            ),
                          );
                        }
                      },
                    )),
              ),
            ),
          );
          // }
        },
        listener: _onConferenceState);
  }

  Widget getLayout(BuildContext context, List<StreamRenderer> items,
      bool isGrid, double borderWidth, double parrentHeight) {
    StreamRenderer? screenshared;

    try {
      if (items.isNotEmpty) {
        for (var stream in items) {
          if (stream.publisherName.toLowerCase().contains('screenshare')) {
            screenshared = stream;
            items.remove(stream);
            break;
          }
        }
      }
    } on Exception catch (e) {
      print(e);
    }

    var numberStream = items.length;
    var row = sqrt(numberStream).round();
    var col = ((numberStream) / row).ceil();

    // var size = MediaQuery.of(context).size;
    // var size = MediaQuery.of(context).size;
    var height = parrentHeight == 0 ? MediaQuery.of(context).size.height : parrentHeight;
    var width = MediaQuery.of(context).size.width;
    // final double itemHeight = (size.height - kToolbarHeight - 24) / row;

    if (context.isWide) {
      // if (isGrid) {
      if (screenshared == null) {
        // desktop grid layout
        final double itemHeight = (height - borderWidth * 2) / row;
        final double itemWidth = (width - borderWidth * 2) / col;

        return Wrap(
          runSpacing: 0,
          spacing: 0,
          alignment: WrapAlignment.center,
          children: items
              .map((e) => ParticipantVideoWidget(
                  remoteStream: e, height: itemHeight, width: itemWidth))
              .toList(),
        );
      } else {
        //desktop list layout

        // const double itemHeight = 182;
        // const double itemWidth = 189;

        final list= items.take(4).toList();

        final double itemWidth = (200 - borderWidth * 2);
        final double itemHeight = (itemWidth * 16 / 9)/ list.length;
        // final double itemWidth = (200 - borderWidth * 2);

        return Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: ParticipantVideoWidget(
                    remoteStream: screenshared,
                    height: double.maxFinite,
                    width: double.maxFinite),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 30, left: 30),
              child: SizedBox(
                width: itemWidth + 20,
                height: MediaQuery.of(context).size.height - 156,
                child:
                Wrap(
                  runSpacing: 0,
                  spacing: 0,
                  alignment: WrapAlignment.center,
                  children: list
                      .map((e) => ParticipantVideoWidget(
                      remoteStream: e, height: itemHeight, width: itemWidth))
                      .toList(),
                )

                // ListView.builder(
                //   shrinkWrap: true,
                //   itemCount: items.length,
                //   itemBuilder: (context, index) {
                //     return Container(
                //       clipBehavior: Clip.hardEdge,
                //       margin: const EdgeInsets.all(3),
                //       decoration: ShapeDecoration(
                //         shape: RoundedRectangleBorder(
                //           side: const BorderSide(width: 2, color: Colors.white),
                //           borderRadius: BorderRadius.circular(6),
                //         ),
                //       ),
                //       child: ParticipantVideoWidget(
                //         remoteStream: items[index],
                //         height: itemHeight,
                //         width: itemWidth,
                //       ),
                //     );
                //   },
                // ),
              ),
            ),
          ],
        );
      }
    } else {
      final double itemWidth = width;
      //Mobile layout
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return ParticipantVideoWidget(
                    remoteStream: items[index],
                    height: (constraints.minHeight) /
                        (items.length > 3 ? 3 : items.length),
                    width: itemWidth);
              });
        },
      );
    }

    return const Text("NO LAYOUT");
  }

}
