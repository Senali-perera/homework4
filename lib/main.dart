import 'package:flutter/material.dart';
import 'package:homework4/services/notification_service.dart';
import 'package:homework4/todo/todo_list.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  NotificationService().initNotification();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'TODO List App';

    return MaterialApp(
      title: title,
      home: TodoList(),
    );
  }
}