import 'package:audioplayers/audioplayers.dart';
import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/ui/widget/call_button_shape.dart';
import '../conference/video_room.dart';
import '../conference/widget/chat_message_widget.dart';
import '../home/ui/widgets/join_popup.dart';
import '../profile/ui/widget/user_image.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.getCurrentUser;

    final ScrollController chatController = ScrollController();
    TextEditingController messageFieldController = TextEditingController();

    FocusNode messageFocusNode = FocusNode();

    AudioPlayer _audioPlayer = AudioPlayer();

    late DropzoneViewController controller;

    Future<void> _onFileDropped(dynamic event) async {

      final  name = controller.getFilename(event);
      final bytes = await controller.getFileData(event);
      await context.read<ChatCubit>().sendFile(name.toString(), bytes);
      // You can process the file bytes as needed here
    }

    void _playIncomingCallSound() async {
      // Play the sound
      try {
        await _audioPlayer.setSource(AssetSource('discord_incoming_call.mp3'));
        _audioPlayer.resume();
      } catch (e) {
        print('Error playing sound: $e'); // Log any errors
      }
    }

    void _stopIncomingCallSound() async {
      // Stop the sound if it's playing
      await _audioPlayer.stop();
    }

    Future<void> sendMessage() async {
      await context.read<ChatCubit>().sendMessage(messageFieldController.text);
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
      _playIncomingCallSound();

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
                      _stopIncomingCallSound();
                      // Navigator.of(context).pop(callDialog);
                    },
                    child: const Text('Answer')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true)
                          .pop(incomingDialog);
                      context.read<ChatCubit>().rejectCall();
                      _stopIncomingCallSound();
                    },
                    child: const Text('Reject')),
              ],
            );
          });
    }

    Future<dynamic> showCallingDialog(
        BuildContext context, String caller) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Calling ${caller}'),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      // Navigator.of(context, rootNavigator: true).pop(incomingDialog);
                      Navigator.of(context, rootNavigator: true)
                          .pop(callDialog);

                      // await publishVideo.hangup();
                      context.read<ChatCubit>().rejectCall();
                    },
                    child: const Text('Reject')),
              ],
            );
          });
    }

    return BlocConsumer<ChatCubit, ChatState>(listener: (context, state) async {
      if (state.incomingCall ?? false) {
        String callerName = "Caller Name"; // Replace with actual caller name
        await showIncomingCallDialog(context, callerName);
        return;
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(incomingDialog);
          _stopIncomingCallSound();
        }
      }

      if (state.calling ?? false) {
        await makeCallDialog();
        return;
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
                child: Center(
                  child: ListView.builder(
                    itemCount: state.users?.length ?? 0,
                    itemBuilder: (context, index) {
                      var user = state.users![index];

                      return GestureDetector(
                        onTap: () {
                          context.read<ChatCubit>().setCurrentParticipant(state.users![index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Stack(
                                children: [
                                  UserImage.medium(user.imageUrl),
                                  Visibility(
                                      visible: user.online,
                                      child: Positioned(
                                        bottom: 2,
                                        right: 4,
                                        child: ClipOval(
                                          child: Container(
                                            width: 10.0,
                                            // width of the circle
                                            height: 10.0,
                                            // height of the circle
                                            color: Colors
                                                .green, // background color
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // ListView.builder(
                  //   itemCount: state.participants?.length ?? 0,
                  //   itemBuilder: (context, index) {
                  //     var participant = state.participants![index];
                  //
                  //     return GestureDetector(
                  //       onTap: (){context.read<ChatCubit>().setCurrentParticipant(state.participants![index]);
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(4.0),
                  //         child: Row(
                  //           children: [
                  //             const SizedBox(
                  //               width: 10,
                  //             ),
                  //             Container(
                  //               width: 50.0,  // Adjust the width as needed
                  //               height: 50.0, // Adjust the height as needed
                  //               decoration: const BoxDecoration(
                  //                 color: Colors.brown,
                  //                 shape: BoxShape.circle,
                  //               ),
                  //             ),
                  //             const SizedBox(
                  //               width: 10,
                  //             ),
                  //
                  //             Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   participant.display,
                  //                   textAlign: TextAlign.center,
                  //                   style: context.textTheme.titleSmall,
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //
                  //   },
                  // ),
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
                          return getRendererItem(context, state.localStream!,
                              double.maxFinite, double.maxFinite);
                        } else {
                          return Stack(
                            children: [
                              getRendererItem(context, state.remoteStream!,
                                  double.maxFinite, double.maxFinite),
                              getRendererItem(
                                  context, state.localStream!, 200, 200),
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
                                                'icon_video_recorder') as Widget
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

                      if (state.currentParticipant != null) {
                        if (state.localStream != null) {
                          print("local stream not null");
                          if (state.remoteStream == null) {
                            return getRendererItem(context, state.localStream!,
                                double.maxFinite, double.maxFinite);
                          } else {
                            print("remote stream not null");
                            return Stack(
                              children: [
                                getRendererItem(context, state.remoteStream!,
                                    double.maxFinite, double.maxFinite),
                                getRendererItem(
                                    context, state.localStream!, 200, 200),
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
                                        state.currentParticipant!.name,
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
                                            decoration:  BoxDecoration(
                                              color: state.currentParticipant!.online ? Colors.green : Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Text(
                                           state.currentParticipant!.online? "Active now": "Away",
                                            style: titleThemeStyle
                                                .textTheme.labelLarge,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  Visibility(
                                      visible: state.currentParticipant!.online,
                                      child:    CallButtonShape(
                                        image:
                                        imageSVGAsset('icon_phone') as Widget,
                                        bgColor: ColorConstants.kPrimaryColor,
                                        onClickAction: () async {
                                          await context.read<ChatCubit>().makeCall(
                                              state.currentParticipant!.name);
                                        },
                                      )
                                  )



                                ],
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child:
                              Stack(
                              children: [
                                DropzoneView(
                                  onCreated: (ctrl) => controller = ctrl,
                                  onDrop: _onFileDropped,
                                ),
                                Container(
                                  child: state.messages == null
                                      ? const Center(child: Text('No Messages'))
                                      : ListView.builder(

                                    controller: chatController,
                                    itemCount: state.messages?.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return VisibilityDetector(
                                          key: Key(index.toString()),
                                          onVisibilityChanged:
                                              (VisibilityInfo info) {
                                            context
                                                .read<ChatCubit>()
                                                .chatMessageSeen(index);
                                          },
                                          child: ChatMessageWidget(
                                              message:
                                              state.messages![index]));
                                    },
                                  ),
                                ),

                              ],
                              )
                        ,
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
                                    onSubmitted: (value) {
                                      sendMessage();
                                    },
                                    controller: messageFieldController,
                                    decoration: InputDecoration(
                                        hintText: "Send a message",
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            sendMessage();
                                          },
                                          icon: imageSVGAsset('icon_send')
                                              as Widget,
                                        )),
                                  ),
                                ),

                                IconButton(
                                  onPressed: () async {
                                    await context.read<ChatCubit>().chooseFile();
                                  },
                                  icon: imageSVGAsset('three_dots')
                                  as Widget,
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
