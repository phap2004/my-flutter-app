import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:login_app/screens/sing-in/screen_signin.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenSellerHome extends StatefulWidget {
  const ScreenSellerHome({super.key});

  @override
  State<ScreenSellerHome> createState() => _ScreenSellerHomedState();
}

class _ScreenSellerHomedState extends State<ScreenSellerHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String shopName = '';
  String email = '';
  String avatarUrl = '';
  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    fetchSellerData();
  }

  //Lấy dữ liệu người bán
  Future<void> fetchSellerData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('sellers').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          shopName = doc.data()?['shop_name'] ?? 'Chưa có tên cửa hàng';
          email = doc.data()?['email'] ?? user.email ?? '';
          avatarUrl = doc.data()?['avatar_url'] ?? '';
          followers = doc.data()?['followers'] ?? 12;
          following = doc.data()?['following'] ?? 50;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy dữ liệu seller: $e');
    }
  }

  // Chọn ảnh từ thư viện & upload lên Firebase Storage
  Future<void> pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    //Kiểm tra quyền truy cập ảnh
    var status = await Permission.photos.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng cấp quyền truy cập thư viện ảnh!'),
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final ref = _storage.ref().child('avatars/${user.uid}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await _firestore.collection('sellers').doc(user.uid).update({
        'avatar_url': url,
      });

      setState(() => avatarUrl = url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e, s) {
      debugPrint('Lỗi chọn ảnh: $e\n$s');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
    }
  }

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
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Header
              Container(
                height: 160,
                color: const Color(0xFFD65F30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.settings, color: Colors.white, size: 32),
                    Row(
                      children: const [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Avatar + info
              Positioned(
                bottom: -45,
                left: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName.isNotEmpty ? shopName : 'Đang tải...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Người theo dõi: $followers',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Đang theo dõi: $following',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
