

import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/ui/images/image.dart';
import '../conference/widget/chat_message_widget.dart';

class ChatRoomPage extends StatelessWidget{

  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController chatController = ScrollController();
    TextEditingController messageFieldController = TextEditingController();


    FocusNode messageFocusNode = FocusNode();
    // final chatCubit = context.watch<ChatCubit>();

    Future<void> sendMessage() async {
      await context.read<ChatCubit>().sendMessage(messageFieldController.text);
      messageFieldController.text = '';
    }

    return BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state){

          print("number of participants: ${state.participants?.length}");

          return  Scaffold(
            body: Row(
              children: [
                // First column
                SizedBox(
                  width: 300,
                  child: Center(
                    child: ListView.builder(
                      itemCount: state.participants?.length ?? 0,
                      itemBuilder: (context, index){

                        var participant = state.participants![index];
                        return ListTile(
                          title: Text(participant.display),
                          trailing: participant.haveUnreadMessages ? const Icon(Icons.arrow_forward) : null,
                          onTap: () => {
                            context.read<ChatCubit>().setCurrentParticipant(state.participants![index])
                          },
                        );
                      },
                    ),
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
                  child:  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(23.0),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              child: state.messages == null
                                  ? const Center(
                                  child: Text('No Messages'))
                                  : ListView.builder(
                                controller: chatController,
                                itemCount:
                                state.messages?.length,
                                itemBuilder:
                                    (BuildContext context,
                                    int index) {
                                  return VisibilityDetector(
                                      key: Key(
                                          index.toString()),
                                      onVisibilityChanged: (VisibilityInfo info) {
                                        context.read<ChatCubit>().chatMessageSeen(index);
                                      },
                                      child: ChatMessageWidget(
                                          message:
                                          state.messages![
                                          index]));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  textInputAction:
                                  TextInputAction.go,
                                  focusNode: messageFocusNode,
                                  onSubmitted: (value) {
                                    sendMessage();
                                  },
                                  controller:
                                  messageFieldController,
                                  decoration: InputDecoration(
                                      hintText: "Send a message",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          sendMessage();
                                        },
                                        icon: imageSVGAsset('icon_send') as Widget,
                                      )),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );



    // return BlocConsumer<ChatCubit, ChatState>(
    //   builder: (context, state){
    //
    //     return  Scaffold(
    //       body: Row(
    //         children: [
    //           // First column
    //           SizedBox(
    //             width: 300,
    //             child: Center(
    //               child: ListView.builder(
    //                 itemCount: state.participants?.length,
    //                 itemBuilder: (context, index){
    //                   return ListTile(
    //                     title: Text(state.participants![index].display),
    //                     trailing: Icon(Icons.arrow_forward),
    //                     onTap: () => {
    //                       context.read<ChatCubit>().setCurrentParticipant(state.participants![index])
    //                     },
    //                   );
    //                 },
    //               ),
    //             ),
    //           ),
    //
    //           const VerticalDivider(
    //             color: Colors.grey, // Color of the divider
    //             thickness: 1, // Thickness of the divider
    //             width: 20, // Width of the space taken by the divider
    //           ),
    //
    //           // Second column
    //           Expanded(
    //             flex: 2,
    //             child:  Container(
    //               width: double.maxFinite,
    //               height: double.maxFinite,
    //               color: Colors.white,
    //               child: Padding(
    //                 padding: const EdgeInsets.all(23.0),
    //                 child: Column(
    //                   // crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Expanded(
    //                       child: Container(
    //                         child: state.messages == null
    //                             ? const Center(
    //                             child: Text('No Messages'))
    //                             : ListView.builder(
    //                           controller: chatController,
    //                           itemCount:
    //                           state.messages?.length,
    //                           itemBuilder:
    //                               (BuildContext context,
    //                               int index) {
    //                             return VisibilityDetector(
    //                                 key: Key(
    //                                     index.toString()),
    //                                 onVisibilityChanged: (VisibilityInfo info) {  },
    //                                 child: ChatMessageWidget(
    //                                     message:
    //                                     state.messages![
    //                                     index]));
    //                           },
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(
    //                       height: 5,
    //                     ),
    //                     Row(
    //                       children: [
    //                         Expanded(
    //                           child: TextField(
    //                             textInputAction:
    //                             TextInputAction.go,
    //                             focusNode: messageFocusNode,
    //                             onSubmitted: (value) {
    //                               sendMessage();
    //                             },
    //                             controller:
    //                             messageFieldController,
    //                             decoration: InputDecoration(
    //                                 hintText: "Send a message",
    //                                 suffixIcon: IconButton(
    //                                   onPressed: () {
    //                                     sendMessage();
    //                                   },
    //                                   icon: imageSVGAsset('icon_send') as Widget,
    //                                 )),
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //
    //   },
    //
    //
    //   listener: (BuildContext context, ChatState state) {
    //
    // },
    //
    // );



  }

}