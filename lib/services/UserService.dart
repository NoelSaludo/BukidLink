import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:bukidlink/models/User.dart';
import 'package:bukidlink/models/Farm.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _instance = UserService._internal();
  factory UserService() {
    return _instance;
  }
  UserService._internal();
  static User? currentUser;

  // Sign in with email and password
  Future<UserCredential?> registerUser(User user) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.emailAddress,
            password: user.password,
          );

      //verify email
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      currentUser = User(
        id: userCredential.user!.uid,
        farmId: user.farmId,
        username: user.username,
        password: user.password,
        firstName: user.firstName,
        lastName: user.lastName,
        emailAddress: user.emailAddress,
        address: user.address,
        contactNumber: user.contactNumber,
        profilePic: user.profilePic,
        type: user.type,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // store additional user info in Firestore if needed
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': user.username,
          'email': user.emailAddress,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'address': user.address,
          'contactNumber': user.contactNumber,
          'type': user.type,
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

  // Register a user and create a farm document linked to that user.
  // Steps:
  // 1. Create auth user
  // 2. Create user document with a null farm reference
  // 3. Create farm document with ownerId pointing to the user document
  // 4. Update user document's farmId to point to the created farm document
  Future<UserCredential?> registerFarm(User user, Farm farm) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.emailAddress,
            password: user.password,
          );

      // verify email
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      final String uid = userCredential.user!.uid;

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final DocumentReference userRef = firestore.collection('users').doc(uid);

      // Create the user document first with no farm reference
      await userRef.set({
        'username': user.username,
        'email': user.emailAddress,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'address': user.address,
        'contactNumber': user.contactNumber,
        'profilePic': user.profilePic,
        'type': user.type,
        'farmId': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Create the farm document with ownerId set to the user document reference
      final DocumentReference farmRef = firestore.collection('farms').doc();
      await farmRef.set({
        'name': farm.name,
        'address': farm.address,
        'ownerId': userRef,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update the user's farmId to point to the created farm reference
      await userRef.update({'farmId': farmRef});

      // Update local currentUser
      currentUser = User(
        id: uid,
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
        type: user.type,
        farmId: farmRef,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error during farm registration: $e');
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
          .doc(userCredential.user?.uid)
          .get();

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
          type: data['type'] ?? 'Consumer',
          farmId: data['farmId'] as DocumentReference?,
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
          type: 'Consumer',
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
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return currentUser;
  }

  String getSafeUserId() {
    return currentUser?.id ?? "unknown-user";
  }

  // Fetch a Farm document given its DocumentReference. Returns null on error or if not found.
  Future<Farm?> getFarmByReference(DocumentReference? farmRef) async {
    if (farmRef == null) return null;
    try {
      final doc = await farmRef.get();
      if (!doc.exists) return null;
      return Farm.fromDocument(doc);
    } catch (e) {
      debugPrint('Error fetching farm by reference: $e');
      return null;
    }
  }

  // Convenience: fetch the farm for a given User model (uses user's farmId reference).
  Future<Farm?> getFarmForUser(User? user) async {
    if (user == null) return null;
    return await getFarmByReference(user.farmId);
  }

  // Find a user id by username. Returns the Firestore doc id or null if not found.
  Future<String?> getUserIdByUsername(String username) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final qs = await firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (qs.docs.isNotEmpty) return qs.docs.first.id;
    } catch (e) {
      debugPrint('Error finding user by username: $e');
    }
    return null;
  }

  Future<User?> getUserById(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return User(
        id: uid,
        username: data['username'] ?? '',
        password: '', // leave empty; don't fetch stored password
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        emailAddress: data['email'] ?? '',
        address: data['address'] ?? '',
        contactNumber: data['contactNumber'] ?? '',
        profilePic: data['profilePic'] ?? 'default_image.png',
        createdAt: data['created_at'] != null
            ? (data['created_at'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updated_at'] != null
            ? (data['updated_at'] as Timestamp).toDate()
            : DateTime.now(),
        type: data['type'] ?? 'Consumer',
        farmId: data['farmId'] as DocumentReference?,
      );
    } catch (e) {
      debugPrint('Error fetching user by ID: $e');
      return null;
    }
  }

  /// Update user document fields for [uid] with the provided [updates] map.
  /// Also updates the in-memory `currentUser` if it matches [uid].
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).update({
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // If currentUser matches uid, update the in-memory copy
      if (currentUser != null && currentUser!.id == uid) {
        final old = currentUser!;
        currentUser = User(
          id: old.id,
          username: updates['username'] ?? old.username,
          password: old.password,
          firstName: updates['firstName'] ?? old.firstName,
          lastName: updates['lastName'] ?? old.lastName,
          emailAddress: updates['emailAddress'] ?? old.emailAddress,
          address: updates['address'] ?? old.address,
          contactNumber: updates['contactNumber'] ?? old.contactNumber,
          profilePic: updates['profilePic'] ?? old.profilePic,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          type: old.type,
          farmId: old.farmId,
        );
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<User> getUserWithFallback(String id) async {
    return await UserService().getUserById(id) ??
        User(
          id: 'unknown',
          username: 'Unknown User',
          password: '',
          firstName: '',
          lastName: '',
          emailAddress: '',
          address: '',
          contactNumber: '',
          profilePic: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }
}
