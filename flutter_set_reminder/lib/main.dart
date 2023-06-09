import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_set_reminder/Pages/welcome.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/notify_service.dart';

//import 'package:flutter_set_reminder/signIn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remind Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}
