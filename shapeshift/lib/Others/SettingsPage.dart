// ignore_for_file: file_names, use_build_context_synchronously, must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Start/ResetPasswordPage.dart';
import '../Start/SignInPage.dart';

class SettingsPage extends StatefulWidget {
  String userId;
  SettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userId);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'User Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(FirebaseAuth.instance.currentUser!.email ?? ''),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Change Password',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResetPasswordPage()),
                  );
                },
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Reset login password',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear Data'),
              subtitle: const Text('Delete all workout routines'),
              trailing: const Icon(Icons.delete),
              onTap: () async {
                // Delete all workout routines for the user
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('workouts')
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.delete();
                  }
                });
              },
            ),
            ListTile(
              title: const Text('Delete All Routines and Quit All Groups'),
              subtitle: const Text('Delete all routines and leave all groups'),
              trailing: const Icon(Icons.delete_forever),
              onTap: () async {
                // Delete all workout routines for the user
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('workouts')
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.delete();
                  }
                });

                // Delete all groups for the user MAKE THIS ACTUALLY WORK
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('groups')
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.delete();
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
