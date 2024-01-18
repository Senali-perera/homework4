import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:homework4/services/notification_service.dart';
import 'package:homework4/todo/todo_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const fetchBackground = "fetchBackground";
bool _accelAvailable = false;
List<double> _accelData = List.filled(3, 0.0);
StreamSubscription? _accelSubscription;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  NotificationService().initNotification();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        _checkAccelerometerStatus();
        if(_accelAvailable){
          _startAccelerometer();
          if(_accelData[0].abs()>10 || _accelData[1].abs()>10 || _accelData[2].abs()>10){
            NotificationService().showNotification(title: "Todo App", body: 'Phone shaked!');
          }
        }
      }
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
      },
    );
  });
}

void _checkAccelerometerStatus() async {
  await SensorManager()
      .isSensorAvailable(Sensors.ACCELEROMETER)
      .then((result) {
      _accelAvailable = result;
  });
}

Future<void> _startAccelerometer() async {
  if (_accelSubscription != null) return;
  if (_accelAvailable) {
    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_FASTEST,
    );
    _accelSubscription = stream.listen((sensorEvent) {
        _accelData = sensorEvent.data;
    });
  }
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