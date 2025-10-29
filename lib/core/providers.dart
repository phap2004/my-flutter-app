import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_app/cards/cardSocialButton.dart';
import 'package:riverpod/legacy.dart';
import 'package:login_app/screens/sing-in/screen_signin.dart';
import 'auth.dart';

final isLoading = StateProvider<bool>((ref) => false);

final isLogged = StateProvider<bool>((ref) => false);
