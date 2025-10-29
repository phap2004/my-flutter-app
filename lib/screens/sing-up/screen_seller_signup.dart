import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_app/cards/cardSocialButton.dart';

class ScreenSellerSignup extends StatefulWidget {
  const ScreenSellerSignup({super.key});

  @override
  State<ScreenSellerSignup> createState() => _ScreenSellerSignupState();
}

class _ScreenSellerSignupState extends State<ScreenSellerSignup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  /// Đăng ký bằng Email & Password (role = seller)
  Future<void> signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu không trùng khớp!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      // Tạo tài khoản Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      // Lưu vào Firestore với role = seller
      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': 'seller',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký người bán thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Lỗi đăng ký';
      if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng!';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ!';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khác: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Đăng ký bằng Google (role = seller)
  Future<void> signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // người dùng hủy đăng nhập

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Lưu vào Firestore nếu chưa có
      final docRef = _firestore.collection('users').doc(user!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'role': 'seller',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký Google thành công: ${user.displayName ?? "Không tên"}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // quay lại trang đăng nhập
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng ký Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF4EDE1)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 170, height: 170),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: _emailController,
                        decoration: inputDecoration('Email/Số điện thoại'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: _passwordController,
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
                      const SizedBox(height: 10),
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: _confirmController,
                        obscureText: _obscurePassword,
                        decoration: inputDecoration('Lặp lại mật khẩu')
                            .copyWith(
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
                        onPressed: isLoading ? null : signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD65F30),
                          minimumSize: const Size(400, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Đăng ký',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),

                      const SizedBox(height: 15),
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          Text('Hoặc'),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      buildSocialButton(
                        imgPath: 'assets/gglogo.png',
                        text: 'Đăng ký bằng Google',
                        onTap: signUpWithGoogle,
                      ),
                      const SizedBox(height: 10),
                      buildSocialButton(
                        imgPath: 'assets/fblogo.png',
                        text: 'Đăng ký bằng Facebook',
                        onTap: () => print('Facebook pressed'),
                      ),
                      const SizedBox(height: 10),
                      buildSocialButton(
                        imgPath: 'assets/applelogo.png',
                        text: 'Đăng ký bằng Apple',
                        onTap: () => print('Apple pressed'),
                      ),
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bạn đã có tài khoản? '),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Đăng nhập ngay',
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
}
