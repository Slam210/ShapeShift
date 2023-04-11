// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String errorMessage = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your email address to reset your password',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@')) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      String email = emailController.text;
                      try {
                        if (kDebugMode) {
                          print(
                              'Checking if $email is registered with Firebase...');
                        } // Debugging statement
                        List<String> signInMethods = await FirebaseAuth.instance
                            .fetchSignInMethodsForEmail(email);
                        if (signInMethods.isEmpty) {
                          if (kDebugMode) {
                            print('$email is not registered with Firebase.');
                          } // Debugging statement
                          errorMessage =
                              'This email is not registered with Firebase.';
                          emailController.clear();
                        } else {
                          if (kDebugMode) {
                            print('$email is registered with Firebase.');
                          } // Debugging statement
                          if (kDebugMode) {
                            print('Sending password reset email to $email...');
                          } // Debugging statement
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);
                          if (kDebugMode) {
                            print('Password reset email sent successfully.');
                          } // Debugging statement
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password reset email sent successfully.'),
                            ),
                          );
                          emailController.clear();
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error sending password reset email: $e');
                        } // Debugging statement
                        errorMessage = 'Error sending password reset email.';
                        emailController.clear();
                      }
                    }
                  },
                  child: const Text('Reset Password'),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
