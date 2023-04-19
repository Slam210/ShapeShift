// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';

import 'package:shapeshift/Start/ResetPasswordPage.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _navigateToResetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToLogin(context),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToSignup(context),
              child: const Text('Sign up'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToResetPassword(context),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
