// ignore_for_file: file_names, library_private_types_in_public_api

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
            return ListView.builder(
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
