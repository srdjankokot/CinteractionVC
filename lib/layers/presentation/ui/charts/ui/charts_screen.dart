import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/all_users_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/user_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
              backgroundColor: ColorConstants.kGrey100,
              body: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      // Large Chart for All Users
                      const AllUsersChart(),

                      const SizedBox(
                        height: 30,
                      ),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          'Individual Results',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.kSecondaryColor,
                              ),
                        ),
                      ),

                      // Individual User Charts
                      LayoutBuilder(builder: (context, constraints) {
                        var minWidth = 400;
                        var space = 20.0;
                        var containerWidth =
                            constraints.maxWidth * 1 / 3 - space * 2 / 3;

                        if (constraints.maxWidth <= minWidth * 3) {
                          containerWidth =
                              constraints.maxWidth * 1 / 2 - space / 2;
                        }
                        if (constraints.maxWidth <= minWidth * 2) {
                          containerWidth = constraints.maxWidth;
                        }

                        return Wrap(
                          spacing: space,
                          runSpacing: space,
                          children: [
                            SizedBox(
                              width: containerWidth,
                              child: UserChartCard(
                                userName: 'KAMERA 1',
                                performanceValue: 70,
                                chartData: const [
                                  25,
                                  20,
                                  18,
                                  15,
                                  12,
                                  10,
                                  25,
                                  45,
                                  72,
                                  85,
                                  88,
                                  90,
                                  82,
                                  75,
                                  80,
                                  85,
                                  78,
                                  70,
                                  55,
                                  45,
                                  35,
                                  28,
                                  22,
                                  18
                                ],
                              ),
                            ),
                            SizedBox(
                              width: containerWidth,
                              child: UserChartCard(
                                userName: 'KAMERA 2',
                                performanceValue: 85,
                                chartData: const [
                                  30,
                                  25,
                                  22,
                                  18,
                                  15,
                                  12,
                                  30,
                                  50,
                                  75,
                                  88,
                                  92,
                                  95,
                                  85,
                                  80,
                                  85,
                                  90,
                                  82,
                                  75,
                                  60,
                                  50,
                                  40,
                                  32,
                                  25,
                                  20
                                ],
                              ),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )));
        });
  }
}
