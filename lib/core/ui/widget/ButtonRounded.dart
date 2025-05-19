import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';
import '../../extension/color.dart';

class ButtonRounded extends StatelessWidget {


  const ButtonRounded(this.textbutton, {super.key});
  final String textbutton;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 68.0,
      child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Color(0xFFF1471C)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(71.0),
                  ))),
          child:  Text(
            textbutton,
            textAlign: TextAlign.center,
            style:   TextStyle(
              color: ColorUtil.getColorScheme(context).surface,
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          )),


    );


    return TextButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFFF1471C)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(71.0),
            ))),
        child:  Text(
          'Log in',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorUtil.getColorScheme(context).surface,
            fontSize: 24,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            height: 0.04,
          ),
        ));

    return SizedBox(
      width: double.infinity,
      height: 68,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: double.infinity,
              height: 68,
              decoration: ShapeDecoration(
                color: Color(0xFFF1471C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(71),
                ),
              ),
            ),
          ),
           SizedBox(
            width: double.infinity,
            height: 68,
            child: Text(
              'Log in',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorUtil.getColorScheme(context).surface,
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
