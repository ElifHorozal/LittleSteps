import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:little_steps/models/add_habit_dialog.dart';
import 'package:little_steps/models/habit_helper.dart';
import 'package:little_steps/components/habit_progress_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
 final HabitHelper _habitHelper = HabitHelper();

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  void initState() {
    super.initState();
    _checkWeeklyProgressForAllHabits(); // Haftalık kontrol
  }

  DateTime getStartOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _addHabit(String habitName, String chartType, Color customColor) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final habit = {
      'name': habitName,
      'chartType': chartType,
      'createdAt': FieldValue.serverTimestamp(),
      'weeklyProgress': List<bool>.generate(7, (_) => false),
      'currentWeekStart': DateFormat('yyyy-MM-dd').format(weekStart),
      'color': {
        'red': customColor.red,
        'green': customColor.green,
        'blue': customColor.blue,
      }, // Renk bilgisi kaydediliyor
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .add(habit);
  }
}

Future<void> _checkWeeklyProgressForAllHabits() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final habits = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .get();

    for (var habit in habits.docs) {
      await _checkAndResetWeeklyProgress(habit.id);
    }
  }
}
Future<void> _checkAndResetWeeklyProgress(String habitId) async {
  final user = _auth.currentUser;
  if (user != null) {
    final today = DateTime.now();
    final weekStart = getStartOfWeek(today); // Haftanın Pazartesi'sini hesapla

    final normalizedWeekStart = DateTime(weekStart.year, weekStart.month, weekStart.day); // Normalize
    final habitRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitId);

    final habitSnapshot = await habitRef.get();
    if (habitSnapshot.exists) {
      final data = habitSnapshot.data() as Map<String, dynamic>;

      // Firestore'dan alınan tarihi doğru formatta okuyun
      final currentWeekStart = data['currentWeekStart'] is String
          ? DateTime.parse(data['currentWeekStart'])
          : (data['currentWeekStart'] as Timestamp).toDate();

      final normalizedCurrentWeekStart = DateTime(
        currentWeekStart.year,
        currentWeekStart.month,
        currentWeekStart.day,
      ); // Normalize

      print('Normalized Week start: $normalizedWeekStart');
      print('Normalized Current week start: $normalizedCurrentWeekStart');

      // Eğer hafta değişmişse sadece o zaman sıfırla
      if (normalizedWeekStart.isAfter(normalizedCurrentWeekStart)) {
        print('Hafta değişti, weeklyProgress sıfırlanıyor...');
        await habitRef.update({
          'weeklyProgress': List<bool>.generate(7, (_) => false), // Haftalık ilerleme sıfırlanır
          'currentWeekStart': DateFormat('yyyy-MM-dd').format(normalizedWeekStart), // Yeni hafta başlangıç tarihi
        });
      } else {
        print('Aynı hafta, sıfırlama yapılmıyor.');
      }
    }
  }
}



 void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddHabitDialog(onAddHabit: _addHabit);
      },
    );
  }
  
 @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alışkanlıklarım'),
      ),
      body: user == null
          ? Center(child: Text('Giriş yapılmamış.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('habits')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showAddHabitDialog(context);
                  });

                  return Center(
                    child: Text(
                      'Henüz alışkanlık tanımlanmadı. Yeni bir alışkanlık ekleyin!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final habits = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final data = habit.data() as Map<String, dynamic>;

                    final String chartType = data['chartType'] ?? 'Bar Chart';
                    final List<bool> weeklyProgress =
                        List<bool>.from(data['weeklyProgress']);
                    final Map<String, int> colorMap = {
                        'red': data['color']['red'] ?? 0,
                        'green': data['color']['green'] ?? 0,
                        'blue': data['color']['blue'] ?? 0,
                      };
                    final today = DateTime.now();
                    final currentDayIndex = today.weekday - 1;

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(data['name'] ?? 'Unknown Habit'),
                            subtitle: HabitProgressChart(
                              chartType: chartType,
                              weeklyProgress: weeklyProgress,
                              colors : colorMap,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Bugünün Durumu:'),
                                Checkbox(
                                  value: weeklyProgress[currentDayIndex],
                                  onChanged: (bool? value) async {
                                    if (value != null) {
                                      await _habitHelper.updateDailyProgress(habit.id, value);
 
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
