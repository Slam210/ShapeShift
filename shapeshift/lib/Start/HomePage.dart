// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shapeshift/Others/CalanderPage.dart';
import 'package:shapeshift/Groups/GroupsPage.dart';
import 'package:shapeshift/Others/SettingsPage.dart';
import 'package:shapeshift/Workouts/WorkoutPage.dart';
import 'package:shapeshift/Others/MapPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      setState(() {
        _username = userData['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page of: $_username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarPage(userId: _username)),
                );
              },
              child: const Text('Go to Calendar Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(userId: _username)),
                );
              },
              child: const Text('Go to Map Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupsPage(username: _username)),
                );
              },
              child: const Text('Go to Groups Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(userId: _username)),
                );
              },
              child: const Text('Go to Settings Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutsPage(userId: _username)),
                );
              },
              child: const Text('Go to Workouts Page'),
            ),
          ],
        ),
      ),
    );
  }
}
