import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/ui/images/image.dart';
import '../../../../../../core/ui/widget/content_layout_web.dart';
import '../../../../../../core/ui/widget/engagement_progress.dart';
import '../../../../../domain/entities/meeting.dart';
import '../../../../cubit/roles/roles_cubit.dart';
import '../../../groups/ui/widget/memebers_widget.dart';
import '../../../profile/ui/widget/user_image.dart';
import '../../../../cubit/meetings/meetings_cubit.dart';

class MeetingListLayout extends StatefulWidget {


  const MeetingListLayout({super.key});

  @override
  MeetingListLayoutState createState() => MeetingListLayoutState();
}

class MeetingListLayoutState extends State<MeetingListLayout> {
  late List<Meeting>? meetings = [];

  @override
  void initState(){
    super.initState();
    context.read<MeetingCubit>().loadMeetings();
  }

  bool isShowingPastMeetings = true;
  @override
  Widget build(BuildContext context) {

    void showPastMeetings() {
      // context.read<MeetingCubit>().loadMeetings();

      setState(() {
        isShowingPastMeetings = true;

      });
    }

    void showScheduledMeetings() {
      context.read<MeetingCubit>().loadScheduledMeetings();
      setState(() {
        isShowingPastMeetings = false;
      });
    }

    void _onMettingsState(BuildContext context, MeetingState state) {
      if (state is MeetingLoaded) {
        setState(() {
          meetings = state.meetings;
        });
      }
    }


    Widget body;
    if (context.isWide) {
      body =  ContentLayoutWeb(
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meetings',
                              style: context.textTheme.headlineLarge,
                            ),
                            Text('${meetings!.length} Meetings'),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => showPastMeetings(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Visibility(
                                        visible: isShowingPastMeetings,
                                        child: SizedBox(
                                          height: 52,
                                          width: 200,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    color: ColorConstants
                                                        .kPrimaryColor
                                                        .withOpacity(
                                                        0.05)),
                                              ),
                                              Container(
                                                  height: 2,
                                                  color:
                                                  ColorConstants
                                                      .kPrimaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 52,
                                        width: 200,
                                        child: Center(
                                          child: Text('Past Meetings',
                                              style: context.textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                color: isShowingPastMeetings
                                                    ? ColorConstants
                                                    .kPrimaryColor
                                                    : ColorConstants
                                                    .kGray2,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () => showScheduledMeetings(),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Visibility(
                                        visible: !isShowingPastMeetings,
                                        child: SizedBox(
                                          height: 52,
                                          width: 200,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                    color: ColorConstants
                                                        .kPrimaryColor
                                                        .withOpacity(
                                                        0.05)),
                                              ),
                                              Container(
                                                  height: 2,
                                                  color:
                                                  ColorConstants
                                                      .kPrimaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 52,
                                        width: 200,
                                        child: Center(
                                          child: Text('Schedule Meeting',
                                              style: context.textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                color: !isShowingPastMeetings
                                                    ? ColorConstants
                                                    .kPrimaryColor
                                                    : ColorConstants
                                                    .kGray2,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
                    ElevatedButton(
                        onPressed: () =>
                        {
                          context.read<RolesCubit>().addRole()
                        },
                        child: const Text('Start a meeting'))
                  ],
                ),
              ),
              Table(columnWidths: const {
                1: FixedColumnWidth(300),
                //   2: FixedColumnWidth(115),
                //   3: FixedColumnWidth(209),
                //   4: FixedColumnWidth(209),
              }, children: [
                TableRow(
                    decoration: const BoxDecoration(color: Color(
                        0xFFF0F0F0)),
                    children: [
                      const TableCell(
                          verticalAlignment: TableCellVerticalAlignment
                              .middle,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Meeting'),
                          )),
                      const TableCell(
                          verticalAlignment: TableCellVerticalAlignment
                              .middle,
                          child: Center(child: Text('Organizer'))),

                      Visibility(
                        visible: isShowingPastMeetings,
                        child: const TableCell(
                            verticalAlignment:
                            TableCellVerticalAlignment.middle,
                            child: Center(
                                child: Text('Average Engagement'))),
                      ),

                      const TableCell(
                          verticalAlignment: TableCellVerticalAlignment
                              .middle,
                          child: Center(child: Text('Users'))),
                      Visibility(
                        visible: isShowingPastMeetings,
                        child: const TableCell(
                            verticalAlignment:
                            TableCellVerticalAlignment.middle,
                            child: Center(child: Text('Recorded'))),
                      ),
                      const TableCell(
                          verticalAlignment: TableCellVerticalAlignment
                              .middle,
                          child: Center(child: Text('Start'))),
                      const TableCell(
                          verticalAlignment: TableCellVerticalAlignment
                              .middle,
                          child: Text('End')),

                      // TableCell(
                      //     verticalAlignment: TableCellVerticalAlignment.middle,
                      //     child: imageSVGAsset('')!),
                    ])
              ]),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: const TableBorder(
                        horizontalInside: BorderSide(
                            width: 0.5,
                            color: ColorConstants.kGray5,
                            style: BorderStyle.solid)),
                    columnWidths: const {
                      1: FixedColumnWidth(300),
                      //   2: FixedColumnWidth(115),
                      //   3: FixedColumnWidth(209),
                      //   4: FixedColumnWidth(209),
                    },
                    children: [
                      for (var meeting in meetings!)
                        TableRow(children: [
                          TableCell(
                            verticalAlignment:
                            TableCellVerticalAlignment.middle,
                            child: Text(
                              meeting.callId.toString(),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          TableCell(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 27, bottom: 27),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: [
                                    // UserImage.medium(meeting.organizer.imageUrl),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meeting.organizer?? '',
                                            style: context.textTheme
                                                .displaySmall,
                                          ),
                                          Text('')
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          Visibility(
                            visible: isShowingPastMeetings,
                            child: TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: EngagementProgress(
                                  engagement: (meeting.averageEngagement * 100).toInt() ,
                                  width: double.maxFinite,
                                )),
                          ),
                          TableCell(
                              verticalAlignment:
                              TableCellVerticalAlignment.middle,
                          child:  Center(child: Text('${meeting.totalNumberOfUsers}'))),
                          //     child: isShowingPastMeetings
                          //         ? Center(child: Text('${meeting.users.length}'))
                          //         : Center(child: MembersWidget(users: meeting.users)))
                          // ,
                          Visibility(
                            visible: isShowingPastMeetings,
                            child: TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Center(
                                    child: imageSVGAsset(meeting.recorded??false
                                        ? 'badge_approved'
                                        : 'badge_waiting'))),
                          ),
                          TableCell(
                              verticalAlignment:
                              TableCellVerticalAlignment.middle,
                              child: Center(
                                  child: Column(
                                      children: [
                                  Text(
                                  '${meeting.meetingStart.day}.${meeting
                                      .meetingStart.month}.${meeting.meetingStart
                                      .year}'),
                                        Text(
                                            '${meeting.meetingStart.hour}:${meeting
                                                .meetingStart.minute}'),

                                      ],
                                  ))),


                          TableCell(
                              verticalAlignment:
                              TableCellVerticalAlignment.middle,
                              child: Visibility(
                                  visible: meeting.meetingEnd != null,
                                 child: Column(
                                    children: [
                                      Text('${meeting.meetingEnd?.day}.${meeting.meetingEnd?.month}.${meeting.meetingEnd?.year}'),
                                      Text(
                                          '${meeting.meetingEnd?.hour}:${meeting
                                              .meetingEnd?.minute}'),

                                    ],
                                  )




                                  )),
                        ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = Container(
        height: MediaQuery
            .of(context)
            .size
            .height - 85,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text(
                  'Meetings',
                  style: context.textTheme.headlineLarge,
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => showPastMeetings(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: isShowingPastMeetings,
                            child: SizedBox(
                              height: 52,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        color: ColorConstants
                                            .kPrimaryColor
                                            .withOpacity(0.05)),
                                  ),
                                  Container(
                                      height: 2,
                                      color: ColorConstants
                                          .kPrimaryColor),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 52,
                            child: Center(
                              child: Text('Past Meetings',
                                  style:
                                  context.textTheme.labelMedium?.copyWith(
                                    color: isShowingPastMeetings
                                        ? ColorConstants.kPrimaryColor
                                        : ColorConstants.kGray2,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => showScheduledMeetings(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: !isShowingPastMeetings,
                            child: SizedBox(
                              height: 52,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        color: ColorConstants
                                            .kPrimaryColor
                                            .withOpacity(0.05)),
                                  ),
                                  Container(
                                      height: 2,
                                      color: ColorConstants
                                          .kPrimaryColor),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 52,
                            child: Center(
                              child: Text('Schedule Meeting',
                                  style:
                                  context.textTheme.labelMedium?.copyWith(
                                    color: !isShowingPastMeetings
                                        ? ColorConstants.kPrimaryColor
                                        : ColorConstants.kGray2,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: Column(
                    children: [
                      Expanded(
                          child: ListView.builder(
                              itemCount: meetings?.length,
                              itemBuilder: (BuildContext context,
                                  int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10,
                                      bottom: 20,
                                      right: 10,
                                      left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${index + 1}.',
                                            style: context.textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Expanded(
                                            child: Text(
                                                meetings![index].callId.toString(),
                                                style: context.textTheme
                                                    .titleSmall),
                                          ),

                                          Visibility(
                                              visible: !isShowingPastMeetings,
                                              child: Text(
                                                  '${meetings![index]
                                                      .meetingStart?.day}.${meetings?[index]
                                                      .meetingStart?.month}.${meetings![index].meetingStart?.year}')),
                                        ],
                                      ),
                                      const SizedBox(height: 10,),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                                meetings![index].organizer??''),
                                            const SizedBox(height: 10,),

                                            Visibility(
                                              visible: isShowingPastMeetings,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                          child:
                                                          Text(
                                                              'Duration: XX min}')),
                                                      const Text(
                                                          'Recorded: '),
                                                      imageSVGAsset(
                                                          meetings![index]
                                                              .recorded??false
                                                              ? 'badge_approved'
                                                              : 'badge_waiting') as Widget
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,),
                                                  EngagementProgress(
                                                    engagement: (meetings![index].averageEngagement! * 100) as int,
                                                    width: double
                                                        .maxFinite,
                                                  )
                                                ],
                                              ),
                                            ),

                                            Visibility(
                                              visible: !isShowingPastMeetings,
                                              child: Column(

                                                children: [
                                                  Text(
                                                      'Start: ${meetings![index]
                                                          .meetingStart?.hour}:${meetings![index].meetingStart?.minute}'),
                                                  const SizedBox(
                                                    height: 10,),
                                                  Text(
                                                      'Start: ${meetings![index]
                                                          .meetingEnd?.hour}:${meetings![index].meetingEnd?.minute}'),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })),
                    ],
                  ))
            ],
          ),
        ),
        // Expanded(
        //   child: SingleChildScrollView(
        //       scrollDirection: Axis.vertical,
        //       child: ListView.builder(itemBuilder: (context, index) =>
        //          Text(meetings[index].name)
        //       )),
        // ),

        // Expanded(
        //   child: SingleChildScrollView(
        //       scrollDirection: Axis.vertical,
        //       child: ListView.builder(itemBuilder: (context, index) =>
        //          Text(meetings[index].name)
        //       )),
      );
    }



    return BlocConsumer<MeetingCubit, MeetingState>(
        builder: (context, state) {

          // if (state is MeetingsIsLoading)
          //   return Text('data');

        return LoadingOverlay(
          loading: state is MeetingsIsLoading,
          child: Column(
            children: [body],
          ),
        );




        }, listener: _onMettingsState);
  }
}