import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePopup extends StatefulWidget {
  const SchedulePopup({Key? key}) : super(key: key);



  @override
  State<SchedulePopup> createState() => _SchedulePopupState();


}

class _SchedulePopupState extends State<SchedulePopup> {
  DateTime date = DateTime.now();
  TimeOfDay time = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    date.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {

    TextEditingController _textFieldController = TextEditingController();

    return AlertDialog(
      title: const Text('Schedule a meeting'),
      content:  Wrap(
        children: [
          Column(
            children: [
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Event Name"),
              ),

              const SizedBox(height: 20,),
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Event Description"),
              ),
              const SizedBox(height: 20,),
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Tag Name"),
              ),

              const SizedBox(height: 20,),

              Row(
                children: [
                  Text('Date: '),

                  ElevatedButton(onPressed: () async {
                    await showDatePicker(context: context, firstDate: DateTime(2024), lastDate: DateTime(2025), ).then((selectedDate)
                    {
                      setState(() {
                        date = selectedDate!;
                      });
                    });
                  }, child: Text(DateFormat('dd/MM/yyyy').format(date))),

                  SizedBox(width: 50,),


                ],
              ),

              const SizedBox(height: 20,),
              Row(
                children: [
                  Text('Time: '),

                  ElevatedButton(onPressed: () async {

                    await showTimePicker(context: context, initialTime: time).then((selectedTime)  {
                      setState(() {
                        time = selectedTime!;
                      });
                    });
                  }, child: Text('${time.hour}:${time.minute}'))

                ],
              )





            ],
          ),
        ],
      ),

      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Text('Schedule'),
          onPressed: () {
            // print(_textFieldController.text);
            Navigator.pop(context);
            // context.pushNamed('meeting',
            //     pathParameters: {
            //       'roomId': _textFieldController.text,
            //     },
            //     extra: context.getCurrentUser?.name);

            // context.go("${AppRoute.meeting.path}/${_textFieldController.text}");
          },
        ),
      ],
    );
  }


}


