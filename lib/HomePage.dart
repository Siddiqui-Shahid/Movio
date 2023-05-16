// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//
// import 'Auth_Functions/googleSignIn.dart';
// import 'main.dart';
//
// class HomePage extends StatelessWidget {
//   final User? userCredential;
//   final String providerId;
//   const HomePage({Key? key, this.userCredential, required this.providerId})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     log("Image Url Facebook - ${userCredential?.photoURL}");
//     log("Image Url Facebook with instance - ${FirebaseAuth.instance.currentUser?.photoURL}");
//     log("UID Facebook with instance - ${FirebaseAuth.instance.currentUser?.uid}");
//     return Scaffold(
//       body: Container(
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: (MediaQuery.of(context).size.width * 0.35) + 3,
//               blackgroundColor: Colors.transparent,
//               child: CircleAvatar(
//                 radius: MediaQuery.of(context).size.width * 0.35,
//                 blackgroundImage: NetworkImage(
//                   userCredential?.photoURL ??
//                       "https://i.stack.imgur.com/l60Hf.png",
//                 ),
//               ),
//             ),
//             const Divider(color: Colors.transparent),
//             Container(
//               alignment: Alignment.centerLeft,
//               width: MediaQuery.of(context).size.width * 0.7,
//               height: 50.0,
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 border: Border.all(color: Colors.transparent, width: 2),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Text(
//                 "LogIn : " + providerId,
//                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900),
//               ),
//             ),
//             const Divider(color: Colors.transparent),
//             Container(
//               alignment: Alignment.centerLeft,
//               width: MediaQuery.of(context).size.width * 0.7,
//               height: 50.0,
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 border: Border.all(color: Colors.transparent, width: 2),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Text(
//                 "Name : ${userCredential?.displayName}",
//                 style: TextStyle(
//                     fontSize: 20.0,
//                     fontWeight: FontWeight.w900,
//                     overflow: TextOverflow.ellipsis),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (providerId == "google.com") {
//             signOutGoogle();
//           } else if (providerId == "facebook.com") {
//             signOutFacebook();
//           }
//           Navigator.popUntil(context, ModalRoute.withName('NULL'));
//           Navigator.of(context)
//               .push(MaterialPageRoute(builder: (context) => const MyApp()));
//         },
//         child: Icon(
//           Icons.login_rounded,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }
//
//   Future<void> signOutFacebook() async {
//     await FacebookAuth.instance.logOut();
//     await FirebaseAuth.instance.signOut();
//   }
// }

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_login/Auth_Functions/googleSignIn.dart';
import 'package:google_login/screens/all_movies.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Colors.pink.shade100,
            Colors.blue.shade100,
            Colors.blue.shade100,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: isLoading
            ? const Center(
                child: SpinKitSpinningLines(
                  color: Colors.black,
                  size: 50.0,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 10.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/MovieIcon.png"),
                      SizedBox(height: 70),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await signInWithGoogle(context);
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 28,
                                  child: Image.asset(
                                      "assets/images/googleIcon.png")),
                              const Expanded(
                                  flex: 60,
                                  child: Text(
                                    "Signup With Google",
                                    style: TextStyle(color: Colors.black),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: Colors.transparent),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await signInWithFacebook(context);
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.0,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 28,
                                child: Image.asset(
                                    "assets/images/facebookIcon.png"),
                              ),
                              const Expanded(
                                flex: 60,
                                child: Text(
                                  "Signup With Facebook",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Ye login ki jo screen hoti hai wo display karta hai or agar login sahi se
      // hau to facebook se login karwane ke liye token leke aata hai
      final LoginResult loginResult = await FacebookAuth.instance.login();
      // firebase se login hone ke baad ye uske credential leta hai
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      // ye firebase me signin karwata hai
      // aur facebook ke auth se firebase auth ka object banata hai jisko apan aage use karte hai
      final UserCredential authResult = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      User? user = authResult.user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LandingPage(
                    userCredential: authResult.user,
                    providerId: authResult.credential?.providerId ?? "NULL",
                  )),
        );
      } else {
        log("FirebaseAuth.instance.currentUser -- User is null---------");
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }
}
