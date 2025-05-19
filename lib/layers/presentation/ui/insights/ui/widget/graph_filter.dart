import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/app/style.dart';
import '../../../../../../core/extension/color.dart';


const List<String> list = <String>['Jan', 'Feb', 'Mar', 'Apr'];
const List<String> listUsers = <String>['All Users', 'Olivia Rhyw', 'Ana Wright', 'Alisa Hester'];


class GraphFilter extends StatefulWidget{

  @override
  GraphFilterState createState() => GraphFilterState();
}

class GraphFilterState extends State<GraphFilter> {

  String dropdownUserValue = listUsers.first;
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //
        Row(
          children: [
            Text(
              'Users: ',
              style: context.textTheme.bodySmall,
            ),
            DropdownButton<String>(
              value: dropdownUserValue,
              icon: imageSVGAsset('drop_down_arrow'),
              elevation: 0,
              style: context.textTheme.displaySmall,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownUserValue = newValue!;
                });
              },

              items: listUsers.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),

            ),
          ],
        ),

        const SizedBox(width: 46,),
        Container(
          padding: const EdgeInsets.only( right: 5),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side:  BorderSide(width: 1, color: ColorUtil.getColorScheme(context).outline),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          child: Row(
              children: [
                Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(8),
                        child: imageSVGAsset('icon_calendar') as Widget),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                      color: ColorUtil.getColorScheme(context).outline,
                    ),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: imageSVGAsset('drop_down_arrow'),
                      elevation: 0,
                      style: context.textTheme.displaySmall?.copyWith(
                          color: ColorUtil.getColorScheme(context).primary                      ),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },

                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),

                    ),
                  ],
                ),
              ],
            ),
          ),

      ],
    );




      ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: ColorUtil.getColor(context)!.kBlue.withOpacity(.1),
              border:  Border(
                left: BorderSide(
                  color: ColorUtil.getColor(context)!.kBlue,
                  width: 8,
                ),
              ),
            ),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon:  Icon(Icons.arrow_forward_ios, size: 12),
              elevation: 0,
              style:  TextStyle(color: ColorUtil.getColor(context)!.kBlue),
              underline: const SizedBox(),
              onChanged: (String? newValue) {},

              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),

            ),)
      );
  }
}
