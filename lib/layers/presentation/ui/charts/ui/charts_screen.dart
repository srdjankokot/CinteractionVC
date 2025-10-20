import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/data/source/local/local_storage.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/all_users_chart.dart';
import 'package:cinteraction_vc/layers/presentation/ui/charts/ui/widget/user_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, this.meetingId});

  final int? meetingId;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  void initState() {
    super.initState();

    // Call API when screen opens
    int? meetingId = widget.meetingId;

    // If meetingId is not provided, check LocalStorage
    if (meetingId == null) {
      meetingId = getIt.get<LocalStorage>().getMeetingIdForCharts();
    }

    if (meetingId != null) {
      print('📊 ChartsScreen: Loading data for meetingId: $meetingId');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get moduleId from current user's enabled modules
        final user = context.getCurrentUser;
        print('📊 Current user: ${user?.name}');
        print(
            '📊 User modules: ${user?.modules.map((m) => '${m.name}(${m.id})').join(', ')}');

        final engagementModule = user?.modules.firstWhere(
          (m) => m.name.toLowerCase() == 'engagement' && m.enabled == 1,
          orElse: () => user.modules.firstWhere((m) => m.enabled == 1),
        );

        if (engagementModule != null) {
          print(
              '📊 Using module: ${engagementModule.name} (id: ${engagementModule.id})');
          context.read<DashboardCubit>().getEngagementTotalAverage(
                meetingId: meetingId!,
                moduleId: engagementModule.id,
              );
        } else {
          print('⚠️ No enabled module found for user');
        }

        // Clear the saved meetingId after using it
        getIt.get<LocalStorage>().clearMeetingIdForCharts();
      });
    } else {
      print('⚠️ ChartsScreen: No meetingId found');
    }
  }

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
                      AllUsersChart(
                        engagementData: state.engagementData,
                        isLoading: state.engagementLoading ?? false,
                      ),

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

                        // Show real user data if available, otherwise show default
                        if (state.engagementData?.usersAverage.isNotEmpty ==
                            true) {
                          return Wrap(
                            spacing: space,
                            runSpacing: space,
                            children: state.engagementData!.usersAverage
                                .map((userData) {
                              // Calculate average performance for this user
                              final avgValue = userData.data.isNotEmpty
                                  ? (userData.data
                                              .map((d) => d.avgValue)
                                              .reduce((a, b) => a + b) /
                                          userData.data.length *
                                          100)
                                      .round()
                                      .toDouble()
                                  : 0.0;

                              // Convert data points to chart data (0-100 scale)
                              final chartData = userData.data
                                  .map((d) => (d.avgValue * 100).toDouble())
                                  .toList();

                              return SizedBox(
                                width: containerWidth,
                                child: UserChartCard(
                                  userName: userData.name,
                                  performanceValue: avgValue,
                                  chartPoints: userData.data,
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          // Default hardcoded data
                          return Wrap(
                            spacing: space,
                            runSpacing: space,
                            children: [
                              SizedBox(
                                width: containerWidth,
                                child: UserChartCard(
                                  userName: 'KAMERA 1',
                                  performanceValue: 70,
                                  chartPoints: const [],
                                ),
                              ),
                              SizedBox(
                                width: containerWidth,
                                child: UserChartCard(
                                  userName: 'KAMERA 2',
                                  performanceValue: 85,
                                  chartPoints: const [],
                                ),
                              ),
                            ],
                          );
                        }
                      }),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )));
        });
  }
}
