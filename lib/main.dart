import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

// 🔔 Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📥 Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Listen to background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token = '';
  String _notification = 'No notification yet';

  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
  }

  void initFirebaseMessaging() async {
    // Get FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('📱 FCM Token: $token');
    setState(() {
      _token = token;
    });

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message: ${message.notification?.title}');
      setState(() {
        _notification = message.notification?.body ?? 'No content';
      });
    });
  }

  Future<void> sendLicenseData() async {
    final url = Uri.parse('http://192.168.1.17:3000/notify'); // Replace with your local IP
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': 'Mohamed',
        'expiryDate': '2025-12-31',
        'fcmToken': _token,
      }),
    );

    print('🧾 Server response: ${response.body}');
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Notification Demo',
      home: Scaffold(
        appBar: AppBar(title: Text('License Notifier')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SelectableText('FCM Token:\n$_token', style: TextStyle(fontSize: 14)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendLicenseData,
                child: Text('Send License Notification'),
              ),
              SizedBox(height: 20),
              Text('🔔 Last Notification:'),
              Text(_notification, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
