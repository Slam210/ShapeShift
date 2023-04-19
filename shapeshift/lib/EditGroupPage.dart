// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'GroupClass.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;
  final String username;

  const EditGroupPage({Key? key, required this.group, required this.username})
      : super(key: key);

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  bool _isCreator = false;
  final _newGroupNameController = TextEditingController();
  late Group _group;

  void _updateGroupName(String newName) {
    DatabaseReference groupRef = FirebaseDatabase.instance
        .ref()
        .child('groups')
        .child(_group.id)
        .child('name');
    groupRef.set(newName).then((value) {
      // The value is the DatabaseReference returned by the set() method
      // You can add any additional logic that needs to be executed after the
      // update is successful.
    }).catchError((error) {
      // Handle the error that occurred during the update
    });
  }

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _isCreator = _group.creator == widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Group: ${_group.name}"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isCreator)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newGroupNameController,
                      decoration: const InputDecoration(
                        hintText: "New Group Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _updateGroupName(_newGroupNameController.text);
                      setState(() {
                        _group.name = _newGroupNameController.text;
                      });
                    },
                    child: const Text("Update"),
                  )
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Members",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _group.members.length,
                    itemBuilder: (context, index) {
                      final member = _group.members[index];
                      return ListTile(
                        title: Text(member),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('Group')
                                  .doc(_group.id)
                                  .update({
                                'members': FieldValue.arrayRemove([member])
                              });
                              setState(() {
                                _group = _group.copyWith(
                                    members: _group.members..remove(member));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("User removed from group")),
                              );
                            } catch (e) {
                              if (kDebugMode) {
                                print("Error removing user from group: $e");
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "An error occurred while removing the user"),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
