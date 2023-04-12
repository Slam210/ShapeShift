// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'GroupClass.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage({Key? key, required this.group}) : super(key: key);

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Group: ${widget.group.name}"),
      ),
      body: const Center(
        child: Text("Edit group content here"),
      ),
    );
  }
}
