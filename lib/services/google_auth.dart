import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn.instance;

  static bool isInitialized = false;

  Future<UserCredential?> initSignIn() async {
    unawaited(_googleSignIn.initialize(
        serverClientId: "774780104370-puug8e1ltv5kfa64ig7oq04i5galnfgs.apps.googleusercontent.com"
    ));

    isInitialized = true;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!isInitialized) {
        await initSignIn();
      }

      final GoogleSignInAccount googleUser = await _googleSignIn
          .authenticate();

      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
      .authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;
      if (accessToken == null ) {
        final authorization2 = await authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }

        authorization = authorization2;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    }

    catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
    await _googleSignIn.signOut();
    } catch (e) {
      print("Error during Google Sign-Out: $e");
    }
  }
}
