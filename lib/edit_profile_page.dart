import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const EditProfilePage({Key? key, required this.userName, required this.userEmail}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Perform operations to save changes
    String newName = _nameController.text;
    String newEmail = _emailController.text;

    // Example: Update user's profile information in the database
    // Example: Show a snackbar or dialog indicating that changes have been saved

    // Navigate back to the profile page with the updated information
    Navigator.pop(context, {'userName': newName, 'userEmail': newEmail});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 167, 178, 197),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              controller: _emailController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
