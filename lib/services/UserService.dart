import 'package:cloud_firestore/cloud_firestore.dart';
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
          'email' : user.emailAddress,
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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user?.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        currentUser = User(
          id: userCredential.user!.uid,
          username: data['username'] ?? '',
          password: password,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          emailAddress: email,
          address: data['address'] ?? '',
          contactNumber: data['contactNumber'] ?? '',
          profilePic: data['profilePic'] ?? '',
          createdAt: data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? (data['updated_at'] as Timestamp).toDate()
              : DateTime.now(),
        );
      } else {
        // User authenticated but no Firestore document - create minimal currentUser
        currentUser = User(
          id: userCredential.user!.uid,
          username: '',
          password: password,
          firstName: '',
          lastName: '',
          emailAddress: email,
          address: '',
          contactNumber: '',
          profilePic: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Clear current user on failed login
      currentUser = null;

      // Throw user-friendly error messages
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address format.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many failed attempts. Please try again later.');
      } else {
        throw Exception('Login failed. Please check your credentials.');
      }
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      currentUser = null;
      rethrow;
    }
  }
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser = null;
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return currentUser;
  }
}