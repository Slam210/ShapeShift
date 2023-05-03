// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'GroupsPage.dart';

class GroupsJoinCreatePage extends StatefulWidget {
  final String username;

  const GroupsJoinCreatePage({Key? key, required this.username})
      : super(key: key);

  @override
  _GroupsJoinCreatePageState createState() => _GroupsJoinCreatePageState();
}

class _GroupsJoinCreatePageState extends State<GroupsJoinCreatePage> {
  late TextEditingController _controller;
  late TextEditingController _groupNameController;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _groupNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create or Join Groups Here"),
        ),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Enter Unique Group Code:"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final groupId = _controller.text;
                    final groupSnapshot = await FirebaseFirestore.instance
                        .collection('Group')
                        .doc(groupId)
                        .get();
                    if (groupSnapshot.exists) {
                      // Join group
                      FirebaseFirestore.instance
                          .collection('Group')
                          .doc(groupId)
                          .update({
                        'members': FieldValue.arrayUnion([widget.username])
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupsPage(username: widget.username),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Group does not exist."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text("Join"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCreating = true;
                    });
                  },
                  child: const Text("Create"),
                ),
              ],
            ),
          ),
          if (_isCreating)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter Group Name:"),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final groupId = FirebaseFirestore.instance
                          .collection('Group')
                          .doc()
                          .id;
                      final groupName = _groupNameController.text.trim();
                      await FirebaseFirestore.instance
                          .collection('Group')
                          .doc(groupId)
                          .set({
                        'name': groupName,
                        'members': [widget.username],
                        'creator': widget.username,
                      }).then((_) {
                        // Add an empty workouts collection to the newly created group document
                        FirebaseFirestore.instance
                            .collection('Group')
                            .doc(groupId)
                            .collection('workouts')
                            .add({});

                        // Add an empty locations collection to the newly created group document
                        FirebaseFirestore.instance
                            .collection('Group')
                            .doc(groupId)
                            .collection('locations')
                            .add({});
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupsPage(username: widget.username),
                        ),
                      );
                    },
                    child: const Text("Create New Group"),
                  ),
                ],
              ),
            ),
        ])));
  }
}
