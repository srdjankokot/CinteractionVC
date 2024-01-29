import 'dart:async';
import 'dart:math';

import '../../profile/model/user.dart';
import '../model/meeting.dart';

List<Meeting> _mockMeetings = [
  Meeting(
      name: 'introduction',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),

  Meeting(
      name: 'Video Production',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),
  Meeting(
      name: 'Video Gaming 2',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),
  Meeting(
      name: 'Video Gaming 3',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),
  Meeting(
      name: 'UX/UI Essentials',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),
];


List<Meeting> _mockScheduledMeetings = [
  Meeting(
      name: 'introduction',
      organizer: _organizer,
      users: [_organizer, _organizer, _organizer, _organizer],
      avgEngagement: Random().nextInt(100),
      recorded: true,
      start: DateTime.now(),
      end: DateTime.now()),
];

Meeting get _mockMeeting => Meeting(
    name: 'introduction',
    organizer: _organizer,
    users: [_organizer, _organizer, _organizer, _organizer],
    avgEngagement: Random().nextInt(100),
    recorded: true,
    start: DateTime.now(),
    end: DateTime.now());
// Group(id: 'group-id', name: 'Video production II', userList: _mockUsers);

User get _organizer => User(
      id: 'john-doe',
      name: 'John Doe',
      email: 'john@test.com',
      imageUrl:
          'https://images.unsplash.com/photo-1528892952291-009c663ce843?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=200&q=80',
      createdAt: DateTime.now(),
    );

class MeetingProvider {
  MeetingProvider();

  final _meetingStream = StreamController<List<Meeting>>.broadcast();

  Stream<List<Meeting>> getMeetingStream() => _meetingStream.stream;

  Future<void> getMeetings() async {
    // await _networkDelay();
    _meetingStream.add(_mockMeetings);
  }

  Future<void> getScheduledMeetings() async {
    // await _networkDelay();
    _meetingStream.add(_mockScheduledMeetings);
  }

  Future<void> addMeeting() async {
    // await _networkDelay();
    _mockMeetings = [..._mockMeetings, _mockMeeting];
    _meetingStream.add(_mockMeetings);
  }

  /// Simulate network delay
  Future<void> _networkDelay() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
