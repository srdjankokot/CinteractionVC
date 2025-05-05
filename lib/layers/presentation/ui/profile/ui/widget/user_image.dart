import 'package:flutter/material.dart';

import '../../../../../../core/ui/widget/url_image.dart';


class UserImage extends StatelessWidget {
  const UserImage.small(this.url, {super.key, this.chatId = 1}) : size = 32;

  const UserImage.medium(this.url , {super.key, this.chatId = 1}) : size = 48;

  const UserImage.large(this.url,  {super.key, this.chatId = 1}) : size = 64;

  final String url;
  final int chatId;
  final double size;

  @override
  Widget build(BuildContext context) {


    Color getRandomColor() {
      final hash = "${chatId * 256}".codeUnits.fold(0, (prev, elem) => prev * 31 + elem);
      final r = 127 + (hash >> 16) % 120;
      final g = 127 + (hash >> 8) % 120;
      final b = 127 + hash % 120;
      return Color.fromARGB(255, r, g, b);
    }
    
    if(url.contains("https:") || url.contains("http:"))
      {
        return CircleAvatar(
          backgroundColor: Colors.white,
          radius: size/2,
          child: UrlImage.circle(
            url: url,
            size: size - 3,
          ),
        );
      }
    else
      {
        return CircleAvatar(
          backgroundColor: getRandomColor(),
          radius: size/2,
          child: Text("$url"),
        ); 
      }
    


  }
}
