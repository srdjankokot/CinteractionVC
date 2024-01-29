
import 'package:cinteraction_vc/features/groups/model/group.dart';

import '../../profile/model/user.dart';
import '../model/meeting.dart';
import '../provider/meetings_provider.dart';

class MeetingRepository{
  MeetingRepository({
    required this.meetingProvider
});

  final MeetingProvider meetingProvider;


  Stream<List<Meeting>> getMeetingStream() {
    return meetingProvider.getMeetingStream();
  }


  Future<void> getListOfMeetings() async
  {
    meetingProvider.getMeetings();
  }

  Future<void> getListOfScheduledMeetings() async
  {
    meetingProvider.getScheduledMeetings();
  }


  Future<void> addMeeting() async
  {
    meetingProvider.addMeeting();
  }

}