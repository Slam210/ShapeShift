// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'EditGroupPage.dart';
import 'GroupClass.dart';
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
                      final group = Group(
                        id: groupId,
                        name: groupName,
                        members: [widget.username],
                        creator: widget.username,
                      );
                      await FirebaseFirestore.instance
                          .collection('Group')
                          .doc(groupId)
                          .set({
                        'name': groupName,
                        'members': [widget.username],
                        'creator': widget.username
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroupPage(group: group),
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
