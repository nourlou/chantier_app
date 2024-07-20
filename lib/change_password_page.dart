import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Form fields and logic to change password
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: const Color.fromARGB(255, 167, 178, 197),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            // Additional fields and save button
          ],
        ),
      ),
    );
  }
}
