import 'dart:async';

import 'package:cinteraction_vc/core/io/network/handlers/get_meetings_handler.dart';
import 'package:cinteraction_vc/features/meetings/model/meeting_response.dart';

import '../model/meeting.dart';

class MeetingProvider {
  MeetingProvider();

  final _meetingStream = StreamController<List<Meeting>>.broadcast();

  Stream<List<Meeting>> getMeetingStream() => _meetingStream.stream;

  MeetingResponse meetings = MeetingResponse(pastMeetings: List.empty(), scheduleMeetings: List.empty());

  Future<void> getMeetings() async {
    await getMeetingFromServer();
    _meetingStream.add(meetings.pastMeetings);
  }

  Future<void> getScheduledMeetings() async {
    await getMeetingFromServer();
    _meetingStream.add(meetings.scheduleMeetings);
  }

  Future<void> getMeetingFromServer() async{
    if(meetings.pastMeetings.isEmpty || meetings.scheduleMeetings.isEmpty){
      GetMeetings handler = GetMeetings();
      var result = await handler.execute();
      meetings = MeetingResponse.fromJson(result!);
    }
  }


  Future<void> addMeeting() async {
    // await _networkDelay();
    // _mockMeetings = [..._mockMeetings, _mockMeeting];
    // _meetingStream.add(_mockMeetings);
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
