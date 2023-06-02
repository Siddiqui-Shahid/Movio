import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_login/screens/all_movies.dart';

import 'HomePage.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xffBBDEFB, {
          50: Color(0xffE3F2FD),
          100: Color(0xffBBDEFB),
          200: Color(0xff90CAF9),
          300: Color(0xff64B5F6),
          400: Color(0xff42A5F5),
          500: Color(0xff2196F3),
          600: Color(0xff1E88E5),
          700: Color(0xff1976D2),
          800: Color(0xff1565C0),
          900: Color(0xff0D47A1),
        }),
        canvasColor: Colors.blueGrey.shade900,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
      ),
      home: auth.currentUser != null
          ? LandingPage(
              providerId:
                  auth.currentUser?.providerData.first.providerId ?? "NULL",
              userCredential: auth.currentUser,
            )
          : const MyHomePage(),
    );
  }
}
