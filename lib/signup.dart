import 'package:depstar_docs/auth_controller.dart';
import 'package:depstar_docs/signin.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final TextEditingController emailcontroller = TextEditingController(text: "");
  final TextEditingController passwordcontroller =
      TextEditingController(text: "");
  final TextEditingController namecontroller = TextEditingController(text: "");

  @override
  void dispose() {
    super.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
  }

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
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'ex: Smith Johnson',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: passwordcontroller,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter Your Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        } else if (!RegExp(r'[A-Z]').hasMatch(value) ||
                            !RegExp(r'[a-z]').hasMatch(value) ||
                            !RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Password must contain upper, lower case letters and numbers';
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
                        await AuthService().signup(
                          email: emailcontroller.text,
                          password: passwordcontroller.text,
                          context: context,
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                        );
                      },
                      child: const Text('Already have an account? Sign In'),
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
