import 'package:cinteraction_vc/layers/presentation/cubit/app/app_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/io/network/models/data_channel_command.dart';
import '../../../../core/logger/loggy_types.dart';

class AppCubit extends Cubit<AppState> with BlocLoggy {

  AppCubit() : super(const AppState.initial()) {
    load();
  }


  void load()
  {

  }

  Future<void> changeUserStatus(UserStatus status)
  async {
    emit(state.copyWith(userStatus: status));
  }

}