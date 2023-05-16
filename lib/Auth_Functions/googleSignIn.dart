import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/all_movies.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      // log("${googleSignInAuthentication.accessToken} - googleSignInAuthentication.accessToken");
      // log("${googleSignInAuthentication.idToken} - googleSignInAuthentication.idToken");

      await auth.signInWithCredential(credential).then((authResult) {
        User? user = authResult.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LandingPage(
                userCredential: authResult.user,
                providerId: authResult.credential?.providerId ?? "NULL",
              ),
            ),
          );
        } else {
          log("FirebaseAuth.instance.currentUser -- User is null---------");
        }
      });
    }
  } catch (PlatformException) {
    log(PlatformException.toString());
    log("Sign in not successful !");
  }
}

Future<void> signOutGoogle() async {
  await FirebaseAuth.instance.signOut();
  GoogleSignIn().signOut();
}
