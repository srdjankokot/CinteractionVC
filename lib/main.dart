import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'google_meet/video_room.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ''
          'CinteractionVC',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
      // home: VideoRoomPage("999888", "Test"),
    );
  }
}

class MyHomePage extends StatefulWidget {

  final String title = 'Cinteraction Virtual Classroom';

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String room = "1234567";
  String displayName = "";

  void _entryVideoRoom() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => VideoRoomPage(room:  int.parse(room), displayName: displayName)));
  }

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
              child: const Text('Video Room'),
            ),
          ],
        ),
      )),
    );
  }
}
