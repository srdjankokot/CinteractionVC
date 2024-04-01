import 'package:cinteraction_vc/assets/strings/Strings.dart';
import 'package:cinteraction_vc/features/login_page/login_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../conference/video_room.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  LoginView();

    //
    // void entryVideoRoom({required LoginStates state}) {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (BuildContext context) =>
    //               VideoRoomPage(
    //                   room: state.roomId)));
    // }

    LoginBloc bloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.getText(StringKey.title, context)),
        ),
        body: BlocBuilder<LoginBloc, LoginStates>(
          bloc: bloc,
          builder: (context, state) {

            return Center(
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (text) {
                          bloc.add(DisplayNameChangedEvent(text));
                        },
                        decoration: InputDecoration(
                            labelText: Strings.getText(StringKey.enterDisplayNameTitle, context)),
                      ),

                      TextFormField(
                        initialValue: state.roomId.toString(),
                          onChanged: (text) {
                            bloc.add(RoomIdChangedEvent(int.parse(text)));
                          },
                          decoration: InputDecoration(
                              labelText: Strings.getText(StringKey.enterRoomIdTitle, context)),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ]), // Only numbers can be entered),

                      // TextButton(
                      //   onPressed: () => entryVideoRoom(state: state),
                      //   child:  Text(Strings.getText(StringKey.enterVideoRoomButton, context)),
                      // ),

                      Text(state.displayName ?? ""),
                      Text(state.roomId.toString())
                    ],
                  ),
                ));
          },
        ));
  }
}
