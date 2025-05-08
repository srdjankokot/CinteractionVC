import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/ui/widget/url_image.dart';

class UserImage extends StatelessWidget {
  const UserImage.small(this.users, {super.key}) : size = 32;

  const UserImage.medium(this.users, {super.key}) : size = 48;

  const UserImage.large(this.users, {super.key}) : size = 200;

  final List<UserImageDto> users;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (users.isNotEmpty) {
      return MultiUserAvatar(users: users, size: size);
    } else {
      return CircleAvatar(
        backgroundColor: ColorConstants.kPrimaryColor,
        radius: size / 2,
        child: const Text(""),
      );
    }
  }
}

class MultiUserAvatar extends StatelessWidget {
  final List<UserImageDto> users; // max 4
  final double size;

  const MultiUserAvatar({required this.users, this.size = 60, super.key});

  Color getRandomColor(int id) {
    final hash =
        "${id * 256}".codeUnits.fold(0, (prev, elem) => prev * 31 + elem);
    final r = 127 + (hash >> 16) % 120;
    final g = 127 + (hash >> 8) % 120;
    final b = 127 + hash % 120;
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(4).toList();
    final numberOfCol = displayUsers.length > 1 ? 2 : 1;
    final numberOfRow = displayUsers.length > 2 ? 2 : 1;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: Wrap(
          children: List.generate(displayUsers.length, (i) {
            final user = displayUsers[i];

            final width = (i == 2 && displayUsers.length == 3)
                ? size
                : size / numberOfCol;
            final height = size / numberOfRow;

            return Container(
              width: width,
              height: height,
              color: getRandomColor(user.id),
              child: Center(
                  child: Stack(
                children: [
                  // Center(
                    //                   //     child: Padding(
                    //                   //   padding: const EdgeInsets.all(4),
                    //                   //   child:
                    //                   //   AutoSizeText(
                    //                   //     user.name.getInitials(),
                    //                   //     style: const TextStyle(
                    //                   //         fontSize: 100,
                    //                   //         color: Colors.white,
                    //                   //         fontWeight: FontWeight.bold),
                    //                   //     maxLines: 1,
                    //                   //     minFontSize: 10,
                    //                   //     overflow: TextOverflow.ellipsis,
                    //                   //   ),
                    //                   // )

                      Text(
                        user.name.getInitials(),
                        style: TextStyle(
                          fontSize: displayUsers.length == 1 ? null : 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // ),
                  if (user.imageUrl != '' &&
                      !user.imageUrl.contains('ui-avatars'))
                    Center(
                      child: UrlImage.square(
                        url: user.imageUrl,
                        size: max(height, width),
                      ),
                    )
                ],
              )),
            );
          }),
        ),
      ),
    );
  }
}

class UserImageDto {
  UserImageDto({required this.id, required this.name, required this.imageUrl});

  final int id;
  final String name;
  final String imageUrl;
}
