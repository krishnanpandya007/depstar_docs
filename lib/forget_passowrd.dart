import 'package:depstar_docs/auth_controller.dart';
import 'package:flutter/material.dart';

class ForgetPassowrd extends StatefulWidget {
  const ForgetPassowrd({super.key});

  @override
  State<ForgetPassowrd> createState() => _ForgetPassowrdState();
}

class _ForgetPassowrdState extends State<ForgetPassowrd> {
  final TextEditingController emailcontroller = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Depstar Docs',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Please Enter your Email to Get Link',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailcontroller,
                      decoration: const InputDecoration(
                        labelText: 'University Email',
                        hintText: 'ex: 21dce001@charusat.edu.in',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.endsWith('@charusat.edu.in') &&
                            !value.endsWith('@charusat.ac.in')) {
                          return 'Please use your Charusat email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        await AuthService().resetpassword(
                          email: emailcontroller.text.trim(),
                        );
                      },
                      child: const Text("Get Link"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
