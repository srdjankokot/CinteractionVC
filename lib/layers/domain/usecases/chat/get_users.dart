import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';

class GetUsersStream
{
  GetUsersStream({required  this.repo});

  final ChatRepo repo;
  Stream<List<UserDto>> call()
  {
    return repo.getUsersStream();
  }
}