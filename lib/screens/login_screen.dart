import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key); // Key parametresi eklendi

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("E-posta ve şifreyi girin")),
    );
    return;
  }

  try {
    // Firebase ile giriş yapma işlemi
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Giriş başarılı!")),
    );

    // Giriş başarılı olursa Firestore’a kullanıcı ekle veya güncelle
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Belge varsa günceller, yoksa ekler

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kullanıcı Firestore'a eklendi veya güncellendi")),
    );

    // Başarılı girişten sonra ProfileScreen'e yönlendirme (örneğin)
      Navigator.pushReplacementNamed(context, '/profile');
      
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'Kullanıcı bulunamadı.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Hatalı şifre.';
    } else {
      errorMessage = 'Bir hata oluştu: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giriş Yap"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "E-posta",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Şifre",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _login,
              child: Text("Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
