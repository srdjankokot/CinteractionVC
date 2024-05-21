import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/data/repos/conference_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/dashboard_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/meetings_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/source/network/api_impl.dart';
import 'package:cinteraction_vc/layers/domain/repos/conference_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/dashboard_repo.dart';
import 'package:cinteraction_vc/layers/domain/repos/home_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/dashboard/dashboard_usecases.dart';
import 'package:cinteraction_vc/layers/domain/usecases/home/home_use_cases.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../layers/data/repos/auth_repo_impl.dart';
import '../../layers/data/repos/home_repo_impl.dart';
import '../../layers/data/source/local/local_storage.dart';
import '../../layers/domain/repos/auth_repo.dart';
import '../../layers/domain/repos/meetings_repo.dart';
import '../../layers/domain/source/api.dart';
import '../../layers/domain/usecases/auth/auth_usecases.dart';
import '../../layers/domain/usecases/conference/conference_usecases.dart';
import '../../layers/domain/usecases/meeting/meeting_use_cases.dart';
import '../../layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../layers/presentation/cubit/home/home_cubit.dart';
import '../../layers/presentation/cubit/meetings/meetings_cubit.dart';
import '../../layers/presentation/cubit/profile/profile_cubit.dart';
import '../../layers/presentation/cubit/users/users_cubit.dart';
import '../../layers/presentation/ui/groups/provider/groups_provider.dart';
import '../../layers/presentation/ui/groups/repository/groups_repository.dart';
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

            return statusCode >= 200 && statusCode < 300;
            if (statusCode == 422) {
              // your http status code
              return true;
            } else {

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
  getIt.registerFactory<MeetingRepo>(() => MeetingRepoImpl(api: getIt()));
  getIt.registerFactory<HomeRepo>(() => HomeRepoImpl(api: getIt()));
  getIt.registerFactory<DashboardRepo>(()=> DashboardRepoImpl(api: getIt()));


  getIt.registerFactory<UsersProvider>(() => UsersProvider());
  getIt.registerFactory<GroupsProvider>(() => GroupsProvider());
  getIt.registerFactory<RolesProvider>(() => RolesProvider());
  getIt.registerFactory<GroupsRepository>(() => GroupsRepository(groupsProvider: getIt()));
  getIt.registerFactory<UsersRepository>(() => UsersRepository(usersProvider: getIt()));

  getIt.registerFactory<RolesRepository>(() => RolesRepository(rolesProvider: getIt()));
  getIt.registerSingleton<UsersCubit>(UsersCubit(groupRepository: getIt(),usersRepository: getIt()));

  getIt.registerFactory(() => AuthUseCases());
  getIt.registerFactory(() => ConferenceUseCases(repo: getIt()));
  getIt.registerFactory(() => MeetingUseCases(repo: getIt()));
  getIt.registerFactory(() => HomeUseCases(repo: getIt()));
  getIt.registerFactory(() => DashboardUseCases());

  getIt.registerSingleton<ProfileProvider>(ProfileProvider());
  // getIt.registerFactory<UsersProvider>(() => UsersProvider());

  // getIt.registerFactory<UsersRepository>(() => UsersRepository(usersProvider: getIt()));
  getIt.registerSingleton<ProfileRepository>(ProfileRepository(profileProvider: getIt()));



  getIt.registerSingleton<ProfileCubit>(ProfileCubit(userRepository: getIt()));
  getIt.registerFactory<HomeCubit>(()=>HomeCubit(homeUseCases: getIt()));
  getIt.registerFactory<MeetingCubit>(()=>MeetingCubit(meetingUseCases: getIt()));
  getIt.registerFactory<DashboardCubit>(()=>DashboardCubit(dashboardUseCases: getIt()));





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
