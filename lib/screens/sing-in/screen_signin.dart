import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:login_app/screens/home/screen_admin_home.dart';
import 'package:login_app/screens/home/screen_seller_home.dart';
import 'package:login_app/screens/home/screen_seller_infor.dart';
import 'package:login_app/screens/home/screen_user_home.dart';
import 'package:login_app/screens/sing-up/screen_user_signup.dart';
import 'package:login_app/screens/sing-up/screen_seller_signup.dart';
import 'package:login_app/cards/cardSocialButton.dart';

class ScreenSignin extends StatefulWidget {
  const ScreenSignin({super.key});

  @override
  State<ScreenSignin> createState() => _ScreenSigninState();
}

class _ScreenSigninState extends State<ScreenSignin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  ///Đăng nhập bằng Email & Password
  Future<void> signInWithEmail() async {
    try {
      setState(() => isLoading = true);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception("Không tìm thấy dữ liệu người dùng.");

      final role = userDoc['role'] ?? 'user';
      print("ROLE: $role"); // debug

      // Chuyển trang theo role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenAdminHome()),
        );
      } else if (role == 'seller') {
        // Kiểm tra nếu đã có thông tin seller
        final sellerDoc = await _firestore.collection('sellers').doc(uid).get();
        if (sellerDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScreenSellerHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScreenSellerInfor()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenUserHome()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công (${role.toUpperCase()})')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Lỗi đăng nhập"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Đăng nhập bằng Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Kiểm tra / thêm mới user
      final docRef = _firestore.collection('users').doc(user!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'role': 'user', // mặc định user
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final role = (await docRef.get())['role'] ?? 'user';

      //Chuyển trang theo role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenAdminHome()),
        );
      } else if (role == 'seller') {
        final sellerDoc =
            await _firestore.collection('sellers').doc(user.uid).get();
        if (sellerDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScreenSellerHome()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScreenSellerInfor()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenUserHome()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Đăng nhập thành công: ${user.displayName ?? "Không tên"}'),
          backgroundColor: Colors.green,
        ),
      );

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng nhập Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF4EDE1)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 170, height: 170),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: inputDecoration('Email/Số điện thoại'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passController,
                        obscureText: _obscurePassword,
                        decoration: inputDecoration('Mật khẩu').copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: isLoading ? null : signInWithEmail,
                        style: buttonStyle(),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: Colors.grey, thickness: 1, endIndent: 10),
                          ),
                          Text('Hoặc'),
                          Expanded(
                            child: Divider(
                                color: Colors.grey, thickness: 1, indent: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildSocialButton(
                        imgPath: 'assets/gglogo.png',
                        text: 'Đăng nhập bằng Google',
                        onTap: () async => await signInWithGoogle(context),
                      ),
                      const SizedBox(height: 10),
                      buildSocialButton(
                        imgPath: 'assets/fblogo.png',
                        text: 'Đăng nhập bằng Facebook',
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),
                      buildSocialButton(
                        imgPath: 'assets/applelogo.png',
                        text: 'Đăng nhập bằng Apple',
                        onTap: () {},
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn chưa có tài khoản? '),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScreenUserSignup()),
                            ),
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn muốn bán hàng? '),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ScreenSellerSignup()),
                            ),
                            child: const Text(
                              'Đăng ký bán hàng',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD65F30), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD65F30),
      minimumSize: const Size(400, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
