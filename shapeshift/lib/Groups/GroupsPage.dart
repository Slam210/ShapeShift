// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'EditGroupPage.dart';
import 'GroupClass.dart';
import 'GroupsJoinCreatePage.dart';

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
    final groupsSnapshot =
        await FirebaseFirestore.instance.collection('Group').get();

    final joinedGroups = groupsSnapshot.docs
        .where((doc) => doc['members'].contains(widget.username))
        .map((doc) => Group.fromDocument(doc))
        .toList();
    final createdGroups = groupsSnapshot.docs
        .where((doc) => doc['creator'] == widget.username)
        .map((doc) => Group.fromDocument(doc))
        .toList();

    setState(() {
      _joinedGroups = joinedGroups;
      _createdGroups = createdGroups;
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
              shrinkWrap: true,
              itemCount: _createdGroups.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_createdGroups[index].id),
                  onDismissed: (direction) async {
                    final group = _createdGroups[index];
                    await FirebaseFirestore.instance
                        .collection('Group')
                        .doc(group.id)
                        .delete()
                        .then((_) async {
                      // Delete the sub-collections
                      await FirebaseFirestore.instance
                          .collection('Group')
                          .doc(group.id)
                          .collection('workouts')
                          .get()
                          .then((querySnapshot) {
                        for (var doc in querySnapshot.docs) {
                          doc.reference.delete();
                        }
                      });

                      await FirebaseFirestore.instance
                          .collection('Group')
                          .doc(group.id)
                          .collection('locations')
                          .get()
                          .then((querySnapshot) {
                        for (var doc in querySnapshot.docs) {
                          doc.reference.delete();
                        }
                      });
                    });

                    setState(() {
                      _createdGroups.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Group '${group.name}' deleted"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: ListTile(
                    title: Text(_createdGroups[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroupPage(
                            group: _createdGroups[index],
                            username: widget.username,
                          ),
                        ),
                      ).then((value) => _getGroups());
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Group ID'),
                          content: Text(_createdGroups[index].id),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: _createdGroups[index].id,
                                ));
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Copy',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Groups You've Joined:"),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _joinedGroups
                  .where((group) => group.creator != widget.username)
                  .length,
              itemBuilder: (context, index) {
                final joinedGroupsList = _joinedGroups
                    .where((group) => group.creator != widget.username)
                    .toList();
                final group = joinedGroupsList[index];
                return Dismissible(
                  key: Key(group.id),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (direction) async {
                    return await showDialog(
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
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text("Leave"),
                              onPressed: () async {
                                FirebaseFirestore.instance
                                    .collection('Group')
                                    .doc(group.id)
                                    .update({
                                  'members':
                                      FieldValue.arrayRemove([widget.username])
                                });

                                // Check if the user leaving the group is the creator
                                final groupDocSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('Group')
                                    .doc(group.id)
                                    .get();
                                final creator = groupDocSnapshot['creator'];
                                if (creator == widget.username) {
                                  await FirebaseFirestore.instance
                                      .collection('Group')
                                      .doc(group.id)
                                      .delete();
                                }

                                Navigator.of(context).pop(true);
                                await _getGroups();
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Group ID'),
                                    content: Text(_createdGroups[index].id),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                            text: _createdGroups[index].id,
                                          ));
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Copy',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(group.name),
                    onTap: () {
                      // Handle onTap
                    },
                  ),
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
                builder: (context) =>
                    GroupsJoinCreatePage(username: widget.username)),
          ).then((value) => _getGroups());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
