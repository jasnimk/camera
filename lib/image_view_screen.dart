import 'package:flutter/material.dart';
import 'dart:io';

class ImageViewScreen extends StatelessWidget {
  final File image;
  final VoidCallback onDelete;

  ImageViewScreen({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}
