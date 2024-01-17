import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/navigation/route.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isWide) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'WELCOME TO',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium,
          ),
          Text(
            'Virtual Classroom of the Future',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineLarge,
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    HomeTabItem(
                        image: const Image(
                          image: ImageAsset('stand.png'),
                        ),
                        onClickAction: () => {AppRoute.meeting.push(context)},
                        label: 'Start Meeting'),
                    const SizedBox(
                      height: 30,
                    ),
                    const HomeTabItem(
                        image: Image(
                          image: ImageAsset('calendar-date.png'),
                        ),
                        bgColor: ColorConstants.kInfoBlue,
                        onClickAction: null,
                        label: 'Schedule')
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                const Column(
                  children: [
                    HomeTabItem(
                      image: Image(
                        image: ImageAsset('add_user.png'),
                      ),
                      bgColor: ColorConstants.kSuccessGreen,
                      onClickAction: null,
                      label: 'Join',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    HomeTabItem(
                        image: Image(
                          image: ImageAsset('user-square.png'),
                        ),
                        bgColor: ColorConstants.kWarning,
                        onClickAction: null,
                        label: 'Add User')
                  ],
                )
              ],
            ),
          ),
        ],
      ));
    } else {
      return Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            imageSVGAsset('original_long_logo') as Widget,
            const SizedBox(height: 50),
            Text(
              'WELCOME TO',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            Text(
              'Virtual Classroom of the Future',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelSmall,
                          size: 52,
                          image: const Image(
                            image: ImageAsset('stand.png'),
                            fit: BoxFit.fill,
                          ),
                          onClickAction: () => {AppRoute.meeting.push(context)},
                          label: 'Start Meeting')),

                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                        textStyle: context.textTheme.labelSmall,
                        size: 52,
                        image: Image(
                          image: ImageAsset('add_user.png'),
                        ),
                        bgColor: ColorConstants.kSuccessGreen,
                        onClickAction: null,
                        label: 'Join',
                      )),

                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelSmall,
                          size: 52,
                          image: Image(
                            image: ImageAsset('calendar-date.png'),
                          ),
                          bgColor: ColorConstants.kInfoBlue,
                          onClickAction: null,
                          label: 'Schedule')),

                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelSmall,
                          size: 52,
                          image: Image(
                            image: ImageAsset('user-square.png'),
                            fit: BoxFit.scaleDown,
                            height: 10,
                            width: 10,
                          ),
                          bgColor: ColorConstants.kWarning,
                          onClickAction: null,
                          label: 'Add User'))
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}

class HomeTabItem extends StatelessWidget {
  final Image image;
  final VoidCallback? onClickAction;
  final Color bgColor;
  final String label;
  final double? size;
  final TextStyle? textStyle;

  const HomeTabItem(
      {super.key,
      required this.image,
      required this.onClickAction,
      this.bgColor = ColorConstants.kPrimaryColor,
      required this.label,
      this.size = 124,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClickAction,
      child: SizedBox(
        height: size! + 30,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(size! / 4),
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size! / 4),
                ),
              ),
              child: Image(
                image: image.image,
                fit: BoxFit.fill,
              ),

              // child: SizedBox(
              //     width: 5,
              //     height: 5,
              //     child: image),
            ),
            const Spacer(),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            )
          ],
        ),
      ),
    );
  }
}
