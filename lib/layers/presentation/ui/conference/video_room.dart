import 'dart:math';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/widget/call_button_shape.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/chat_details_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../core/io/network/models/data_channel_command.dart';
import '../../../../core/navigation/route.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/engagement_progress.dart';
import '../../../../core/util/util.dart';
import '../../cubit/app/app_cubit.dart';
import '../../cubit/app/app_state.dart';
import '../../cubit/conference/conference_cubit.dart';
import '../../cubit/conference/conference_state.dart';
import '../profile/ui/widget/user_image.dart';

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
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      AppRoute.home.pushReplacement(context);

      await context
          .read<
          AppCubit>()
          .changeUserStatus(UserStatus.online);
    }

    if (state.isCallStarted && state.chatId != null) {
      context.read<ChatCubit>().load(true, state.chatId ?? 0);

      await context
          .read<
          AppCubit>()
          .changeUserStatus(UserStatus.inTheCall);
    }

    if (state.toastMessage != null) {
      showTopOverlay(context, state.toastMessage!);
      context.read<ConferenceCubit>().clearToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    double chatContainedWidth = 400;
    final ScrollController chatController = ScrollController();


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
          List<StreamRenderer> contributors = [];
          List<StreamRenderer> contributorsHandUp = [];

          for (var i = 0; i < state.numberOfStreamsCopy; i++) {
            items.addAll(
                state.streamRenderers!.entries.map((e) => e.value).toList());
          }
          // var subscribers = state.streamSubscribers?.toList();
          contributors.addAll(
              state.streamSubscribers!.entries.map((e) => e.value).toList());
          contributorsHandUp.addAll(state.streamSubscribers!.entries
              .where((e) => e.value.isHandUp == true)
              .map((e) => e.value)
              .toList());

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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double expandedHeight = constraints.maxHeight;


                                                return Stack(
                                                  children: [
                                                    getLayout(
                                                        context,
                                                        items,
                                                        state.isGridLayout,
                                                        borderWidth,
                                                        expandedHeight,
                                                        state.showingParticipants ||
                                                            state.showingChat),

                                                    Positioned(
                                                      bottom: 20,
                                                      right: 24,
                                                      child: EngagementProgress(
                                                        engagement: state.avgEngagement ?? 0,
                                                        width: 266,
                                                        height: 28,
                                                      ),
                                                    ),
                                                  ],
                                                );

                                                return getLayout(
                                                    context,
                                                    items,
                                                    state.isGridLayout,
                                                    borderWidth,
                                                    expandedHeight,
                                                    state.showingParticipants ||
                                                        state.showingChat);
                                              },
                                            ),
                                          ),
                                          Visibility(
                                            visible: state.showingChat,
                                            child: getChatView(context, chatContainedWidth),
                                            // ),
                                          ),
                                          Visibility(
                                              visible: state.showingParticipants,
                                              child: getParticipantsView(context, chatContainedWidth, contributors, contributorsHandUp)
                                          ),

                                        ],
                                      ),
                                    ),
                                    Container(
                                        height: 80,
                                        color: ColorConstants.kBlack3,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: double.maxFinite,
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: double.maxFinite,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    CallButtonShape(
                                                        image: !state
                                                            .audioMuted!
                                                            ? imageSVGAsset(
                                                            'icon_microphone')
                                                        as Widget
                                                            : imageSVGAsset(
                                                            'icon_microphone_disabled')
                                                        as Widget,
                                                        onClickAction:
                                                            () async {
                                                          await context
                                                              .read<
                                                              ConferenceCubit>()
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
                                                        onClickAction:
                                                            () async {
                                                          await context
                                                              .read<
                                                              ConferenceCubit>()
                                                              .videoMute();
                                                        }),
                                                    const SizedBox(width: 20),
                                                    CallButtonShape(
                                                        image: imageSVGAsset(
                                                            'icon_arrow_square_up')
                                                        as Widget,
                                                        bgColor: state
                                                            .screenShared
                                                            ? ColorConstants
                                                            .kPrimaryColor
                                                            : ColorConstants
                                                            .kWhite30,
                                                        onClickAction:
                                                            () async {
                                                          if (state
                                                              .screenShared) {
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .shareScreen(
                                                                null);
                                                          } else {
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .shareScreen(
                                                                await navigator
                                                                    .mediaDevices
                                                                    .getDisplayMedia({
                                                                  'video': true,
                                                                  'audio': true
                                                                }));
                                                          }
                                                        }),
                                                    const SizedBox(width: 20),
                                                    CallButtonShape(
                                                        image: Icon(
                                                          state.handUp
                                                              ? Icons
                                                              .waving_hand_outlined
                                                              : Icons
                                                              .front_hand_outlined,
                                                          color: Colors.white,
                                                        ),
                                                        bgColor: ColorConstants
                                                            .kWhite30,
                                                        onClickAction:
                                                            () async {
                                                          await context
                                                              .read<
                                                              ConferenceCubit>()
                                                              .handUp();
                                                        }),
                                                    const SizedBox(width: 20),
                                                    CallButtonShape(
                                                      // image: state.recording ? const Icon(Icons.stop, size: 30, color: Colors.red): const  Icon(Icons.fiber_manual_record, size: 30, color: Colors.red),
                                                      image: state.recording ==
                                                          RecordingStatus
                                                              .notRecording
                                                          ? const Icon(
                                                          Icons
                                                              .fiber_manual_record,
                                                          size: 30,
                                                          color: Colors.red)
                                                          : state.recording ==
                                                          RecordingStatus
                                                              .loading
                                                          ? const CircularProgressIndicator(
                                                        strokeWidth:
                                                        2,
                                                        color: Colors
                                                            .white,
                                                      )
                                                          : const Icon(
                                                          Icons.stop,
                                                          size: 30,
                                                          color: Colors
                                                              .red),
                                                      onClickAction: () async {
                                                        await context
                                                            .read<
                                                            ConferenceCubit>()
                                                            .recordingMeet();
                                                      },
                                                    ),
                                                    const SizedBox(width: 20),
                                                    CallButtonShape(
                                                      image: imageSVGAsset(
                                                          'icon_phone')
                                                      as Widget,
                                                      bgColor: ColorConstants
                                                          .kPrimaryColor,
                                                      onClickAction: () async {
                                                        await context
                                                            .read<
                                                            ConferenceCubit>()
                                                            .finishCall();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: double.maxFinite,
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Stack(children: [
                                                        CallButtonShape(
                                                          image: const Icon(
                                                            Icons.group,
                                                            color: Colors.white,
                                                          ),
                                                          bgColor:
                                                          ColorConstants
                                                              .kPrimaryColor
                                                              .withOpacity(
                                                              0.4),
                                                          onClickAction:
                                                              () async {
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .toggleParticipantsWindow();
                                                          },
                                                        ),

                                                        Positioned(
                                                          right: 5,
                                                          top: 2,
                                                          child:
                                                          AnimatedOpacity(
                                                            opacity: 1,
                                                            duration:
                                                            const Duration(
                                                                milliseconds:
                                                                250),
                                                            child: Container(
                                                              padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  6,
                                                                  vertical:
                                                                  2),
                                                              decoration:
                                                              BoxDecoration(
                                                                color: Colors
                                                                    .redAccent,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    12),
                                                              ),
                                                              constraints:
                                                              const BoxConstraints(
                                                                minWidth: 20,
                                                                minHeight: 16,
                                                              ),
                                                              child: Text(
                                                                contributors
                                                                    .length
                                                                    .toString(),
                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                                style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )

                                                        // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                                        //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                                                      ]),
                                                      const SizedBox(width: 20),
                                                      Stack(children: [
                                                        CallButtonShape(
                                                          image: imageSVGAsset(
                                                              'icon_message')
                                                          as Widget,
                                                          bgColor:
                                                          ColorConstants
                                                              .kPrimaryColor
                                                              .withOpacity(
                                                              0.4),
                                                          onClickAction:
                                                              () async {
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .toggleChatWindow();
                                                          },
                                                        ),
                                                        BlocBuilder<ChatCubit,
                                                            ChatState>(
                                                          builder:
                                                              (context, state) {
                                                            final int unread = state
                                                                .unreadMessages;

                                                            if (showingChat ||
                                                                unread == 0) {
                                                              return const SizedBox
                                                                  .shrink();
                                                            }

                                                            return Positioned(
                                                              right: 5,
                                                              top: 2,
                                                              child:
                                                              AnimatedOpacity(
                                                                opacity: 1,
                                                                duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                    250),
                                                                child:
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                      6,
                                                                      vertical:
                                                                      2),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        12),
                                                                  ),
                                                                  constraints:
                                                                  const BoxConstraints(
                                                                    minWidth:
                                                                    20,
                                                                    minHeight:
                                                                    16,
                                                                  ),
                                                                  child: Text(
                                                                    unread > 99
                                                                        ? '99+'
                                                                        : unread
                                                                        .toString(),
                                                                    textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                    style:
                                                                    const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                      10,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                                    ]),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SafeArea(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                          child: Container(
                                              child: getLayout(
                                                  context,
                                                  items,
                                                  state.isGridLayout,
                                                  borderWidth,
                                                  0,
                                                  false))),
                                      Padding(
                                          padding: const EdgeInsets.all( 18.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              CallButtonShape(
                                                image: imageSVGAsset('icon_phone')
                                                as Widget,
                                                bgColor:
                                                ColorConstants.kPrimaryColor,
                                                onClickAction: () async {
                                                  await context
                                                      .read<ConferenceCubit>()
                                                      .finishCall();
                                                },
                                              ),
                                              const Spacer(),
                                              CallButtonShape(
                                                  image: !state.audioMuted
                                                      ? imageSVGAsset(
                                                      'icon_microphone')
                                                  as Widget
                                                      : imageSVGAsset(
                                                      'icon_microphone_disabled')
                                                  as Widget,
                                                  onClickAction: () async {
                                                    await context
                                                        .read<ConferenceCubit>()
                                                        .audioMute();
                                                  }),
                                              const Spacer(),
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
                                              const Spacer(),
                                              CallButtonShape(
                                                  image: imageSVGAsset(
                                                      'icon_switch_camera') as Widget,
                                                  onClickAction: () async {
                                                    await context
                                                        .read<ConferenceCubit>()
                                                        .switchCamera();
                                                  }),
                                              const Spacer(),

                                              BlocBuilder<ChatCubit,
                                                  ChatState>(
                                                builder:
                                                    (context, state) {
                                                  final int unread = state
                                                      .unreadMessages;

                                                  // if (showingChat ||
                                                  //     unread == 0) {
                                                  //   return const SizedBox
                                                  //       .shrink();
                                                  // }

                                                  return Stack(children: [
                                                    PopupMenuButton<String>(
                                                      iconColor: Colors.white,
                                                      icon: const Icon(Icons.more_vert),
                                                      onSelected: (e) async {
                                                        switch (e) {
                                                          case 'Chat':
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .toggleChatWindow();
                                                            break;
                                                          case 'Participants':
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .toggleParticipantsWindow();
                                                            break;
                                                          case 'HandUp':
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .handUp();
                                                            break;

                                                          case 'Switch Camera':
                                                            await context
                                                                .read<
                                                                ConferenceCubit>()
                                                                .switchCamera();
                                                            break;
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext context) {
                                                        return {'Chat','Participants', 'HandUp'}.map((String choice) {
                                                          return PopupMenuItem<String>(
                                                            value: choice,
                                                            child: choice=='Chat' ?
                                                            Row(children: [
                                                              Text(choice),
                                                              const SizedBox(width: 5,),
                                                              Visibility(
                                                                visible: unread > 0,
                                                                child:
                                                                AnimatedOpacity(
                                                                  opacity: 1,
                                                                  duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                      250),
                                                                  child:
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                        6,
                                                                        vertical:
                                                                        2),
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      color: Colors
                                                                          .redAccent,
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          12),
                                                                    ),
                                                                    constraints:
                                                                    const BoxConstraints(
                                                                      minWidth:
                                                                      20,
                                                                      minHeight:
                                                                      16,
                                                                    ),
                                                                    child: Text(
                                                                      unread > 99
                                                                          ? '99+'
                                                                          : unread
                                                                          .toString(),
                                                                      textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                      style:
                                                                      const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                        10,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]) :
                                                            Text(choice),
                                                          );
                                                        }).toList();
                                                      },
                                                    ),
                                                    Visibility(
                                                      visible: unread > 0,
                                                      child: Positioned(
                                                        right: 5,
                                                        top: 2,
                                                        child:
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration: const BoxDecoration(
                                                            color: ColorConstants.kPrimaryColor,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),

                                                    )
                                                    // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                                    //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                                                  ]);



                                                  return Positioned(
                                                    right: 5,
                                                    top: 2,
                                                    child:
                                                    AnimatedOpacity(
                                                      opacity: 1,
                                                      duration:
                                                      const Duration(
                                                          milliseconds:
                                                          250),
                                                      child:
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            6,
                                                            vertical:
                                                            2),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: Colors
                                                              .redAccent,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                        ),
                                                        constraints:
                                                        const BoxConstraints(
                                                          minWidth:
                                                          20,
                                                          minHeight:
                                                          16,
                                                        ),
                                                        child: Text(
                                                          unread > 99
                                                              ? '99+'
                                                              : unread
                                                              .toString(),
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          style:
                                                          const TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontSize:
                                                            10,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),



                                            ],
                                          ))
                                    ],
                                  ),
                                  Visibility(
                                    visible: state.showingChat,
                                    child: getChatView(context, double.maxFinite),
                                    // ),
                                  ),
                                  Visibility(
                                      visible: state.showingParticipants,
                                      child: getParticipantsView(context, double.maxFinite, contributors, contributorsHandUp)
                                  ),
                                ],
                              ));
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

  Widget getLayout(
      BuildContext context,
      List<StreamRenderer> items,
      bool isGrid,
      double borderWidth,
      double parrentHeight,
      bool isSideWidowOpen) {
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
    var height =
        parrentHeight == 0 ? MediaQuery.of(context).size.height : parrentHeight;
    var width = MediaQuery.of(context).size.width - (isSideWidowOpen ? 400 : 0);
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

        final list = items.take(4).toList();

        final double itemWidth = (200 - borderWidth * 2);
        final double itemHeight = (itemWidth * 16 / 9) / list.length;
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
                  child: Wrap(
                    runSpacing: 0,
                    spacing: 0,
                    alignment: WrapAlignment.center,
                    children: list
                        .map((e) => ParticipantVideoWidget(
                            remoteStream: e,
                            height: itemHeight,
                            width: itemWidth))
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



Widget getChatView(BuildContext context, double width)
{
  return Container(
    width: width,
    height: double.maxFinite,
    color: Colors.white,
    child: Padding(
      padding:
      const EdgeInsets.all(23.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chat messages',
                  style: context
                      .titleTheme
                      .titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(
                    Icons.close),
                onPressed: () {
                  context
                      .read<
                      ConferenceCubit>()
                      .toggleChatWindow();
                },
              )
            ],
          ),
          Expanded(
              child: BlocConsumer<
                  ChatCubit,
                  ChatState>(
                builder:
                    (context, state) {
                  return ChatDetailsWidget(
                      state);
                },
                listener: (BuildContext
                context,
                    ChatState state) {},
              )),
        ],
      ),
    ),
  );
}

Widget getParticipantsView(BuildContext context, double width, List<StreamRenderer> contributors, List<StreamRenderer> contributorsHandUp){
  return Container(
    width: width,
    height: double.maxFinite,
    color: Colors.white,
    child: Padding(
      padding:
      const EdgeInsets.all(23.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'IN THE MEETING',
                  style: context
                      .titleTheme
                      .titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(
                    Icons.close),
                onPressed: () {
                  context
                      .read<
                      ConferenceCubit>()
                      .toggleParticipantsWindow();
                },
              )
            ],
          ),
          Visibility(
            visible:
            contributorsHandUp
                .isNotEmpty,
            child: Text(
              'Raised hands',
              style: context
                  .titleTheme
                  .titleSmall,
            ),
          ),
          ...contributorsHandUp
              .map((contributor) {
            var name = contributor
                .publisherName;
            return Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .center,
              children: [
                UserImage.medium(
                  [
                    contributor
                        .getUserImageDTO()
                  ],
                ),
                const SizedBox(
                    width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        name,
                        style:
                        const TextStyle(
                          fontFamily:
                          'Montserrat',
                          fontSize:
                          16,
                          fontWeight:
                          FontWeight
                              .w500,
                          color: Colors
                              .black87,
                        ),
                        overflow:
                        TextOverflow
                            .ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          Text(
            'Contributors',
            style: context.titleTheme
                .titleSmall,
          ),
          Expanded(
              child: ListView.builder(
                itemCount:
                contributors.length,
                itemBuilder:
                    (context, index) {
                  var contributor =
                  contributors[index];
                  var name = contributor
                      .publisherName;

                  return Padding(
                    padding:
                    const EdgeInsets
                        .all(2.0),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .center,
                      children: [
                        UserImage.medium([
                          contributor
                              .getUserImageDTO()
                        ]),
                        const SizedBox(
                            width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                name,
                                style:
                                const TextStyle(
                                  fontFamily:
                                  'Montserrat',
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight.w500,
                                  color: Colors
                                      .black87,
                                ),
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                maxLines:
                                1,
                              ),
                            ],
                          ),
                        ),
                        CallButtonShape(
                            size: 35,
                            bgColor: !contributor.isAudioMuted!
                                ? ColorConstants
                                .kStateSuccess
                                : ColorConstants
                                .kPrimaryColor,
                            image: !contributor
                                .isAudioMuted!
                                ? imageSVGAsset(
                                'icon_microphone')
                            as Widget
                                : imageSVGAsset(
                                'icon_microphone_disabled')
                            as Widget,
                            onClickAction:
                                () async {
                              await context
                                  .read<
                                  ConferenceCubit>()
                                  .muteByID(
                                  contributor.id);
                            }),
                        const SizedBox(
                            width: 6),
                        TextButton(
                            onPressed:
                                () {
                              context
                                  .read<
                                  ConferenceCubit>()
                                  .kick(contributor
                                  .id);
                            },
                            child: Text(
                              "Kick",
                              style: context
                                  .textTheme
                                  .bodySmall,
                            ))
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
    ),
  );
}
