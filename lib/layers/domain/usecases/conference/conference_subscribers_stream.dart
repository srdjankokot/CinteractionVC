
import '../../../../core/io/network/models/participant.dart';
import '../../repos/conference_repo.dart';

class GetSubscriberStream
{
  GetSubscriberStream({required  this.repo});

  final ConferenceRepo repo;
  Stream<List<Participant>>  call()
  {
    return repo.getSubscribersStream();
  }
}