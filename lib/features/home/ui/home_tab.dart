import 'dart:math';

import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

import '../../../../assets/colors/Colors.dart';
import '../../../../core/ui/images/image.dart';
import '../../../../core/navigation/route.dart';
import '../../meetings/model/meeting.dart';
import '../../profile/model/user.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isWide) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WELCOME TO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'Virtual Classroom of the Future',
            textAlign: TextAlign.center,
            style: context.titleTheme.titleLarge,
          ),
          Container(
            margin: const EdgeInsets.only(top: 50, left: 300, right: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        HomeTabItem(
                          image: const Image(
                            image: ImageAsset('stand.png'),
                          ),
                          onClickAction: () => {AppRoute.meeting.push(context)},
                          label: 'Start Meeting',
                          textStyle: context.textTheme.labelMedium,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        HomeTabItem(
                            image: const Image(
                              image: ImageAsset('calendar-date.png'),
                            ),
                            bgColor: ColorConstants.kStateInfo,
                            onClickAction: null,
                            label: 'Schedule',
                            textStyle: context.textTheme.labelMedium)
                      ],
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Column(
                      children: [
                        HomeTabItem(
                            image: const Image(
                              image: ImageAsset('add_user.png'),
                            ),
                            bgColor: ColorConstants.kStateSuccess,
                            onClickAction: () =>
                                {AppRoute.meeting.push(context)},
                            label: 'Join',
                            textStyle: context.textTheme.labelMedium),
                        const SizedBox(
                          height: 30,
                        ),
                        HomeTabItem(
                            image: const Image(
                              image: ImageAsset('user-square.png'),
                            ),
                            bgColor: ColorConstants.kStateWarning,
                            onClickAction: null,
                            label: 'Add User',
                            textStyle: context.textTheme.labelMedium)
                      ],
                    )
                  ],
                ),
                Visibility(
                    visible: true,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 250,
                        ),
                        const NextMeetingWidget(),
                      ],
                    ))
              ],
            ),
          ),
        ],
      ));
    } else {
      return Container(
        margin: const EdgeInsets.only(right: 20, left: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            imageSVGAsset('original_long_logo') as Widget,
            const SizedBox(height: 50),
            Text(
              'WELCOME TO',
              textAlign: TextAlign.center,
              style: context.titleTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
            Text(
              'Virtual Classroom of the Future',
              textAlign: TextAlign.center,
              style: context.titleTheme.titleMedium,
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelMedium,
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
                        textStyle: context.textTheme.labelMedium,
                        size: 52,
                        image: Image(
                          image: ImageAsset('add_user.png'),
                        ),
                        bgColor: ColorConstants.kStateSuccess,
                        onClickAction: null,
                        label: 'Join',
                      )),
                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelMedium,
                          size: 52,
                          image: Image(
                            image: ImageAsset('calendar-date.png'),
                          ),
                          bgColor: ColorConstants.kStateInfo,
                          onClickAction: null,
                          label: 'Schedule')),
                  Expanded(
                      flex: 1,
                      child: HomeTabItem(
                          textStyle: context.textTheme.labelMedium,
                          size: 52,
                          image: Image(
                            image: ImageAsset('user-square.png'),
                            fit: BoxFit.scaleDown,
                            height: 10,
                            width: 10,
                          ),
                          bgColor: ColorConstants.kStateWarning,
                          onClickAction: null,
                          label: 'Add User'))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(),
            const SizedBox(
              height: 30,
            ),
            Visibility(
                child: Column(
              children: [
                Text(
                  'Upcoming Meetings',
                  textAlign: TextAlign.center,
                  style: context.titleTheme.titleSmall,
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    margin: const EdgeInsets.only(right: 20, left: 20),
                    child: const NextMeetingWidget()),
              ],
            )),
            const SizedBox(height: 20),
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
    return SizedBox(
      height: size! + 40,
      child: Column(
        children: [
          Card(
              elevation: 3,
              color: bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size! / 4)),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: onClickAction,
                child: Container(
                  width: size,
                  height: size,
                  child: Container(
                      padding: EdgeInsets.all(size! / 4), child: image),
                ),
              )),
          const Spacer(),
          SizedBox(
            height: textStyle!.fontSize! * textStyle!.height! * 2,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NextMeetingWidget extends StatelessWidget {
  const NextMeetingWidget({super.key});

  User get _organizer => User(
        id: 'john-doe',
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
            'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      );

  Meeting get _meeting => Meeting(
      id: '225-885-25',
      passcode: '123456',
      name: 'Digital Photography',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: false,
      start: DateTime.now().add(const Duration(hours: 2)),
      end: DateTime.now().add(const Duration(hours: 3, minutes: 30)));

  @override
  Widget build(BuildContext context) {
    var currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(7),
        ),
      ),
      child: Container(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(

                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, left: 20, right: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: ImageAsset('next_meeting_bg.png'), fit: BoxFit.fill),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: DigitalClock(
                        showSecondsDigit: false,
                        hourMinuteDigitTextStyle: context
                            .titleTheme.headlineMedium
                            ?.copyWith(color: Colors.white),
                        colon: Text(
                          ':',
                          style: context.titleTheme.headlineMedium
                              ?.copyWith(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                    Text(
                      currentDate,
                      style: context.textTheme.bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _meeting.name,
                      style: context.textTheme.displayLarge,
                    ),
                    Text(
                      '${_meeting.start.hour}:${_meeting.start.minute} - ${_meeting.end.hour}:${_meeting.end.minute}',
                      style: context.textTheme.bodyLarge,
                    ),
                    Text(
                      'Meeting ID: ${_meeting.id}',
                      style: context.textTheme.bodyLarge,
                    ),
                    Text(
                      'Passcode: ${_meeting.passcode}',
                      style: context.textTheme.bodyLarge,
                    ),
                    Text(
                      'Organizer: ${_meeting.organizer.name}',
                      style: context.textTheme.bodyLarge,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                          onPressed: () => {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                ColorConstants.kStateSuccess),
                          ),
                          child: Text(
                            'Join Meeting',
                            style: context.textTheme.labelLarge
                                ?.copyWith(color: Colors.white),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
