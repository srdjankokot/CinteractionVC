import 'package:flutter/material.dart';

import '../../../../../../core/ui/widget/url_image.dart';



class UserImage extends StatelessWidget {
  const UserImage.small(this.url, {super.key}) : size = 32;

  const UserImage.medium(this.url, {super.key}) : size = 48;

  const UserImage.large(this.url, {super.key}) : size = 64;

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {

    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: size/2,
      child: UrlImage.circle(
        url: url,
        size: size - 3,
      ),
    );


    return UrlImage.circle(
      url: url,
      size: size,
    );
  }
}
