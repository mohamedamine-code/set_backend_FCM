import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddLicenseScreen extends StatefulWidget {
  @override
  _AddLicenseScreenState createState() => _AddLicenseScreenState();
}

class _AddLicenseScreenState extends State<AddLicenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _loading = true);

      final fcmToken = await FirebaseMessaging.instance.getToken();
      final expiryDate = _selectedDate!.toIso8601String().split('T').first;

      final uri = Uri.parse('http://192.168.1.15:3000/add-license'); // Replace with your server IP

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'expiryDate': expiryDate,
          'fcmToken': fcmToken,
        }),
      );

      setState(() => _loading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ License added')));
        _nameController.clear();
        _selectedDate = null;
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed: ${response.body}')));
      }
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add License')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Your Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'No date selected'
                        : 'Expiry Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Pick Date'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit License'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
