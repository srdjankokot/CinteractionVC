import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/engagement_dto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';

class AllUsersChart extends StatelessWidget {
  const AllUsersChart({
    super.key,
    this.engagementData,
    this.isLoading = false,
  });

  final EngagementTotalAverageDto? engagementData;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Attention Average',
                        style: context.titleTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How attention levels changed throughout the day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorConstants.kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getAverageAttentionText(),
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Line Chart
            SizedBox(
              height: 300,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : LineChart(
                      _mainData(),
                      duration: const Duration(milliseconds: 250),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAverageAttentionText() {
    if (engagementData == null ||
        engagementData!.totalAttentionAverage.isEmpty) {
      return '0.0%';
    }

    // Calculate average from all data points
    final sum = engagementData!.totalAttentionAverage
        .map((e) => e.avgValue)
        .reduce((a, b) => a + b);
    final average = sum / engagementData!.totalAttentionAverage.length;

    return '${(average * 100).toStringAsFixed(1)}%';
  }

  List<FlSpot> _getChartSpots() {
    print('🔍 _getChartSpots called');
    print('🔍 engagementData: ${engagementData != null ? "exists" : "null"}');
    print(
        '🔍 totalAttentionAverage length: ${engagementData?.totalAttentionAverage.length ?? 0}');

    if (engagementData == null ||
        engagementData!.totalAttentionAverage.isEmpty) {
      print('🔍 Using default hardcoded data');
      // Return default hardcoded data
      return const [
        FlSpot(0, 25), // 00:00 - Low attention (sleep)
        FlSpot(1, 20), // 01:00 - Very low attention
        FlSpot(2, 18), // 02:00 - Very low attention
        FlSpot(3, 15), // 03:00 - Very low attention
        FlSpot(4, 12), // 04:00 - Very low attention
        FlSpot(5, 10), // 05:00 - Very low attention
        FlSpot(6, 25), // 06:00 - Waking up
        FlSpot(7, 45), // 07:00 - Morning routine
        FlSpot(8, 72), // 08:00 - High attention (work start)
        FlSpot(9, 85), // 09:00 - Peak attention
        FlSpot(10, 88), // 10:00 - Peak attention
        FlSpot(11, 90), // 11:00 - Peak attention
        FlSpot(12, 82), // 12:00 - Lunch break
        FlSpot(13, 75), // 13:00 - Post-lunch dip
        FlSpot(14, 80), // 14:00 - Afternoon focus
        FlSpot(15, 85), // 15:00 - High attention
        FlSpot(16, 78), // 16:00 - Afternoon focus
        FlSpot(17, 70), // 17:00 - End of work day
        FlSpot(18, 55), // 18:00 - Evening relaxation
        FlSpot(19, 45), // 19:00 - Evening activities
        FlSpot(20, 35), // 20:00 - Evening wind down
        FlSpot(21, 28), // 21:00 - Evening relaxation
        FlSpot(22, 22), // 22:00 - Preparing for sleep
        FlSpot(23, 18), // 23:00 - Low attention (bedtime)
      ];
    }

    // Process real data from API
    List<FlSpot> spots = [];

    print(
        '🔍 Processing ${engagementData!.totalAttentionAverage.length} data points');

    for (int i = 0; i < engagementData!.totalAttentionAverage.length; i++) {
      final dataPoint = engagementData!.totalAttentionAverage[i];
      try {
        // Use index as x value (0, 1, 2, 3...)
        final xValue = i.toDouble();
        // Convert 0-1 value to 0-100 percentage
        final yValue = dataPoint.avgValue * 100;
        spots.add(FlSpot(xValue, yValue));

        print(
            '📊 Chart point $i: time=${dataPoint.timeSlotStart}, value=${yValue.toStringAsFixed(1)}%');
      } catch (e) {
        print('❌ Error parsing data point: $e');
      }
    }

    print('📊 Total spots created: ${spots.length}');
    if (spots.isEmpty) {
      print('⚠️ No spots created, returning empty list');
      return [];
    }

    return spots;
  }

  LineChartData _mainData() {
    final spots = _getChartSpots();
    final maxX = spots.isNotEmpty ? spots.last.x : 23;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: maxX.toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: ColorConstants.kPrimaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: ColorConstants.kPrimaryColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: ColorConstants.kPrimaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 11,
    );

    if (engagementData != null &&
        engagementData!.totalAttentionAverage.isNotEmpty) {
      final index = value.toInt();
      if (index >= 0 && index < engagementData!.totalAttentionAverage.length) {
        final timeString =
            engagementData!.totalAttentionAverage[index].timeSlotStart;
        try {
          final time = DateTime.parse(timeString).add(const Duration(hours: 2));

          // Detect ultra-short meetings by span between first and last label
          final first = DateTime.parse(
              engagementData!.totalAttentionAverage.first.timeSlotStart);
          final last = DateTime.parse(
              engagementData!.totalAttentionAverage.last.timeSlotStart);
          final totalSeconds = last.difference(first).inSeconds.abs();

          // If under 60 seconds, always show seconds and every label
          final showSeconds = totalSeconds < 60;

          // For short meetings (≤10 data points), show every label; else every other label
          final shouldShow = showSeconds ||
              engagementData!.totalAttentionAverage.length <= 10 ||
              index % 2 == 0;

          if (shouldShow) {
            final label = showSeconds
                ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}'
                : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(label, style: style),
            );
          }
        } catch (e) {
          return const SizedBox.shrink();
        }
      }
      return const SizedBox.shrink();
    }

    // Default for hardcoded data - show every 4 hours
    if (value.toInt() % 4 == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text('${value.toInt().toString().padLeft(2, '0')}:00',
            style: style),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
    );
    String text = '${value.toInt()}';

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
