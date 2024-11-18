import 'package:flutter/material.dart';
import 'package:little_steps/screens/achievement_screen.dart';
import 'package:little_steps/screens/home_screen.dart';
import 'package:little_steps/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () {
              // Profil ekranına yönlendir
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Home'),
            onTap: () {
              // Ana ekrana yönlendir
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Achievements'),
            onTap: () {
              // Başarılar ekranına yönlendir
              Navigator.pushReplacementNamed(context, '/achievements');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              // Firebase oturumunu kapat
              await FirebaseAuth.instance.signOut();

              // Giriş ekranına yönlendir
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
