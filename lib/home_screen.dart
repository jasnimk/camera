import 'package:camera_app/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadImages();
  }

  Future<void> _requestPermissions() async {
    await Permission.photos.request();
    await Permission.storage.request();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = '${directory.path}/CameraAppImages';
    final myDir = Directory(dirPath);
    if (!await myDir.exists()) {
      await myDir.create(recursive: true);
    }
    final List<FileSystemEntity> entities = await myDir.list().toList();
    final List<File> files = entities.whereType<File>().toList();
    setState(() {
      _images = files;
    });
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = '${directory.path}/CameraAppImages';
      await Directory(dirPath).create(recursive: true);
      final fileName = basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('$dirPath/$fileName');
      setState(() {
        _images.add(savedImage);
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      _captureImage();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
      ),
      body: Column(
        children: <Widget>[
          if (_selectedIndex == 0)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: (40.0 / 75.5),
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewScreen(
                              image: _images[index],
                              onDelete: () {
                                _deleteImage(_images[index]);
                              }),
                        ),
                      );
                    },
                    child: Image.file(_images[index]),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Capture',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _deleteImage(File image) {
    image.delete();
    setState(() {
      _images.remove(image);
    });
  }
}
