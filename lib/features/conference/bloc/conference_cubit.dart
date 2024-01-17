import 'package:cinteraction_vc/features/conference/bloc/conference_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logger/loggy_types.dart';

class ConferenceCubit extends Cubit<ConferenceState> with BlocLoggy {
  ConferenceCubit() : super(const ConferenceInitial());

}