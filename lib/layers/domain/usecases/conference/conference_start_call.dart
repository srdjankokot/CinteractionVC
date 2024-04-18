import '../../entities/api_response.dart';
import '../../repos/conference_repo.dart';

class ConferenceStartCall {

  ConferenceStartCall({required  this.repo});

  final ConferenceRepo repo;

  Future<ApiResponse<int>> call() {
     return repo.startCall();
  }
}