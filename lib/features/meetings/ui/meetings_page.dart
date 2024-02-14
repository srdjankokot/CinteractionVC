import 'package:cinteraction_vc/features/meetings/ui/widget/meeting_list_layout.dart';
import 'package:cinteraction_vc/features/roles/ui/widget/role_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ui/widget/loading_overlay.dart';
import '../bloc/meetings_cubit.dart';
import '../model/meeting.dart';

class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      child:
        MeetingListLayout(),

    );
  }
}
