import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Başarılarım"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('achievements').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Henüz bir başarınız yok.",
                style: TextStyle(fontSize: 18),
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
