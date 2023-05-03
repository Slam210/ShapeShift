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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Workouts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Group')
                  .doc(_group.id)
                  .collection('workouts')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Text('Loading...');
                }

                final documents = snapshot.data!.docs;

                if (documents.isEmpty) {
                  return const Text('There are no workouts.');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final workout = documents[index];
                          return FutureBuilder<DocumentSnapshot>(
                            future: workout.reference.get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Error loading workout');
                              }

                              if (!snapshot.hasData) {
                                return const Text('Loading workout...');
                              }

                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final title = data['title'];
                              final description = data['description'];

                              if (title != null && title.isNotEmpty) {
                                return Dismissible(
                                  key: ValueKey(workout.id),
                                  onDismissed: (direction) async {
                                    try {
                                      // Delete the document from Firestore
                                      await workout.reference.delete();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('$title deleted.'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'An error occurred while deleting $title.'),
                                        ),
                                      );
                                    }
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  child: ListTile(
                                    title: Text(title),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(title),
                                            content: Text(description),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Close',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get a list of workouts from Firebase
              List<Map<String, dynamic>> workouts = [];
              try {
                final snapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.username)
                    .collection('workouts')
                    .get();
                if (snapshot.docs.isNotEmpty) {
                  workouts = snapshot.docs.map((doc) => doc.data()).toList();
                }
              } catch (e) {
                if (kDebugMode) {
                  print("Error getting workouts from Firebase: $e");
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("An error occurred while getting workouts"),
                  ),
                );
                return;
              }

              // Show a dialog with a list of workouts
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Select a workout"),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: workouts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final workout = workouts[index];
                          return ListTile(
                            title: Text(workout['title']),
                            onTap: () {
                              Navigator.of(context).pop(workout);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ).then((selectedWorkoutData) async {
                if (selectedWorkoutData != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('Group')
                        .doc(_group.id)
                        .collection('workouts')
                        .add(selectedWorkoutData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Workout added")),
                    );
                  } catch (e) {
                    if (kDebugMode) {
                      print("Error adding workout: $e");
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("An error occurred while adding the workout"),
                      ),
                    );
                  }
                }
              });
            },
            child: const Text("Add Workout"),
          )
        ],
      ),
    );
  }
}
