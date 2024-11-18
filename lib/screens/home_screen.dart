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

  Future<void> _addHabit(String habitName) async {
  final user = _auth.currentUser;
  if (user != null) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Alışkanlık oluştur
    final habit = {
      'name': habitName,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final newHabitRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .add(habit);

    // Günlük progress belgesini oluştur
    final progress = {
      'isCompleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(newHabitRef.id) // Yeni oluşturulan alışkanlık belgesinin ID'si
        .collection('progress')
        .doc(today)
        .set(progress);
  }
}


  Future<void> _updateDailyProgress(String habitId, bool isCompleted) async {
    final user = _auth.currentUser;
    if (user != null) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final progressRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .collection('progress')
          .doc(today);

      await progressRef.set({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _showAddHabitDialog() {
    final _habitNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alışkanlık Tanımla'),
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
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final habitName = _habitNameController.text.trim();
                if (habitName.isNotEmpty) {
                  _addHabit(habitName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
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
                    _showAddHabitDialog();
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

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(data['name'] ?? 'Bilinmeyen Alışkanlık'),
                        trailing: StreamBuilder<DocumentSnapshot>(
                          stream: _firestore
                              .collection('users')
                              .doc(user.uid)
                              .collection('habits')
                              .doc(habit.id)
                              .collection('progress')
                              .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
                              .snapshots(),
                          builder: (context, progressSnapshot) {
                            final isCompleted = progressSnapshot.data?['isCompleted'] ?? false;
 
                            return Checkbox(
                              value: isCompleted,
                              onChanged: (bool? value) {
                                _updateDailyProgress(habit.id, value ?? false);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
