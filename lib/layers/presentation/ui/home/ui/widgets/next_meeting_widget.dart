import 'dart:math';

import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:one_clock/one_clock.dart';
// import 'package:slide_digital_clock/slide_digital_clock.dart';

import '../../../../../../assets/colors/Colors.dart';
import '../../../../../../core/ui/images/image.dart';
import '../../../../../data/dto/user_dto.dart';
import '../../../../../domain/entities/meetings/meeting.dart';

class NextMeetingWidget extends StatelessWidget {
  const NextMeetingWidget({super.key, required this.meeting});

  final Meeting meeting;

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
                    child: const DigitalClock(
                      showSeconds: false,
                      textScaleFactor: 1.3,
                      isLive: true,
                      digitalClockTextColor: Colors.white,
                    )


                    // DigitalClock(
                    //   showSecondsDigit: false,
                    //   hourMinuteDigitTextStyle: context.titleTheme.headlineMedium?.copyWith(color: Colors.white),
                    //   colon: Text(':', style: context.titleTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 30),
                    //   ),
                    // ),
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
                    meeting.eventName?? "Next Meeting",
                    style: context.textTheme.displayLarge,
                  ),

                  Text('${DateFormat('HH:mm').format(meeting.meetingStart)} - ${DateFormat('HH:mm').format(meeting.meetingEnd!)}',
                      style: context.textTheme.bodyLarge),

                  // Text(
                  //   '${meeting.meetingStart.hour}:${meeting.meetingStart.minute} - ${meeting.meetingEnd?.hour}:${meeting.meetingEnd?.minute}',
                  //   style: context.textTheme.bodyLarge,
                  // ),
                  Text(
                    'Meeting ID: ${meeting.callId}',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Passcode: ',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Organizer: ${meeting.organizer}',
                    style: context.textTheme.bodyLarge,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          context.pushNamed('meeting',
                              pathParameters: {
                                'roomId': meeting.streamId!,
                              },
                              extra: context.getCurrentUser?.name);
                        },
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