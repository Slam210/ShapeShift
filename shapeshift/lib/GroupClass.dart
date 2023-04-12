// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  String name;
  List<String> members;
  String creator;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.creator,
  });

  factory Group.fromDocument(DocumentSnapshot snapshot) {
    return Group(
      id: snapshot.id,
      name: snapshot['name'],
      members: List<String>.from(snapshot['members']),
      creator: snapshot['creator'],
    );
  }
}
