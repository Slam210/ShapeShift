// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class AddWorkoutPage extends StatefulWidget {
  final String userId;
  const AddWorkoutPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddWorkoutPageState createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('workouts')
                    .add({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditWorkoutPage extends StatefulWidget {
  final String userId;
  final String workoutId;
  final String title;
  final String description;
  const EditWorkoutPage({
    Key? key,
    required this.userId,
    required this.workoutId,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Workout Title',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('workouts')
                    .doc(widget.workoutId)
                    .update({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
