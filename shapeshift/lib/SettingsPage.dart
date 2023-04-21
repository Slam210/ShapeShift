// ignore_for_file: file_names, use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Start/SignInPage.dart';

class SettingsPage extends StatelessWidget {
  String userId;
  SettingsPage({Key? key, required this.userId}) : super(key: key);

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
            ListTile(
              title: const Text('Username'),
              subtitle: Text(userId),
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
            const ListTile(
              title: Text('Current Password'),
              subtitle: TextField(),
            ),
            const ListTile(
              title: Text('New Password'),
              subtitle: TextField(),
            ),
            const ListTile(
              title: Text('Confirm New Password'),
              subtitle: TextField(),
            ),
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
                    .doc(userId)
                    .collection('workouts')
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    doc.reference.delete();
                  });
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
                    .doc(userId)
                    .collection('workouts')
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    doc.reference.delete();
                  });
                });

                // Delete all groups for the user
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('groups')
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    doc.reference.delete();
                  });
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
