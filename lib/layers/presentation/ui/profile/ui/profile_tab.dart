import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/extension/router.dart';
import 'package:cinteraction_vc/core/util/menu_items.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/route.dart';
import '../../../../../core/ui/images/image.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {

    final user = context.getCurrentUser;
    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => AppRoute.auth.push(context),
          child: const Text('Log In'),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),

        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Column(children: [

           const  Spacer(),
            Container(

              margin: const EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                children: [
                  UserImage.medium(user.imageUrl),
                  const SizedBox(width: 10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleSmall,
                      ),

                      Text(
                        'Participant',
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const  Spacer(),
            const Divider(),
          ],),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(

          onPressed: () {
            context.logOut();
          },
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
