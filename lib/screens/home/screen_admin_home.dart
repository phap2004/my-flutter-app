import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/screens/sing-in/screen_signin.dart';

class ScreenAdminHome extends StatefulWidget {
  const ScreenAdminHome({super.key});

  @override
  State<ScreenAdminHome> createState() => _ScreenAdminHomeState();
}

class _ScreenAdminHomeState extends State<ScreenAdminHome> {
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
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        backgroundColor: const Color(0xFFD65F30),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF4EDE1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👋 Xin chào, Admin!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${user?.email ?? "Không xác định"}',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30, thickness: 1),

            // 🔹 Khu vực quản trị chính
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  buildAdminCard(Icons.people, 'Quản lý người dùng'),
                  buildAdminCard(Icons.store, 'Quản lý sản phẩm'),
                  buildAdminCard(Icons.shopping_cart, 'Quản lý đơn hàng'),
                  buildAdminCard(Icons.analytics, 'Thống kê hệ thống'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdminCard(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mở chức năng: $title')),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: const Color(0xFFD65F30)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
