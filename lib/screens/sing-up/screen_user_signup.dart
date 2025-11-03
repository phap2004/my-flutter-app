import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_app/cards/cardSocialButton.dart';

import 'package:login_app/core/auth.dart';

class ScreenUserSignup extends StatefulWidget {
  const ScreenUserSignup({super.key});

  @override
  State<ScreenUserSignup> createState() => _ScreenUserSignupState();
}

class _ScreenUserSignupState extends State<ScreenUserSignup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool signed = false;

  @override
  Widget build(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final String role = 'user';
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
                        controller: _emailController,
                        decoration: inputDecoration('Email'),
                        textInputAction: TextInputAction.next,
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
                        decoration: inputDecoration('Nhập lại mật khẩu')
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
                        onPressed: () =>
                            signUp(email, password, role, confirm, context),
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
                        onTap: () async {
                          try {
                            final log = await signInWithGoogle(context);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đăng ký Google thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi đăng ký Google: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      buildSocialButton(
                        imgPath: 'assets/fblogo.png',
                        text: 'Đăng ký bằng Facebook',
                        onTap: () => print('Apple pressed'),
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
