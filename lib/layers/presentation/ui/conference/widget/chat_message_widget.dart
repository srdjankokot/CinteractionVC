import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/domain/entities/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../chat/link_text.dart';
import '../../profile/ui/widget/user_image.dart';


class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding:  const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment:message.displayName == 'Me' ? MainAxisAlignment.end: MainAxisAlignment.start,
          children: [
            Visibility(
                visible: message.displayName != 'Me' && message.avatarUrl.isNotEmpty,
                child: UserImage.medium(message.avatarUrl)),
            const SizedBox(width: 12,),
           Expanded(child:
           Column(
             crossAxisAlignment: message.displayName == 'Me' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
             children: [ Row(
               mainAxisAlignment: message.displayName == 'Me' ? MainAxisAlignment.end : MainAxisAlignment.start,
                   children: [
                     Visibility(
                         visible: message.displayName != 'Me',
                         child: Text(message.displayName, style: context.primaryTextTheme.displaySmall)),
                     const SizedBox(width: 6,),
                 Container(
                   child: Text(
                       DateFormat('hh:mm a').format(message.time),
                       style: context.primaryTextTheme.bodySmall?.copyWith(color: ColorConstants.kGray600),

                     )
                 ),
                   ],
                 ),
               LinkText(message.message)

           //
           // Text(
           //         message.message,
           //         style: context.primaryTextTheme.bodySmall?.copyWith(color: ColorConstants.kGray600),
           //         softWrap: true,
           //       ),
             ],
           ),)
          ],
        ),
    );
  }
}
