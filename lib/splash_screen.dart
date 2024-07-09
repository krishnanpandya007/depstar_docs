import 'dart:async';
import 'package:depstar_docs/home.dart';
import 'package:depstar_docs/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is signed in
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => MyHomePage()));
      } else {
        // User is not signed in
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => SignIn()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.png'),
      ),
    );
  }
}
