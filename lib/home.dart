import 'package:depstar_docs/auth_controller.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await AuthService().signout(context: context);
          },
          child: const Icon(
            Icons.logout,
          ),
          ),
      appBar: AppBar(
        title: const Text("Depstar Docs"),
      ),
    );
  }
}
