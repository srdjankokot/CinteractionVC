import 'dart:io';

import 'package:cinteraction_vc/video_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Janus Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // home: MyHomePage(title: 'Flutter Janus Demo Home Page'),
      home: VideoRoomPage("1234567", "Test"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _entryVideoRoom() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                VideoRoomPage(room, displayName)));
  }

  String room = "1234567";
  String displayName = "";

  var roomTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    roomTextController.value = TextEditingValue(text: room);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            TextField(
              onChanged: (text) {
                displayName = text;
              },
              decoration:  const InputDecoration(labelText: "Enter display name"),
            ),

            TextField(
                controller: roomTextController,
                onChanged: (text) {
                  room = text;
                },
                decoration:  const InputDecoration(labelText: "Enter room number"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]), // Only numbers can be entered),

            TextButton(
              onPressed: _entryVideoRoom,
              child: Text('Video Room'),
            ),
          ],
        ),
      )),
    );
  }
}
