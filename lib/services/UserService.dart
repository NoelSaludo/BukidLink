import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:bukidlink/services/google_auth.dart';
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
      // Only create the Firebase Auth user. Firestore user document will be
      // created after email verification.
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.emailAddress.trim(),
            password: user.password.trim(),
          );

      // Set minimal in-memory currentUser (no Firestore writes yet).
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

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error during email/password sign-in: $e');
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
      // Only create the Firebase Auth user. Firestore farm/user will be
      // created after verification by caller.
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.emailAddress.trim(),
            password: user.password.trim(),
          );

      final String uid = userCredential.user!.uid;

      // Set minimal in-memory currentUser (Firestore farm/user will be
      // created after verification by caller).
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
        farmId: null,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error during farm registration: $e');
      return null;
    }
  }

  /// Save consumer user info to Firestore for the currently authenticated
  /// Firebase user. This should be called after email verification.
  Future<void> saveUserToFirestore(User user) async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) throw Exception('No authenticated Firebase user');

      final uid = fbUser.uid;
      final firestore = FirebaseFirestore.instance;

      final docRef = firestore.collection('users').doc(uid);
      await docRef.set({
        'username': user.username,
        'emailAddress': user.emailAddress,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'address': user.address,
        'contactNumber': user.contactNumber,
        'profilePic': user.profilePic,
        'type': user.type ?? 'Consumer',
        'farmId': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // update in-memory currentUser
      currentUser = User(
        id: uid,
        username: user.username,
        password: '',
        firstName: user.firstName,
        lastName: user.lastName,
        emailAddress: user.emailAddress,
        address: user.address,
        contactNumber: user.contactNumber,
        profilePic: user.profilePic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: user.type ?? 'Consumer',
        farmId: null,
      );
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  /// Create a farmer user document and associated farm document for the
  /// currently authenticated Firebase user. Call this after email verification.
  Future<void> saveFarmToFirestore(User user, Farm farm) async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) throw Exception('No authenticated Firebase user');

      final uid = fbUser.uid;
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);

      // create farm doc
      final farmRef = firestore.collection('farms').doc();
      await farmRef.set({
        'name': farm.name,
        'address': farm.address,
        'ownerId': userRef,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // create user doc with farmId pointing to the farm ref
      await userRef.set({
        'username': user.username,
        'email': user.emailAddress,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'address': user.address,
        'contactNumber': user.contactNumber,
        'profilePic': user.profilePic,
        'type': user.type ?? 'Farmer',
        'farmId': farmRef,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      currentUser = User(
        id: uid,
        username: user.username,
        password: '',
        firstName: user.firstName,
        lastName: user.lastName,
        emailAddress: user.emailAddress,
        address: user.address,
        contactNumber: user.contactNumber,
        profilePic: user.profilePic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: user.type ?? 'Farmer',
        farmId: farmRef,
      );
    } catch (e) {
      debugPrint('Error saving farm and user to Firestore: $e');
      rethrow;
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

  /// Sign in with Google using [FirebaseService].
  // (Removed older implementation; see newer `signInWithGoogle` below.)

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // clear in-memory current user when signing out
    currentUser = null;
  }

  /// Send a verification email to the currently authenticated Firebase user.
  /// No-op if there is no current user or the email is already verified.
  Future<void> sendEmailVerificationToCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      rethrow;
    }
  }

  /// Reload the Firebase auth current user to get the latest state (emailVerified, etc.).
  Future<void> reloadFirebaseUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading firebase user: $e');
      rethrow;
    }
  }

  /// Returns whether the current firebase auth user is email verified.
  /// If [reloadFirst] is true, performs a reload before checking.
  Future<bool> isFirebaseCurrentUserEmailVerified({
    bool reloadFirst = false,
  }) async {
    try {
      if (reloadFirst) await reloadFirebaseUser();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Error checking emailVerified: $e');
      return false;
    }
  }

  /// Returns the email of the currently authenticated firebase user, or null.
  String? getFirebaseCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Sign in with Google using [FirebaseService].
  ///
  /// Returns `true` if a matching Firestore `users` document already exists,
  /// `false` if the Firebase user signed in but no Firestore document was found
  /// (caller should present a signup form and then call the dedicated
  /// creation methods below).
  Future<bool> signInWithGoogle() async {
    try {
      final userCredential = await FirebaseService().signInWithGoogle();

      if (userCredential == null) {
        debugPrint('Google sign-in returned null');
        return false;
      }

      final fbUser = userCredential.user;
      if (fbUser == null) {
        debugPrint('Google sign-in did not return a Firebase user');
        return false;
      }

      final String uid = fbUser.uid;
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);
      final doc = await userRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        currentUser = User(
          id: uid,
          username: data['username'] ?? '',
          password: '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          emailAddress:
              data['emailAddress'] ?? data['email'] ?? fbUser.email ?? '',
          address: data['address'] ?? '',
          contactNumber: data['contactNumber'] ?? '',
          profilePic: data['profilePic'] ?? fbUser.photoURL ?? '',
          createdAt: data['created_at'] != null
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
          updatedAt: data['updated_at'] != null
              ? (data['updated_at'] as Timestamp).toDate()
              : DateTime.now(),
          type: data['type'] ?? 'Consumer',
          farmId: data['farmId'] as DocumentReference?,
        );

        return true;
      } else {
        // No Firestore user document: set a minimal in-memory currentUser and
        // return false so the UI can collect additional fields and create the
        // full user record.
        final displayName = fbUser.displayName ?? '';
        final firstName = displayName.split(' ').isNotEmpty
            ? displayName.split(' ').first
            : '';
        final lastName = displayName.split(' ').length > 1
            ? displayName.split(' ').skip(1).join(' ')
            : '';

        currentUser = User(
          id: uid,
          username: '',
          password: '',
          firstName: firstName,
          lastName: lastName,
          emailAddress: fbUser.email ?? '',
          address: '',
          contactNumber: '',
          profilePic: fbUser.photoURL ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          type: 'Consumer',
          farmId: null,
        );

        return false;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return false;
    }
  }

  /// Create a consumer user document for the currently-signed Firebase user
  /// (used after Google sign-in when no Firestore user existed).
  Future<void> createConsumerAccount({
    required String username,
    required String firstName,
    required String lastName,
    required String address,
    required String contactNumber,
  }) async {
    try {
      if (currentUser == null) throw Exception('No authenticated user');
      final uid = currentUser!.id;
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);

      await userRef.set({
        'username': username,
        'email': currentUser!.emailAddress,
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'contactNumber': contactNumber,
        'profilePic': currentUser!.profilePic,
        'type': 'Consumer',
        'farmId': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      currentUser = User(
        id: uid,
        username: username,
        password: '',
        firstName: firstName,
        lastName: lastName,
        emailAddress: currentUser!.emailAddress,
        address: address,
        contactNumber: contactNumber,
        profilePic: currentUser!.profilePic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'Consumer',
        farmId: null,
      );
    } catch (e) {
      debugPrint('Error creating consumer account: $e');
      rethrow;
    }
  }

  /// Create a farmer user document and associated farm document for the
  /// currently-signed Firebase user (used after Google sign-in when no Firestore
  /// user existed).
  Future<void> createFarmerAccount({
    required String username,
    required String firstName,
    required String lastName,
    required String address,
    required String contactNumber,
    required String farmName,
    required String farmAddress,
  }) async {
    try {
      if (currentUser == null) throw Exception('No authenticated user');
      final uid = currentUser!.id;
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(uid);

      // create farm doc
      final farmRef = firestore.collection('farms').doc();
      await farmRef.set({
        'name': farmName,
        'address': farmAddress,
        'ownerId': userRef,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // create user doc with farmId pointing to the farm ref
      await userRef.set({
        'username': username,
        'email': currentUser!.emailAddress,
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'contactNumber': contactNumber,
        'profilePic': currentUser!.profilePic,
        'type': 'Farmer',
        'farmId': farmRef,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      currentUser = User(
        id: uid,
        username: username,
        password: '',
        firstName: firstName,
        lastName: lastName,
        emailAddress: currentUser!.emailAddress,
        address: address,
        contactNumber: contactNumber,
        profilePic: currentUser!.profilePic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'Farmer',
        farmId: farmRef,
      );
    } catch (e) {
      debugPrint('Error creating farmer account: $e');
      rethrow;
    }
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
        // Support both legacy 'email' key and newer 'emailAddress'
        emailAddress: data['emailAddress'] ?? data['email'] ?? '',
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

  /// Replace/overwrite the entire user document for [user].
  /// This writes all main user fields to Firestore and updates the in-memory
  /// `currentUser` reference.
  Future<void> updateUser(User user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('users').doc(user.id);

      await docRef.set({
        'username': user.username,
        'firstName': user.firstName,
        'lastName': user.lastName,
        // write both keys for backward compatibility
        'emailAddress': user.emailAddress,
        'email': user.emailAddress,
        'address': user.address,
        'contactNumber': user.contactNumber,
        'profilePic': user.profilePic,
        'type': user.type ?? 'Consumer',
        'farmId': user.farmId,
        'created_at': Timestamp.fromDate(user.createdAt),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false));

      // update in-memory currentUser
      currentUser = User(
        id: user.id,
        username: user.username,
        password: (currentUser != null && currentUser!.id == user.id)
            ? currentUser!.password
            : user.password,
        firstName: user.firstName,
        lastName: user.lastName,
        emailAddress: user.emailAddress,
        address: user.address,
        contactNumber: user.contactNumber,
        profilePic: user.profilePic,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
        type: user.type,
        farmId: user.farmId,
      );
    } catch (e) {
      debugPrint('Error replacing user document: $e');
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
