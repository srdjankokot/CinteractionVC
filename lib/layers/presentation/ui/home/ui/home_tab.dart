import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/home_item.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/join_popup.dart';
import 'package:cinteraction_vc/layers/presentation/ui/home/ui/widgets/schedule_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/ui/images/image.dart';
import '../../../../domain/entities/meeting.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {


    Future<void> displayJoinRoomPopup(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return const JoinPopup();
        },
      );
    }

    Future<void> displayAddScheduleMeetingPopup(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (context) {
          return const SchedulePopup();
        },
      );
    }



    Widget startMeetingWidget()
    {
      return HomeTabItem.getHomeTabItem(
        context: context,
        image: const Image(
        image: ImageAsset('stand.png'),
        fit: BoxFit.fill,
      ),
           onClickAction:  () {
          context.pushNamed('meeting',
              pathParameters: {
                'roomId': Random().nextInt(999999).toString(),
              },
              extra: context.getCurrentUser?.name);
        },
        label: 'Start Meeting',
         textStyle:  context.textTheme.labelMedium,

      );
    }

    Widget addUserWidget()
    {
      return  HomeTabItem.getHomeTabItem(
         context: context,
          image: const Image(
            image: ImageAsset('user-square.png'),
          ),
          bgColor: ColorConstants.kStateWarning,
          onClickAction: null,
          label: 'Add User',
          textStyle: context.textTheme.labelMedium);
    }

    Widget scheduleMeetingWidget()
    {
      return HomeTabItem.getHomeTabItem(
        context: context,
          image: const Image(
            image: ImageAsset('calendar-date.png'),
          ),
          bgColor: ColorConstants.kStateInfo,
          onClickAction: () => {
            // AppRoute.meeting.push(context)
            displayAddScheduleMeetingPopup(context)
          },
          label: 'Schedule',
          textStyle: context.textTheme.labelMedium);
    }


    Widget joinMeetingWidget()
    {
      return HomeTabItem.getHomeTabItem(
        context: context,
          image: const Image(
            image: ImageAsset('add_user.png'),
          ),
          bgColor: ColorConstants.kStateSuccess,
          onClickAction: () => {
            // AppRoute.meeting.push(context)
            displayJoinRoomPopup(context)
          },
          label: 'Join',
          textStyle: context.textTheme.labelMedium);
    }



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
            margin: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        startMeetingWidget(),
                        const SizedBox(
                          height: 30,
                        ),
                        scheduleMeetingWidget()
                      ],
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Column(
                      children: [
                        joinMeetingWidget(),
                        const SizedBox(
                          height: 30,
                        ),
                        addUserWidget()
                      ],
                    )
                  ],
                ),
                const Spacer(),
                const Visibility(
                  visible: true,
                  child: NextMeetingWidget(),
                ),
                const Spacer(),
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
                      child: startMeetingWidget()
                  ),
                  Expanded(
                      flex: 1,
                      child: joinMeetingWidget()),
                  Expanded(
                      flex: 1,
                      child: scheduleMeetingWidget()),
                  Expanded(
                      flex: 1,
                      child: addUserWidget())
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

class NextMeetingWidget extends StatelessWidget {
  const NextMeetingWidget({super.key});

  UserDto get _organizer => UserDto(
        id: 23,
        name: 'John Doe',
        email: 'john@test.com',
        imageUrl:
            'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
        createdAt: DateTime.now(),
      );

  Meeting get _meeting => Meeting(
      callId: 2,
      organizer: '_organizer',
      organizerId: 23,
      averageEngagement: Random().nextDouble(),
      recorded: false,
      meetingStart: DateTime.now().add(const Duration(hours: 2)),
      meetingEnd: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      totalNumberOfUsers: 3,
      );

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
                    'Digital Photography',
                    style: context.textTheme.displayLarge,
                  ),
                  Text(
                    '${_meeting.meetingStart?.hour}:${_meeting.meetingStart?.minute} - ${_meeting.meetingEnd?.hour}:${_meeting.meetingEnd?.minute}',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Meeting ID: ${_meeting.callId}',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Passcode: 123456',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Organizer: ${_meeting.organizer}',
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
    );
  }
}
