import 'package:flutter/material.dart';

import '../../extension/color.dart';

class ContentLayoutWeb extends StatelessWidget{

  final Widget child;

  const ContentLayoutWeb({super.key, required this.child});

  @override
  Widget build(BuildContext context) {


    return Expanded(
        child: Container(
          color: ColorUtil.getColor(context)!.kGrey[100],
          child: Stack(
              children: [
                Positioned(
                    right: 20,
                    left: 20,
                    top: 20,
                    bottom: 20,
                    child: Container(
                        decoration: BoxDecoration(
                            color: ColorUtil.getColorScheme(context).surface,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: child,
                        )

                    )

                )
              ]

          ),
        ));
  }

}
