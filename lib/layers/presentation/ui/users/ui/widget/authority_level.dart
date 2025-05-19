import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/color.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthorityLevel extends StatelessWidget{

  final int level;

  const AuthorityLevel({super.key, required this.level});

  @override
  Widget build(BuildContext context) {

    var label = level == 3? 'HIGH': level == 2? 'MEDIUM': 'LOW';
    var color = level == 3? ColorConstants.kStateSuccess: level == 2? ColorUtil.getColorScheme(context).primaryFixed: ColorUtil.getColorScheme(context).primary;

    return SizedBox(
        height: 23,
      child: Row(
        children: [
          Text(label, style: context.textTheme.labelMedium,),
          const SizedBox(width: 8,),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: 8,
                    color: ColorUtil.getColorScheme(context).surface.withOpacitySafe( 0.5),
                  ),

                  Container(
                    height: 12,
                    width: 8,
                    color: color,
                  )
                ],
              ),

              const SizedBox(
                width: 2,
              ),

              Stack(
                children: [
                  Container(
                    height: 12,
                    width: 8,
                    color: ColorUtil.getColorScheme(context).surface.withOpacitySafe( 0.5),
                  ),

                  Visibility(
                    visible: level>=2,
                    child: Container(
                      height: 12,
                      width: 8,
                      color: color,
                    ),
                  )
                ],
              ),

              const SizedBox(
                width: 2,
              ),

              Stack(
                children: [
                  Container(
                    height: 12,
                    width: 8,
                    color: ColorUtil.getColorScheme(context).surface.withOpacitySafe( 0.5),
                  ),
                  Visibility(
                    visible: level>=3,
                    child: Container(
                      height: 12,
                      width: 8,
                      color: color,
                    )
                  ),
                ],
              )


            ],
          )
        ],
      ),
    );
  }

}