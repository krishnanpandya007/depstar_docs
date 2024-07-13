// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:depstar_docs/auth_controller.dart';
import 'package:depstar_docs/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startVerification();
  }

  void startVerification() async {
    await AuthService().emailverification();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify Your email address',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "We have just sent email verification link on your email. Please check email and click on that link to verify your Email address",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "if not auto redirected after verification, click on the Continue button",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 50),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser?.reload();
                  if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
                    timer.cancel();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  } else {
                    print("wait for verification");
                  }
                },
                child: const Text("Continue"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await AuthService().emailverification();
                },
                child: const Text("Resend Email Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
