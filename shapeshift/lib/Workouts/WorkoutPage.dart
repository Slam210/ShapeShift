// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddWorkoutPage.dart';
import 'EditWorkoutPage.dart';

class WorkoutsPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId;
  WorkoutsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return Column(
              children: [
                const SizedBox(height: 16.0),
                Text(
                  'Created',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.35, // Set the height to half the screen height
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot document = documents[index];
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
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Groups',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Group')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      final List<DocumentSnapshot> groupDocuments =
                          snapshot.data!.docs;
                      final List<DocumentSnapshot> joinedGroupDocuments =
                          groupDocuments
                              .where((doc) => (doc['members'] as List<dynamic>)
                                  .contains(userId))
                              .toList();

                      return SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.35, // Set the height to half the screen height
                        child: ListView.builder(
                          itemCount: joinedGroupDocuments.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot groupDoc =
                                joinedGroupDocuments[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16.0),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: groupDoc.reference
                                        .collection('workouts')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        final List<DocumentSnapshot>
                                            workoutDocs = snapshot.data!.docs;
                                        return ListView.builder(
                                          itemCount: workoutDocs.length - 1,
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot workoutDoc =
                                                workoutDocs[index];
                                            return ListTile(
                                              title: Text(workoutDoc['title']),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          workoutDoc['title']),
                                                      content: Text(workoutDoc[
                                                          'description']),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
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
