import 'package:flutter/material.dart';

class AddHabitDialog extends StatefulWidget {
  final Function(String habitName, String chartType, Color customColor) onAddHabit;

  AddHabitDialog({required this.onAddHabit});

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _habitNameController = TextEditingController();
  String selectedChartType = 'Circular Progress'; // Varsayılan grafik türü
  int redValue = 0; // Varsayılan kırmızı değeri
  int greenValue = 0; // Varsayılan yeşil değeri
  int blueValue = 0; // Varsayılan mavi değeri

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alışkanlık Tanımla'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alışkanlık Adı Girişi
            TextField(
              controller: _habitNameController,
              decoration: const InputDecoration(
                labelText: 'Alışkanlık Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Grafik Türü Seçici
            DropdownButton<String>(
              value: selectedChartType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedChartType = newValue!;
                });
              },
              items: <String>[
                'Circular Progress',
                'Icon Progress',
                'Linear Progress',
                'Gradient Progress',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Renk Özelleştirme
            Text(
              'Renk Özelleştirme (RGB)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                // Red Slider
                Expanded(
                  child: Column(
                    children: [
                      Text('Red: $redValue'),
                      Slider(
                        value: redValue.toDouble(),
                        min: 0,
                        max: 255,
                        divisions: 255,
                        activeColor: Colors.red,
                        label: redValue.toString(),
                        onChanged: (double value) {
                          setState(() {
                            redValue = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Green Slider
                Expanded(
                  child: Column(
                    children: [
                      Text('Green: $greenValue'),
                      Slider(
                        value: greenValue.toDouble(),
                        min: 0,
                        max: 255,
                        divisions: 255,
                        activeColor: Colors.green,
                        label: greenValue.toString(),
                        onChanged: (double value) {
                          setState(() {
                            greenValue = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Blue Slider
                Expanded(
                  child: Column(
                    children: [
                      Text('Blue: $blueValue'),
                      Slider(
                        value: blueValue.toDouble(),
                        min: 0,
                        max: 255,
                        divisions: 255,
                        activeColor: Colors.blue,
                        label: blueValue.toString(),
                        onChanged: (double value) {
                          setState(() {
                            blueValue = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Renk Önizlemesi
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, redValue, greenValue, blueValue),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final habitName = _habitNameController.text.trim();
            if (habitName.isNotEmpty) {
              widget.onAddHabit(
                habitName,
                selectedChartType,
                Color.fromARGB(255, redValue, greenValue, blueValue),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
