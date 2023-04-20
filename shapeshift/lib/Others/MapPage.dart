// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key, required String userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
      ),
      body: const Center(
        child: Text('This is a blank map page.'),
      ),
    );
  }
}
