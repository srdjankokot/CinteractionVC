
import 'package:cinteraction_vc/features/dashboard/ui/widget/metric_chart.dart';
import 'package:cinteraction_vc/features/dashboard/ui/widget/new_groups_widget.dart';
import 'package:cinteraction_vc/features/dashboard/ui/widget/new_users_widget.dart';
import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';
import '../../insights/ui/widget/bar_chart.dart';
import '../../insights/ui/widget/pie_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.kGrey100,
        body: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                  LayoutBuilder(builder: (context, constraints) {

                    var minWidth = 400;
                    var space = 20.0;
                    var containerWidth = constraints.maxWidth * 1/4 - space*3/4;
                    if(constraints.maxWidth <= minWidth * 4) {
                      containerWidth = constraints.maxWidth * 1/3 - space*2/3;
                    }
                    if(constraints.maxWidth <= minWidth * 3) {
                      containerWidth = constraints.maxWidth * 1/2 - space/2;
                    }
                    if(constraints.maxWidth <= minWidth * 2) {
                      containerWidth = constraints.maxWidth;
                    }

                    return Wrap(
                      spacing: space,
                      runSpacing: space,
                      children: [
                        SizedBox(
                          width: containerWidth,
                          child: const MetricGraph(
                              title: 'Meetings attended',
                              values: [18, 15, 17, 13, 18, 20]),
                        ),

                        SizedBox(
                          width: containerWidth,
                          child: const MetricGraph(
                              title: 'Meetings started',
                              values: [6, 6.5, 8, 7.2, 6.8, 8]),
                        ),

                        SizedBox(
                          width: containerWidth,
                          child: const MetricGraph(
                              title: 'Average users per meeting',
                              values: [54, 53.2, 53, 52.5, 53.5, 52.4, 52]),
                        ),

                        SizedBox(
                          width: containerWidth,
                          child: const MetricGraph(
                              title: 'Session duration',
                              values: [40, 48, 58, 55, 50, 59, 63]),
                        ),
                      ],
                    );
                  }),
                const SizedBox(
                  height: 20,
                ),
                  LayoutBuilder(builder: (context, constraints){
                    var minWidth = 400;
                    var space = 20.0;
                    var containerWidth = constraints.maxWidth * 1/2 - space/2;
                    if(constraints.maxWidth <= minWidth * 2) {
                      containerWidth = constraints.maxWidth;
                    }
                    return  Wrap(
                      spacing: space,
                      runSpacing: space,
                      children: [
                        SizedBox(
                          width: containerWidth,
                          child: const PieChartStats(
                            values: [NameValueClass(name: '(20) Realized meetings', value: 72), NameValueClass(name: '(8) Missed', value: 28)],
                            title: 'My realized meetings',
                            colors: [
                              ColorConstants.kStateSuccess,
                              ColorConstants.kGrey100
                            ],
                          ),
                        ),

                        SizedBox(
                          width: containerWidth,
                          child: const PieChartStats(
                              values: [NameValueClass(name: '(687) Realized meetings', value: 77), NameValueClass(name: '(158) Missed', value: 23)],
                              title: 'Realized meetings by users',
                              colors: [
                                ColorConstants.kStateInfo,
                                ColorConstants.kGrey100
                              ]),
                        ),
                      ],
                    );
    }),

                const SizedBox(
                  height: 20,
                ),

                LayoutBuilder(builder: (context, constraints) {
                  var minWidth = 400;
                  var space = 20.0;
                  var containerWidth = constraints.maxWidth * 1/2 - space/2;
                  if(constraints.maxWidth <= minWidth * 2) {
                    containerWidth = constraints.maxWidth;
                  }

                  return Wrap(
                    spacing: space,
                    runSpacing: space,
                    children: [

                      Container(
                        height: 350,
                        width: containerWidth,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        child: const NewUsersWidget(),
                      ),


                      Container(
                        height: 350,
                        width: containerWidth,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const  NewGroupsWidget(),
                      ),

                    ],
                  );
                }),

                const SizedBox(
                  height: 20,
                ),
                const GetBarChart(
                  title: 'Total Engagement',
                  color: ColorConstants.kStateInfo,
                )
              ],
            )));
  }
}

