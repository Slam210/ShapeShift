// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'EditGroupPage.dart';
import 'GroupClass.dart';
import 'JoinGroup.dart';

class GroupsPage extends StatefulWidget {
  final String username;

  const GroupsPage({Key? key, required this.username}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late List<Group> _joinedGroups;
  late List<Group> _createdGroups;

  @override
  void initState() {
    super.initState();
    _joinedGroups = [];
    _createdGroups = [];
    _getGroups();
  }

  Future<void> _getGroups() async {
    final joinedGroupsSnapshot = await FirebaseFirestore.instance
        .collection('Group')
        .where('members', arrayContains: widget.username)
        .get();
    final createdGroupsSnapshot = await FirebaseFirestore.instance
        .collection('Group')
        .where('creator', isEqualTo: widget.username)
        .get();

    setState(() {
      _joinedGroups = joinedGroupsSnapshot.docs
          .map((doc) => Group.fromDocument(doc))
          .toList()
          .cast<Group>();
      _createdGroups = createdGroupsSnapshot.docs
          .map((doc) => Group.fromDocument(doc))
          .toList()
          .cast<Group>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Groups You've Created:"),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _createdGroups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_createdGroups[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditGroupPage(group: _createdGroups[index])),
                    ).then((value) => _getGroups());
                  },
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Groups You've Joined:"),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _joinedGroups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_joinedGroups[index].name),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Leave Group?"),
                          content: const Text(
                              "Are you sure you want to leave this group?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Leave"),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('Group')
                                    .doc(_joinedGroups[index].id)
                                    .update({
                                  'members':
                                      FieldValue.arrayRemove([widget.username])
                                });
                                Navigator.of(context).pop();
                                _getGroups();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JoinGroupPage(user: widget.username)),
          ).then((value) => _getGroups());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
