import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/screens/sing-in/screen_signin.dart';

class ScreenUserHome extends StatefulWidget {
  const ScreenUserHome({super.key});

  @override
  State<ScreenUserHome> createState() => _ScreenUserHomeState();
}

class _ScreenUserHomeState extends State<ScreenUserHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ScreenSignin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD65F30),
        title: const Text('Trang chính người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '👋 Chào mừng bạn đến với trang người dùng!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
