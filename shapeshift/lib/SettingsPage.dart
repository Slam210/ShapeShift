// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'SignInPage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
            const ListTile(
              title: Text('Username'),
              subtitle: Text('John Doe'), // Replace with user's username
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
              onTap: () {
                // I should put something here
              },
            ),
            ListTile(
              title: const Text('Delete All Routines and Quit All Groups'),
              subtitle: const Text('Delete all routines and leave all groups'),
              trailing: const Icon(Icons.delete_forever),
              onTap: () {
                // we should implement delete all routines and quit all groups functionality
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