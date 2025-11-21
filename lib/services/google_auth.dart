import 'dart:async';

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
}