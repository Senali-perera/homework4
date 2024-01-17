import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homework4/todo/todo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AddTodo extends StatefulWidget {

  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController _textTitleFieldController = TextEditingController();
  final TextEditingController _textDescriptionFieldController = TextEditingController();
  File? _image;
  final imagePicker = ImagePicker();

  void getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: AlertDialog(
        title: const Text('Add a new todo item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textTitleFieldController,
                decoration: const InputDecoration(hintText: 'Enter todo title here'),
              ),
              TextField(
                controller: _textDescriptionFieldController,
                decoration:
                const InputDecoration(hintText: 'Enter todo description here'),
              ),
              TextButton(onPressed: () => getImageFromGallery(), child: const Text("Add an image")
              ),
              Center(child: _image == null ? const Image(image: AssetImage('assets/images/no_image.jpeg')) : Image.file(_image!, fit: BoxFit.fill)
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTodoItem(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<String> saveImageToFileSystem(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = basename(imageFile.path);
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> _addTodoItem(BuildContext context) async {
    String title = _textTitleFieldController.text;
    String description = _textDescriptionFieldController.text;
    String? imagePath;
    String id = DateTime.now().toIso8601String();

    if(_image != null){
      imagePath = await saveImageToFileSystem(_image!);
    }

    Todo todo = Todo(id, title, false, description, imagePath: imagePath);

    Navigator.pop(context, todo);

  }

}
