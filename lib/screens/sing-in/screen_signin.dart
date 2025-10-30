import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_app/core/auth.dart';
import 'package:riverpod/legacy.dart';
import 'package:login_app/cards/cardSocialButton.dart';
import 'package:login_app/screens/sing-up/screen_user_signup.dart';
import 'package:login_app/screens/sing-up/screen_seller_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

final isLoading = StateProvider<bool>((ref) => false);

class ScreenSignin extends ConsumerStatefulWidget {
  const ScreenSignin({super.key});

  @override
  ConsumerState<ScreenSignin> createState() => _ScreenSigninState();
}

class _ScreenSigninState extends ConsumerState<ScreenSignin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _obscurePassword = true;

  //set focus to
  final emailFocus = FocusNode();
  final passFocus = FocusNode();
  final loginFocus = FocusNode();

  //UI
  @override
  Widget build(BuildContext context) {
    ///Đăng nhập bằng Email & Password
    final e = emailController.text.trim();
    final p = passController.text.trim();

    //get typing state
    final _isLoading = ref.watch(isLoading);

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
                        focusNode: emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(passFocus),
                        controller: emailController,
                        decoration: inputDecoration('Email/Số điện thoại'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        focusNode: passFocus,
                        textInputAction: TextInputAction.go,
                        controller: passController,
                        obscureText: _obscurePassword,
                        onEditingComplete: () {},
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          try {
                            Loggin(e, p, 1, context);
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message ?? "Lỗi đăng nhập"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },

                        decoration: inputDecoration('Mật khẩu').copyWith(
                          suffixIcon: Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            child: IconButton(
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
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        focusNode: loginFocus,
                        onPressed: () async {
                          try {
                            Loggin(e, p, 1, context);
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message ?? "Lỗi đăng nhập"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },

                        style: buttonStyle(),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
                                builder: (_) => const ScreenUserSignup(),
                              ),
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
                                builder: (_) => const ScreenSellerSignup(),
                              ),
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
