import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HabitProgressChart extends StatelessWidget {
  final String chartType;
  final List<bool> weeklyProgress;
  final Map<String, int> colors;
  
  const HabitProgressChart({
    Key? key,
    required this.chartType,
    required this.weeklyProgress,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case 'Circular Progress':
        return _buildCircularProgress();
      case 'Icon Progress':
        return _buildHabitProgressIcons();
      case 'Linear Progress':
        return _buildLinearProgressIndicator();
      case 'Gradient Progress':
          return _buildGradientProgressBar();
      default:
        return const Text('Unknown chart type');
    }
  }

  Widget _buildHabitProgressIcons() {
    final days = ['Pzt', 'Sal', 'Çrş', 'Prş', 'Cum', 'Cmt', 'Paz'];
    final customColor = Color.fromRGBO(
      colors['red'] ?? 0,
      colors['green'] ?? 0,
      colors['blue'] ?? 0,
      1.0, // Opaklık
      );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isCompleted = weeklyProgress[index];
        return Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? customColor : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              days[index],
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCircularProgress() {
    final completedDays = weeklyProgress.where((e) => e).length;
    final progress = completedDays / 7;
    final customColor = Color.fromRGBO(
      colors['red'] ?? 0,
      colors['green'] ?? 0,
      colors['blue'] ?? 0,
      1.0, // Opaklık
      );
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(customColor),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        const Text(
          'Weekly Progress',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
  
Widget _buildLinearProgressIndicator() {
  final completedDays = weeklyProgress.where((e) => e).length;
  final progress = completedDays / 7;
  final customColor = Color.fromRGBO(
  colors['red'] ?? 0,
  colors['green'] ?? 0,
  colors['blue'] ?? 0,
  1.0, // Opaklık
  );

  return Column(
    children: [
      LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(customColor),
        minHeight: 10,
      ),
      SizedBox(height: 8),
      Text(
        '${(progress * 100).toInt()}% tamamlandı',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    ],
  );
}
  
Widget _buildGradientProgressBar() {
  final completedDays = weeklyProgress.where((e) => e).length;
  final customColor = Color.fromRGBO(
    colors['red'] ?? 0,
    colors['green'] ?? 0,
    colors['blue'] ?? 0,
    1.0, // Opaklık
    );

  return Container(
    height: 10,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: LinearGradient(
        colors: [
          customColor,
          customColor.withOpacity(completedDays / 7),
          Colors.grey.shade300,
        ],
        stops: [0.0, completedDays / 7, 1.0],
      ),
    ),
  );
}
}


