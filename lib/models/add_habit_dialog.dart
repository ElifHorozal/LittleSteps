import 'package:flutter/material.dart';

class AddHabitDialog extends StatelessWidget {
  final Function(String habitName, String chartType) onAddHabit;

  AddHabitDialog({required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    final _habitNameController = TextEditingController();
    String selectedChartType = 'Bar Chart'; // Varsayılan grafik türü

    return AlertDialog(
      title: Text('Alışkanlık Tanımla'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _habitNameController,
            decoration: InputDecoration(
              labelText: 'Alışkanlık Adı',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedChartType,
            onChanged: (String? newValue) {
              selectedChartType = newValue!;
            },
            items: <String>['Bar Chart', 'Line Chart', 'Circular Progress']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final habitName = _habitNameController.text.trim();
            if (habitName.isNotEmpty) {
              onAddHabit(habitName, selectedChartType);
              Navigator.of(context).pop();
            }
          },
          child: Text('Ekle'),
        ),
      ],
    );
  }
}
