import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _initializeUserDocument() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = _firestore.collection('users').doc(user.uid);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({'habits': []});
      }
    }
  }

  Future<void> _addHabit(String habitName) async {
    final user = _auth.currentUser;
    if (user != null) {
      final habit = {
        'name': habitName,
        'createdAt': FieldValue.serverTimestamp(),
        'weeklyProgress': List.generate(7, (_) => false),
      };
      await _firestore.collection('users').doc(user.uid).collection('habits').add(habit);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeUserDocument();
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
                  return Center(
                    child: Text(
                      'Henüz alışkanlık eklenmedi.\nYeni bir alışkanlık eklemek için "+" butonuna tıklayın.',
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
                    final data = habit.data() as Map<String, dynamic>?;

                    final weeklyProgress = data?['weeklyProgress'] != null
                        ? List<bool>.from(data!['weeklyProgress'])
                        : List.generate(7, (_) => false);

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(data?['name'] ?? 'Bilinmeyen Alışkanlık'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (dayIndex) {
                            final now = DateTime.now();
                            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                            final dayDate = startOfWeek.add(Duration(days: dayIndex));
                            final dayName = DateFormat.E().format(dayDate); // Günün kısa adı (Mon, Tue, ...)
                            final isToday = dayIndex == (now.weekday - 1); // Bugün kontrolü

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? Colors.blue : Colors.black,
                                  ),
                                ),
                                Checkbox(
                                  value: weeklyProgress[dayIndex],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      weeklyProgress[dayIndex] = value!;
                                    });
                                    _firestore
                                        .collection('users')
                                        .doc(user.uid)
                                        .collection('habits')
                                        .doc(habit.id)
                                        .update({'weeklyProgress': weeklyProgress});
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final _habitNameController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Alışkanlık Ekle'),
                content: TextField(
                  controller: _habitNameController,
                  decoration: InputDecoration(
                    labelText: 'Alışkanlık Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Diyaloğu kapat
                    },
                    child: Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () {
                      final habitName = _habitNameController.text.trim();
                      if (habitName.isNotEmpty) {
                        _addHabit(habitName); // Alışkanlığı ekle
                        Navigator.of(context).pop(); // Diyaloğu kapat
                      }
                    },
                    child: Text('Ekle'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
