import '../entities/api_response.dart';
import '../entities/meeting.dart';

abstract class HomeRepo
{
  Future<ApiResponse<bool>> scheduleMeeting({
    required String name,
    required String description,
    required String tag,
    required DateTime date,
  });

  Future<ApiResponse<Meeting?>> getNextMeeting();
}