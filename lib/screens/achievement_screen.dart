import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:little_steps/components/nav_drawer.dart';

class AchievementScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // Kullanıcı kontrolü
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Başarılarım")),
        body: Center(
          child: Text(
            "Giriş yapmanız gerekiyor.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("Başarılarım"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('achievements') // Başarılar için ayrı koleksiyon
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Bir hata oluştu: ${snapshot.error}",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Henüz bir başarı kazanmadınız. Hedeflerinizi tamamlayarak başarılar kazanabilirsiniz!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            );
          }

          final achievements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final data = achievement.data() as Map<String, dynamic>;
              final title = data['title'] ?? "Başarı";
              final description = data['description'] ?? "Açıklama yok";
              final isCompleted = data['isCompleted'] ?? false;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : Colors.black,
                    ),
                  ),
                  subtitle: Text(description),
                  trailing: isCompleted
                      ? Icon(Icons.emoji_events, color: Colors.amber)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
