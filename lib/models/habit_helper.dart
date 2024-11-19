import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<void> updateDailyProgress(String habitId, bool isCompleted) async {
  final user = _auth.currentUser;
  if (user != null) {
    final today = DateTime.now();
    final weekDayIndex = today.weekday - 1; // Haftanın günü (0 = Pazartesi, 6 = Pazar)

    final habitRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitId);

    final habitSnapshot = await habitRef.get();
    if (habitSnapshot.exists) {
      final data = habitSnapshot.data() as Map<String, dynamic>;
      List<bool> weeklyProgress = List<bool>.from(data['weeklyProgress']);

      // Haftalık ilerleme güncellenir
      weeklyProgress[weekDayIndex] = isCompleted;

      await habitRef.update({
        'weeklyProgress': weeklyProgress,
      });

      // Günlük ilerleme kaydedilir
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .set({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}

}
