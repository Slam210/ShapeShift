// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddWorkoutPage.dart';
import 'EditWorkoutPage.dart';

class WorkoutsPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;
  WorkoutsPage({Key? key, required this.userId}) : super(key: key);

  Future<List<QueryDocumentSnapshot>> fetchWorkoutsFromGroups() async {
    List<QueryDocumentSnapshot> workouts = [];

    final groupsDocs = await firestore
        .collection('Group')
        .where((doc) => doc['members'].contains(userId))
        .get();

    // workouts from each group
    for (final groupDoc in groupsDocs.docs) {
      final workoutsCollection = groupDoc.reference.collection('workouts');
      final workoutsDocs = await workoutsCollection.get();
      workouts.addAll(workoutsDocs.docs);
    }

    return workouts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts Page'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchWorkoutsFromGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> groupWorkouts = snapshot.data!;
            return StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('users')
                  .doc(userId)
                  .collection('workouts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final List<DocumentSnapshot> userWorkouts =
                      snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: userWorkouts.length + groupWorkouts.length,
                    itemBuilder: (context, index) {
                      if (index < userWorkouts.length) {
                        final DocumentSnapshot document = userWorkouts[index];
                        return ListTile(
                          title: Text(document['title']),
                          subtitle: Text(document['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              firestore
                                  .collection('users')
                                  .doc(userId)
                                  .collection('workouts')
                                  .doc(document.id)
                                  .delete();
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditWorkoutPage(
                                  userId: userId,
                                  workoutId: document.id,
                                  title: document['title'],
                                  description: document['description'],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // group stuff
                        final QueryDocumentSnapshot document =
                            groupWorkouts[index - userWorkouts.length];
                        return ListTile(
                          title: Text(document['title']),
                          subtitle: Text(document['description']),
                        );
                      }
                    },
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Failed to fetch workouts'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddWorkoutPage(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
