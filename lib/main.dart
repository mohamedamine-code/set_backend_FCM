import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:send_fcm/pages/add_license_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Registration',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AddLicenseScreen(),
    );
  }
}
