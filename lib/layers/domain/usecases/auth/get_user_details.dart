import '../../../../core/app/injector.dart';
import '../../../data/dto/user_dto.dart';
import '../../entities/api_response.dart';
import '../../repos/auth_repo.dart';

class GetUserDetails{
  GetUserDetails();

  final AuthRepo _repo = getIt.get<AuthRepo>();

  Future<ApiResponse<UserDto?>> call(String token) async{
    return await _repo.getUserDetails(token);
  }
}