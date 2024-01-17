import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homework4/services/notification_service.dart';
import 'package:homework4/todo/todo.dart';

import '../database/todo_db.dart';
import 'add_todo.dart';


class TodoList extends StatefulWidget {
  @override
  _TodoListState createState()=>_TodoListState();
}

class _TodoListState extends State<TodoList>{
  List<Todo>? _todos = [];
  final todoDB = TodoDB();

  void loadTodos() async {
    List<Todo> todos = await todoDB.loadAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  void _addTodoItem(BuildContext context) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTodo(),
        ));

    todoDB.insertTodo(result);
    loadTodos();
  }

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Widget _viewTodoItem(Todo todo){
    return ListTile(
      title: Text(todo.title),
      subtitle: Text(todo.description),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          todoDB.deleteTodo(todo.id);
          loadTodos();
        },
      ),
      leading: todo.imagePath == null? const Image(image: AssetImage('assets/images/no_image.jpeg')) : Image.file(File(todo.imagePath!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: ListView.builder(
        itemCount: _todos?.length,
        itemBuilder: (context, index) {
          return _viewTodoItem(_todos![index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          NotificationService().showNotification(title: "sample title", body: 'It works!');
          // _addTodoItem(context);
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}