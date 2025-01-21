import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/image.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/last_message_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_chat.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/chat_details_widget.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/user_list_view.dart';
import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import 'widget/chat_list_view.dart';
import '../conference/widget/chat_message_widget.dart';
import '../home/ui/widgets/home_item.dart';
import '../home/ui/widgets/join_popup.dart';
import '../home/ui/widgets/schedule_popup.dart';
import '../profile/ui/widget/user_image.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.getCurrentUser;

    final ScrollController chatController = ScrollController();
    TextEditingController messageFieldController = TextEditingController();

    FocusNode messageFocusNode = FocusNode();

    AudioPlayer audioPlayer = AudioPlayer();

    late DropzoneViewController controller;

    Future<void> onFileDropped(dynamic event) async {
      final name = await controller.getFilename(event);

      print(name);

      final bytes = await controller.getFileData(event);
      await context.read<ChatCubit>().sendFile(name.toString(), bytes);
      // You can process the file bytes as needed here
    }

    void playIncomingCallSound() async {
      // Play the sound
      try {
        await audioPlayer.setSource(AssetSource('discord_incoming_call.mp3'));
        audioPlayer.resume();
      } catch (e) {
        print('Error playing sound: $e'); // Log any errors
      }
    }

    void stopIncomingCallSound() async {
      await audioPlayer.stop();
    }

    Future<void> sendMessage(participiantId) async {
      await context
          .read<ChatCubit>()
          .sendMessage(messageFieldController.text, participiantId);
      messageFieldController.text = '';
    }

    AlertDialog? callDialog;
    AlertDialog? incomingDialog;

    makeCallDialog() async {
      callDialog = await showDialog<AlertDialog>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text("Calling..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context, rootNavigator: true)
                            .pop(incomingDialog);
                        // Navigator.of(context, rootNavigator: true).pop(callDialog);
                        // await publishVideo.hangup();
                        context.read<ChatCubit>().rejectCall();
                      },
                      child: const Text('Reject')),
                ],
              ),
            );
          });
    }

    Future<dynamic> showIncomingCallDialog(
        BuildContext context, String caller) async {
      playIncomingCallSound();

      return showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Incoming call from ${caller}'),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      context.read<ChatCubit>().answerCall();
                      Navigator.of(context).pop(incomingDialog);
                      stopIncomingCallSound();
                      // Navigator.of(context).pop(callDialog);
                    },
                    child: const Text('Answer')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)
                          .pop(incomingDialog);
                      context.read<ChatCubit>().rejectCall();
                      stopIncomingCallSound();
                    },
                    child: const Text('Reject')),
              ],
            );
          });
    }

    Future<void> displayJoinRoomPopup(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return const JoinPopup();
        },
      );
    }

    Future<void> displayAddScheduleMeetingPopup(BuildContext ctx) async {
      return showDialog(
        context: ctx,
        builder: (context) {
          return SchedulePopup(
            context: ctx,
          );
        },
      );
    }

    return BlocConsumer<ChatCubit, ChatState>(listener: (context, state) async {
      if (state.incomingCall ?? false) {
        // String callerName = "Caller Name"; // Replace with actual caller name
        await showIncomingCallDialog(context, state.caller!);
        return;
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(incomingDialog);
          stopIncomingCallSound();
        }
      }

      if (state.calling ?? false) {
        await makeCallDialog();
        return;
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(incomingDialog);
        }
      }
    }, builder: (context, state) {
      return Scaffold(
          body: Stack(
        children: [
          Row(
            children: [
              // First column
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: HomeTabItem.mobile(
                              image: const Image(
                                image: ImageAsset('stand.png'),
                                fit: BoxFit.fill,
                              ),
                              onClickAction: () {
                                context.pushNamed('meeting',
                                    pathParameters: {
                                      'roomId':
                                          Random().nextInt(999999).toString(),
                                    },
                                    extra: context.getCurrentUser?.name);
                              },
                              label: 'Start Meeting',
                              textStyle: context.textTheme.labelMedium,
                            ),
                          ),
                          Expanded(
                            child: HomeTabItem.mobile(
                                image: const Image(
                                  image: ImageAsset('add_user.png'),
                                ),
                                bgColor: ColorConstants.kStateSuccess,
                                onClickAction: () => {
                                      // AppRoute.meeting.push(context)
                                      displayJoinRoomPopup(context)
                                    },
                                label: 'Join',
                                textStyle: context.textTheme.labelMedium),
                          ),
                          Expanded(
                            child: HomeTabItem.mobile(
                                image: const Image(
                                  image: ImageAsset('calendar-date.png'),
                                ),
                                bgColor: ColorConstants.kStateInfo,
                                onClickAction: () async {
                                  displayAddScheduleMeetingPopup(context);
                                },
                                label: 'Schedule',
                                textStyle: context.textTheme.labelMedium),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: ListType.values.map((option) {
                          return Expanded(
                              child: ListTile(
                            titleAlignment: ListTileTitleAlignment.center,
                            title: Text(
                              option.name,
                              textAlign: TextAlign.center,
                            ),
                            onTap: () {
                              context.read<ChatCubit>().changeListType(option);
                            },
                            selected: state.listType == option,
                            selectedColor: ColorConstants.kPrimaryColor,
                          ));
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: state.listType == ListType.Chats
                          ? state.chats!.isNotEmpty
                              ? ChatsListView(state: state)
                              : const Center(
                                  child: Text('There is no chats'),
                                )
                          : UsersListView(state: state),
                    )
                  ],
                ),
              ),

              const VerticalDivider(
                color: Colors.grey, // Color of the divider
                thickness: 1, // Thickness of the divider
                width: 20, // Width of the space taken by the divider
              ),

              // Second column
              Expanded(
                flex: 2,
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(23.0),
                    child: () {
                      if (state.localStream != null) {
                        if (state.remoteStream == null) {
                          return ParticipantVideoWidget(
                              remoteStream: state.localStream!,
                              height: double.maxFinite,
                              width: double.maxFinite);
                        } else {
                          return Stack(
                            children: [
                              ParticipantVideoWidget(
                                  remoteStream: state.remoteStream!,
                                  height: double.maxFinite,
                                  width: double.maxFinite),
                              ParticipantVideoWidget(
                                  remoteStream: state.localStream!,
                                  height: 200,
                                  width: 200),
                              Positioned.fill(
                                bottom: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CallButtonShape(
                                        image: !state.audioMuted
                                            ? imageSVGAsset('icon_microphone')
                                                as Widget
                                            : imageSVGAsset(
                                                    'icon_microphone_disabled')
                                                as Widget,
                                        onClickAction: () async {
                                          await context
                                              .read<ChatCubit>()
                                              .audioMute();
                                        }),
                                    const SizedBox(width: 20),
                                    CallButtonShape(
                                        image: !state.videoMuted
                                            ? imageSVGAsset(
                                                'icon_video_recorder') as Widget
                                            : imageSVGAsset(
                                                    'icon_video_recorder_disabled')
                                                as Widget,
                                        onClickAction: () async {
                                          await context
                                              .read<ChatCubit>()
                                              .videoMute();
                                        }),
                                    const SizedBox(width: 20),
                                    CallButtonShape(
                                        image: imageSVGAsset(
                                            'icon_arrow_square_up') as Widget,
                                        bgColor: true
                                            ? ColorConstants.kPrimaryColor
                                            : ColorConstants.kWhite30,
                                        onClickAction: () async {}),
                                    const SizedBox(width: 20),
                                    CallButtonShape(
                                      image:
                                          imageSVGAsset('icon_phone') as Widget,
                                      bgColor: ColorConstants.kPrimaryColor,
                                      onClickAction: () async {
                                        await context
                                            .read<ChatCubit>()
                                            .rejectCall();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }

                      if (state.currentParticipant != null ||
                          state.chatDetails != null) {
                        if (state.localStream != null) {
                          print("local stream not null");
                          if (state.remoteStream == null) {
                            return ParticipantVideoWidget(
                                remoteStream: state.localStream!,
                                height: double.maxFinite,
                                width: double.maxFinite);
                          } else {
                            return Stack(
                              children: [
                                ParticipantVideoWidget(
                                    remoteStream: state.remoteStream!,
                                    height: double.maxFinite,
                                    width: double.maxFinite),
                                ParticipantVideoWidget(
                                    remoteStream: state.remoteStream!,
                                    height: 200,
                                    width: 200),
                                Positioned.fill(
                                  bottom: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CallButtonShape(
                                          image: false
                                              ? imageSVGAsset('icon_microphone')
                                                  as Widget
                                              : imageSVGAsset(
                                                      'icon_microphone_disabled')
                                                  as Widget,
                                          onClickAction: () async {
                                            // await context
                                            //     .read<ConferenceCubit>()
                                            //     .audioMute();
                                          }),
                                      const SizedBox(width: 20),
                                      CallButtonShape(
                                          image: false
                                              ? imageSVGAsset(
                                                      'icon_video_recorder')
                                                  as Widget
                                              : imageSVGAsset(
                                                      'icon_video_recorder_disabled')
                                                  as Widget,
                                          onClickAction: () async {
                                            // await context
                                            //     .read<ConferenceCubit>()
                                            //     .videoMute();
                                          }),
                                      const SizedBox(width: 20),
                                      CallButtonShape(
                                          image: imageSVGAsset(
                                              'icon_arrow_square_up') as Widget,
                                          bgColor: true
                                              ? ColorConstants.kPrimaryColor
                                              : ColorConstants.kWhite30,
                                          onClickAction: () async {}),

                                      // const SizedBox(width: 20),

                                      // Stack(children: [
                                      //   CallButtonShape(
                                      //     image: imageSVGAsset('icon_message')
                                      //     as Widget,
                                      //     bgColor: ColorConstants.kPrimaryColor
                                      //         .withOpacity(0.4),
                                      //     onClickAction: () async {
                                      //       await context
                                      //           .read<ConferenceCubit>()
                                      //           .toggleChatWindow();
                                      //     },
                                      //   ),
                                      //   Positioned(
                                      //     right: 0,
                                      //     top: 0,
                                      //     child: AnimatedOpacity(
                                      //       opacity:
                                      //       (state.unreadMessages != null &&
                                      //           state.unreadMessages! > 0)
                                      //           ? 1
                                      //           : 0,
                                      //       duration:
                                      //       const Duration(milliseconds: 250),
                                      //       child: Container(
                                      //         width: 12,
                                      //         height: 12,
                                      //         decoration: const ShapeDecoration(
                                      //           color: Colors.white,
                                      //           shape: OvalBorder(),
                                      //         ),
                                      //         // child: Text(
                                      //         //   '1',
                                      //         //   style: context
                                      //         //       .primaryTextTheme.labelSmall
                                      //         //       ?.copyWith(
                                      //         //           fontSize: 8,
                                      //         //           fontWeight:
                                      //         //               FontWeight.w700),
                                      //         // )
                                      //       ),
                                      //     ),
                                      //   ),
                                      //   // child: Text('${state.unreadMessages}', style: context.primaryTextTheme.labelSmall,)),
                                      //   //   child: Text('1', style: context.primaryTextTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w700),)),,
                                      // ]),

                                      const SizedBox(width: 20),
                                      // CallButtonShape(
                                      //     image: imageSVGAsset('icon_user') as Widget,
                                      //     // onClickAction: joined ? switchCamera : null),
                                      //     onClickAction: joined ? null : null),
                                      // const SizedBox(width: 20),
                                      CallButtonShape(
                                        image: imageSVGAsset('icon_phone')
                                            as Widget,
                                        bgColor: ColorConstants.kPrimaryColor,
                                        onClickAction: () async {
                                          await context
                                              .read<ChatCubit>()
                                              .rejectCall();
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
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        }

                        return Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.listType == ListType.Chats
                                            ? state.chatDetails?.chatName ??
                                                "" // Use null-safe operator to avoid errors
                                            : state.currentParticipant?.name ??
                                                "",
                                        style: titleThemeStyle
                                            .textTheme.titleLarge,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 15.0,
                                            // Adjust the width as needed
                                            height: 15.0,
                                            // Adjust the height as needed
                                            decoration: BoxDecoration(
                                              color: (state.currentParticipant == null ? false : state.currentParticipant!.online)
                                                  ? Colors.green
                                                  : Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Text(
                                            (state.currentParticipant == null ? false : state.currentParticipant!.online)
                                                ? "Active now"
                                                : "Away",
                                            style: titleThemeStyle
                                                .textTheme.labelLarge,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  Visibility(
                                      visible: state.currentParticipant == null ? false:  state.currentParticipant!.online,
                                      child: CallButtonShape(
                                        image: imageSVGAsset('icon_phone')
                                            as Widget,
                                        bgColor: ColorConstants.kStateSuccess,
                                        onClickAction: () async {
                                          await context
                                              .read<ChatCubit>()
                                              .makeCall(
                                                  state.currentParticipant!.id);

                                          // await context.read<ChatCubit>().rejectCall();
                                        },
                                      ))
                                ],
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: Stack(
                                children: [
                                  DropzoneView(
                                    onCreated: (ctrl) => controller = ctrl,
                                    onDrop: onFileDropped,
                                  ),
                                  Container(
                                    child: !state.isLoading
                                        ? ChatDetailsWidget(state)
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    textInputAction: TextInputAction.go,
                                    focusNode: messageFocusNode,
                                    onSubmitted: (value) async {
                                      var participiansList = state
                                          .chatDetails!.chatParticipants
                                          .map((data) => data.id)
                                          .toList();

                                      var participantId = state.chatDetails!
                                          .chatParticipants.first.id;

                                      await context
                                          .read<ChatCubit>()
                                          .sendChatMessage(
                                              chatId: state.chatDetails!.chatId,
                                              messageContent:
                                                  messageFieldController.text,
                                              participiantsId: participiansList,
                                              senderId: state
                                                  .chatDetails!.authUser.id);

                                      sendMessage(participantId);
                                      messageFieldController.text = "";
                                    },
                                    controller: messageFieldController,
                                    decoration: InputDecoration(
                                        hintText: "Send a message",
                                        suffixIcon: IconButton(
                                          onPressed: () async {
                                            var participiansList = state
                                                .chatDetails!.chatParticipants
                                                .map((data) => data.id)
                                                .toList();

                                            var participantId = state
                                                .chatDetails!
                                                .chatParticipants
                                                .first
                                                .id;

                                            await context
                                                .read<ChatCubit>()
                                                .sendChatMessage(
                                                    chatId: state
                                                        .chatDetails!.chatId,
                                                    messageContent:
                                                        messageFieldController
                                                            .text,
                                                    participiantsId:
                                                        participiansList,
                                                    senderId: state.chatDetails!
                                                        .authUser.id);
                                            sendMessage(participantId);
                                            messageFieldController.text = "";
                                          },
                                          icon: imageSVGAsset('icon_send')
                                              as Widget,
                                        )),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await context
                                        .read<ChatCubit>()
                                        .chooseFile();
                                  },
                                  icon: imageSVGAsset('three_dots') as Widget,
                                )
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          UserImage.large(user!.imageUrl),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge,
                              ),
                              Text(
                                user.name,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ],
                      );
                    }(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ));
    });
  }
}
