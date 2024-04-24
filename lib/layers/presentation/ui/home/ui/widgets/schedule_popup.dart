import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/ui/input/input_field.dart';

class SchedulePopup extends StatelessWidget {
  const SchedulePopup({super.key, required this.context});
  final BuildContext context;
  @override
  Widget build(BuildContext innerContext) {

    TextEditingController nameFieldController = TextEditingController();
    TextEditingController descFieldController = TextEditingController();
    TextEditingController tagNameFieldController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocProvider.value(
      value: context.watch<HomeCubit>(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (c, s){
            print('state');
        },
          builder: (context, state) => AlertDialog(
            content: AlertDialog(
              title: const Text('Schedule a meeting'),
              content:  Form(
                key: formKey,
                child: Wrap(
                  children: [
                    Column(
                      children: [
                        InputField.name(
                            label: 'Enter your full name',
                            controller: nameFieldController,
                            textInputAction:
                            TextInputAction.next),
                        // TextField(
                        //   controller: nameFieldController,
                        //   decoration: const InputDecoration(hintText: "Event Name"),
                        // ),

                        const SizedBox(height: 20,),
                        TextField(
                          controller: descFieldController,
                          decoration: const InputDecoration(hintText: "Event Description"),
                        ),
                        const SizedBox(height: 20,),
                        TextField(
                          controller: tagNameFieldController,
                          decoration: const InputDecoration(hintText: "Tag Name"),
                        ),

                        const SizedBox(height: 20,),

                        Row(
                          children: [
                            const Text('Date: '),
                            ElevatedButton(onPressed: () async {
                              await showDatePicker(context: context, firstDate: DateTime.now().add(const Duration(hours: 1)), lastDate: DateTime.now().add(const Duration(days: 90)), ).then((selectedDate)
                              {
                                context.read<HomeCubit>().setScheduleDate(selectedDate!);
                              });
                            }, child: Text(DateFormat('dd/MM/yyyy').format(state.scheduleStartDateTime?? DateTime.now()))),
                            const SizedBox(width: 50,),
                          ],
                        ),

                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            const Text('Time: '),

                            ElevatedButton(onPressed: () async {

                              await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(state.scheduleStartDateTime!)).then((selectedTime)  {
                                context.read<HomeCubit>().setScheduleTime(selectedTime);
                              });
                            }, child: Text(DateFormat('HH:mm').format(state.scheduleStartDateTime!)))
                          ],
                        )
                      ],
                    ),
                  ],
                ),
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
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    // print(_textFieldController.text);
                    Navigator.pop(context);
                    context.read<HomeCubit>().scheduleMeeting(nameFieldController.value.text, descFieldController.value.text, tagNameFieldController.value.text);

                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}