import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:bukidlink/models/User.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _instance = UserService._internal();
  factory UserService() {return _instance;}
  UserService._internal();
  static User? currentUser;

  // Sign in with email and password
  Future<UserCredential?> register(User user) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.emailAddress,
        password: user.password,
      );

      //verify email
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      currentUser = User(
        id: userCredential.user!.uid,
        username: user.username,
        password: user.password,
        firstName: user.firstName,
        lastName: user.lastName,
        emailAddress: user.emailAddress,
        address: user.address,
        contactNumber: user.contactNumber,
        profilePic: user.profilePic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // store additional user info in Firestore if needed
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user?.uid).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': user.username,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'address': user.address,
          'contactNumber': user.contactNumber,
          'profilePic': user.profilePic,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }


      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error during email/password sign-in: $e');
      return null;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      } else {
        debugPrint('Error during login: ${e.message}');
      }
    }
  }
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return currentUser;
  }
}