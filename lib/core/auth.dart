import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/legacy.dart';
import 'package:login_app/screens/home/screen_admin_home.dart';
import 'package:login_app/screens/home/screen_seller_home.dart';
import 'package:login_app/screens/home/screen_seller_infor.dart';
import 'package:login_app/screens/home/screen_user_home.dart';
// import 'package:login_app/screens/sing-up/screen_user_signup.dart';
// import 'package:login_app/screens/sing-up/screen_seller_signup.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final isLoading = StateProvider<bool>((ref) => false);

Future<User?> Loggin(
  String? e,
  String? p,
  int type,
  BuildContext context,
) async {
  String role;
  switch (type) {
    case 1:
      {
        signInWithEmail(e!, p!, context);
        role = getRoleFromMethod(
          e: e,
          p: p,
          method: 1,
          context: context,
        ).toString();
        logIntoHome(role, context);
      }
    case 2:
      {
        signInWithGoogle(context);
        role = getRoleFromMethod(method: 2, context: context).toString();
        logIntoHome(role, context);
      }
  }
}

Future<String> getRoleFromMethod({
  String? e,
  String? p,
  required int method,
  required context,
}) async {
  String? role;
  switch (method) {
    case 1:
      {
        final getMethod = await signInWithEmail(e!, p!, context);
        if (getMethod == null) {
          print('Đăng nhập lỗi, không có user');
          return 'user';
        }
        final uid = getMethod!.uid;
        final snap = await _firestore.collection('users').doc(uid).get();
        role = (snap.data()?['role'] as String?) ?? 'user';
        break;
      }
    case 2:
      {
        final getMethod = await signInWithGoogle(context!);
        final uid = getMethod!.uid;
        final snap = await _firestore.collection('users').doc(uid).get();
        role = (snap.data()?['role'] as String?) ?? 'user';
        break;
      }
  }
  return role!;
}

Future<User?> signInWithEmail(String e, String p, BuildContext context) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: e,
      password: p,
    );
    final String? uid = userCredential.user?.uid;
    if (uid == null) throw Exception('Không tìm thấy UID');

    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) throw Exception('Không tìm thấy dữ liệu người dùng');
    final user = userCredential.user;

    return user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('Không tồn tại tài khoản này.');
    } else if (e.code == 'wrong-password') {
      print('Sai mật khẩu.');
    } else if (e.code == 'invalid-email') {
      print('Email không hợp lệ.');
    } else {
      print('Lỗi khác: ${e.message}');
    }
  } finally {}
}

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
    String role;
    if (doc.exists) {
      role = (doc.data()?['role'] ?? 'user') as String;
    } else {
      await docRef.set({'uid': user.uid, 'email': user.email, 'role': 'user'});
      role = 'user';
    }

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

Future<void> logIntoHome(String role, BuildContext context) async {
  switch (role) {
    case 'admin':
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenAdminHome()),
        );
        break;
      }
    case 'sellers':
      {
        final getMethod = await signInWithGoogle(context);
        final uid = getMethod!.uid;
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
        break;
      }
    default:
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ScreenUserHome()),
        );
      }
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Đăng nhập thành công (${role.toUpperCase()})')),
  );
}
