// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({Key? key, required this.user}) : super(key: key);

  final dynamic user;

  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Group'),
      ),
      body: const Center(
        child: Text('Empty Page for Join Group'),
      ),
    );
  }
}
