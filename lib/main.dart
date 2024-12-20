import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/achievement_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Ana ekran LoginScreen olarak ayarlandı
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(), // Profile rotası tanımlandı
        '/home':  (context) => HomeScreen(),
        '/achievements': (context) => AchievementScreen(),
      },
    );
  }
}
