import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../assets/colors/Colors.dart';
import '../../../../../data/dto/engagement_dto.dart';
import 'chart.dart';

class UserChartCard extends StatelessWidget {
  final String userName;
  final double duration;
  final List<LineSeries> data; // time-based points

  const UserChartCard({
    super.key,
    required this.userName,
    required this.duration,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // final statusColor = _getPerformanceColor(performanceValue);

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 300,
              child: MultiLineChart(
                minX: 0,
                maxX: duration,
                series: data,
                height: 200,
                // Example: custom bottom titles if x is time index
                bottomTitleBuilder: (value, meta) {
                  if(value % 10 != 0)
                  {
                    return const Text("");
                  }

                  final secs = value.round(); // or: (value + 1e-6).floor()
                  final m = (secs ~/ 60).toString().padLeft(2, '0');
                  final s = (secs % 60).toString().padLeft(2, '0');
                  return Text('$m:$s', style: Theme.of(context).textTheme.labelSmall);
                },
                leftTitleBuilder: (value, meta) => Text('${value.toInt()}%', style: Theme.of(context).textTheme.labelSmall),
              )


              // LineChart(
              //   _mainData(statusColor),
              //   duration: const Duration(milliseconds: 250),
              // ),


            ),
          ],
        ),
      ),
    );
  }

  // Color _getPerformanceColor(double value) {
  //   if (value >= 80) return ColorConstants.kStateSuccess;
  //   if (value >= 60) return ColorConstants.kStateInfo;
  //   if (value >= 40) return ColorConstants.kStateWarning;
  //   return ColorConstants.kStateError;
  // }
  //
  // LineChartData _mainData(Color color) {
  //   // Build spots from time-based points
  //   final spots = chartPoints.asMap().entries.map((entry) {
  //     final i = entry.key;
  //     final y = (entry.value.avgValue * 100).toDouble();
  //     return FlSpot(i.toDouble(), y);
  //   }).toList();
  //
  //   final maxX = spots.isNotEmpty ? spots.last.x.toDouble() : 0.0;
  //
  //   return LineChartData(
  //     gridData: FlGridData(
  //       show: true,
  //       drawVerticalLine: false,
  //       horizontalInterval: 20,
  //       getDrawingHorizontalLine: (value) {
  //         return FlLine(
  //           color: Colors.grey[200],
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       rightTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       topTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           interval: 1, // titles widget decides filtering
  //           getTitlesWidget: _bottomTitleWidgets,
  //         ),
  //       ),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           interval: 20,
  //           getTitlesWidget: _leftTitleWidgets,
  //           reservedSize: 40,
  //         ),
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //       show: true,
  //       border: Border(
  //         bottom: BorderSide(color: Colors.grey[300]!),
  //         left: BorderSide(color: Colors.grey[300]!),
  //       ),
  //     ),
  //     minX: 0,
  //     maxX: maxX,
  //     minY: 0,
  //     maxY: 100,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: spots,
  //         isCurved: true,
  //         color: color,
  //         barWidth: 2.5,
  //         isStrokeCapRound: true,
  //         dotData: FlDotData(
  //           show: true,
  //           getDotPainter: (spot, percent, barData, index) {
  //             return FlDotCirclePainter(
  //               radius: 3,
  //               color: Colors.white,
  //               strokeWidth: 1.5,
  //               strokeColor: color,
  //             );
  //           },
  //         ),
  //         belowBarData: BarAreaData(
  //           show: true,
  //           color: color.withOpacity(0.1),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _bottomTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     fontWeight: FontWeight.w400,
  //     fontSize: 10,
  //   );
  //
  //   final index = value.toInt();
  //   if (index >= 0 && index < chartPoints.length) {
  //     try {
  //       final baseTime = DateTime.parse(chartPoints[index].timeSlotStart);
  //       final time = baseTime.add(const Duration(hours: 2));
  //
  //       // Determine overall duration of this series
  //       final first = DateTime.parse(chartPoints.first.timeSlotStart);
  //       final last = DateTime.parse(chartPoints.last.timeSlotStart);
  //       final totalSeconds = last.difference(first).inSeconds.abs();
  //
  //       final showSeconds = totalSeconds < 60; // under 1 minute
  //       final shouldShow =
  //           showSeconds || chartPoints.length <= 10 || index % 2 == 0;
  //
  //       if (!shouldShow) return const SizedBox.shrink();
  //
  //       final label = showSeconds
  //           ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}'
  //           : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  //       return SideTitleWidget(
  //         axisSide: meta.axisSide,
  //         child: Text(label, style: style),
  //       );
  //     } catch (_) {
  //       return const SizedBox.shrink();
  //     }
  //   }
  //
  //   return const SizedBox.shrink();
  // }
  //
  // Widget _leftTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     fontWeight: FontWeight.w400,
  //     fontSize: 10,
  //   );
  //   String text = '${value.toInt()}';
  //
  //   return Text(text, style: style, textAlign: TextAlign.left);
  // }
}
