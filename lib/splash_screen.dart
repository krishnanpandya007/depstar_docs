// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depstar_docs/commete.dart';
import 'package:depstar_docs/signin.dart';
import 'package:depstar_docs/verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool dataLoaded = false;
  Map<String, dynamic> globalMap = {};
  Map<String, dynamic> contactMap = {};

  @override
  void initState() {
    super.initState();
    // load data
    loadData() async {
      FirebaseFirestore db = FirebaseFirestore.instance;

      Timer(const Duration(seconds: 2), () {});
      await db.collection("Comeetee").get().then((event) {
        print(event.docs);
        for (var doc in event.docs) {
          print("${doc.id} => ${doc.data()}");
          globalMap[doc.id] = jsonDecode(doc.data()["child"]);
        }
      });
      await db.collection("Contact").get().then((event) {
        for (var doc in event.docs) {
          contactMap[doc.id] = jsonDecode(doc.data()["child"]);
        }
      });

      print("HelloPrinter:::");

      print(globalMap);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: ((context) => CometeePage(
                // ignore: prefer_const_literals_to_create_immutables
                navigationStack: [],
                globalMap: globalMap,
                contactMap: contactMap,
              ))));
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        loadData();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const Verify(),
          ),
        );
      }
    } else {
      Future.delayed(
        Duration.zero,
        () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const SignIn(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20.0,
            ),
            Text('DEPSTAR DOCS'),
          ],
        ),
      ),
    );
  }
}
