import 'package:cinteraction_vc/features/meetings/ui/widget/meeting_list_layout.dart';
import 'package:cinteraction_vc/features/roles/ui/widget/role_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ui/widget/loading_overlay.dart';
import '../bloc/meetings_cubit.dart';
import '../model/meeting.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  MeetingsPageState createState() => MeetingsPageState();
}

class MeetingsPageState extends State<MeetingsPage> {
  late List<Meeting>? meetingList = [];


  @override
  void initState(){
    super.initState();
    context.read<MeetingCubit>().loadMeetings();

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MeetingCubit, MeetingState>(
        builder: (context, state) {
          final Widget body;

          body = Material(
            child: Column(
              children: [
                MeetingListLayout(meetings: meetingList!),
              ],
            ),
          );

          // return const Text('No Users');

          return LoadingOverlay(
              loading: state is MeetingsIsLoading,
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                  child: body,
              ));
        },
        listener: _onUsersState);
  }

  void _onUsersState(BuildContext context, MeetingState state) {
    if (state is MeetingLoaded) {
      setState(() {
        meetingList = state.meetings;
      });
    }
  }
}
