import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../enums.dart';

class VolumeChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> weeklyVolumeData;
  final TimeFrame selectedTimeFrame;
  final Function(TimeFrame) onTimeFrameSelected;

  const VolumeChart({
    super.key,
    required this.weeklyVolumeData,
    required this.selectedTimeFrame,
    required this.onTimeFrameSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyVolumeData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No volume data available for this period',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    // Ensure we have data to calculate the max Y value
    final maxValue = weeklyVolumeData.isEmpty 
        ? 10.0 
        : (weeklyVolumeData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Volume',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: DropdownButton<TimeFrame>(
                  value: selectedTimeFrame,
                  underline: Container(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(
                      value: TimeFrame.last7Days,
                      child: Text('Last 7 Days'),
                    ),
                    DropdownMenuItem(
                      value: TimeFrame.lastMonth,
                      child: Text('Last Month'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onTimeFrameSelected(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < weeklyVolumeData.length) {
                            final date = weeklyVolumeData[value.toInt()].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue > 0 ? maxValue / 5 : 1.0,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    weeklyVolumeData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyVolumeData[index].value,
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 