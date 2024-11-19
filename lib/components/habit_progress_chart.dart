import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HabitProgressChart extends StatelessWidget {
  final String chartType;
  final List<bool> weeklyProgress;

  const HabitProgressChart({
    Key? key,
    required this.chartType,
    required this.weeklyProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case 'Bar Chart':
        return _buildBarChart();
      case 'Line Chart':
        return _buildLineChart();
      case 'Circular Progress':
        return _buildCircularProgress();
      default:
        return Text('Unknown chart type');
    }
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: Colors.grey),
      ),
      primaryYAxis: NumericAxis(isVisible: false),
      series: <ChartSeries>[
        ColumnSeries<_ChartData, String>(
          dataSource: _generateChartData(),
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.value,
          color: Colors.blueAccent,
        )
      ],
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: Colors.grey),
      ),
      primaryYAxis: NumericAxis(isVisible: false),
      series: <ChartSeries>[
        SplineSeries<_ChartData, String>(
          dataSource: _generateChartData(),
          xValueMapper: (_ChartData data, _) => data.day,
          yValueMapper: (_ChartData data, _) => data.value,
          color: Colors.teal,
        )
      ],
    );
  }

  Widget _buildCircularProgress() {
    final completedDays = weeklyProgress.where((e) => e).length;
    final progress = completedDays / 7;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Weekly Progress',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  List<_ChartData> _generateChartData() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (index) {
      return _ChartData(
        days[index],
        weeklyProgress[index] ? 1.0 : 0.0,
      );
    });
  }
}

class _ChartData {
  final String day;
  final double value;

  _ChartData(this.day, this.value);
}
