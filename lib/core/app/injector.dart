import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/data/repos/conference_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/source/network/api_impl.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../layers/data/repos/auth_repo_impl.dart';
import '../../layers/data/source/local/local_storage.dart';
import '../../layers/domain/repos/auth_repo.dart';
import '../../layers/domain/source/api.dart';
import '../../layers/domain/usecases/auth/auth_usecases.dart';
import '../../layers/domain/usecases/conference/conference_usecases.dart';
import '../../layers/presentation/cubit/profile/profile_cubit.dart';
import '../../layers/presentation/cubit/users/users_cubit.dart';
import '../../layers/presentation/ui/groups/provider/groups_provider.dart';
import '../../layers/presentation/ui/groups/repository/groups_repository.dart';
import '../../layers/presentation/ui/meetings/provider/meetings_provider.dart';
import '../../layers/presentation/ui/meetings/repository/meetings_repository.dart';
import '../../layers/presentation/ui/profile/provider/user_mock_provider.dart';
import '../../layers/presentation/ui/profile/repository/profile_repository.dart';
import '../../layers/presentation/ui/roles/provider/roles_provider.dart';
import '../../layers/presentation/ui/roles/repository/roles_repository.dart';
import '../../layers/presentation/ui/users/provider/users_provider.dart';
import '../../layers/presentation/ui/users/repository/users_repository.dart';
import '../../main.dart';

GetIt getIt = GetIt.instance;

Future<void> initializeGetIt() async {

  getIt.registerFactoryAsync<Dio>(() async {
    final accessToken = await getAccessToken();
    return Dio(
        BaseOptions(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization' :  accessToken
          },
          validateStatus: (statusCode) {
            if (statusCode == null) {
              return false;
            }
            if (statusCode == 422) {
              // your http status code
              return true;
            } else {
              return statusCode >= 200 && statusCode < 300;
            }


          },
        ));
  });

  // getIt.registerFactory<Dio>(() => Dio(
  //     BaseOptions(
  //   headers: {
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //     'Authorization' :  getAccessToken()
  //   },
  //   validateStatus: (statusCode) {
  //     if (statusCode == null) {
  //       return false;
  //     }
  //     if (statusCode == 422) {
  //       // your http status code
  //       return true;
  //     } else {
  //       return statusCode >= 200 && statusCode < 300;
  //     }
  //   },
  // )));

  getIt.registerSingleton<Api>(ApiImpl());


  getIt.registerFactory<LocalStorage>(() => LocalStorageImpl(sharedPreferences: sharedPref),);


  getIt.registerFactory<AuthRepo>(() => AuthRepoImpl(api: getIt()),);
  getIt.registerFactory<ConferenceRepo>(() => ConferenceRepoImpl(api: getIt()));

  getIt.registerFactory<UsersProvider>(() => UsersProvider());
  getIt.registerFactory<GroupsProvider>(() => GroupsProvider());
  getIt.registerFactory<MeetingProvider>(() => MeetingProvider());
  getIt.registerFactory<RolesProvider>(() => RolesProvider());
  getIt.registerFactory<GroupsRepository>(() => GroupsRepository(groupsProvider: getIt()));
  getIt.registerFactory<UsersRepository>(() => UsersRepository(usersProvider: getIt()));
  getIt.registerFactory<MeetingRepository>(() => MeetingRepository(meetingProvider: getIt()));
  getIt.registerFactory<RolesRepository>(() => RolesRepository(rolesProvider: getIt()));
  getIt.registerSingleton<UsersCubit>(UsersCubit(groupRepository: getIt(),usersRepository: getIt()));

  getIt.registerFactory(() => AuthUseCases());
  getIt.registerFactory(() => ConferenceUseCases(repo: getIt()));

  getIt.registerSingleton<ProfileProvider>(ProfileProvider());
  // getIt.registerFactory<UsersProvider>(() => UsersProvider());

  // getIt.registerFactory<UsersRepository>(() => UsersRepository(usersProvider: getIt()));
  getIt.registerSingleton<ProfileRepository>(ProfileRepository(profileProvider: getIt()));



  getIt.registerSingleton<ProfileCubit>(ProfileCubit(userRepository: getIt()));


  Map<String, dynamic>? getHeader()
  {




    return {
      'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization' : getAccessToken()
  };

    return null;
  }

}
