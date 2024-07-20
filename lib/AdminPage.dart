import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  final String adminName;

  const AdminPage({Key? key, required this.adminName}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<User> users = [];

  String? _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome ${widget.adminName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showAddUserDialog();
              },
              child: Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
            SizedBox(height: 16),
            if (widget.adminName.toLowerCase() == 'Chef') // Vérifie le rôle de l'utilisateur pour afficher le bouton de gestion des chantiers uniquement pour le chef
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/chantiers'); // Navigation vers la page de gestion des chantiers
                },
                child: Text('Gérer les chantiers'),
              ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(users[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(users[index].email, style: TextStyle(color: Colors.black54)), // Afficher l'email
                          Text(users[index].role.value, style: TextStyle(color: Colors.blueAccent)), // Afficher le rôle correctement
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _editUser(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteUser(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    _nameController.clear();
    _emailController.clear();
    _selectedRole = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                ],
                decoration: InputDecoration(labelText: 'Select Role'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveUser();
                Navigator.pop(context);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveUser() {
    if (_nameController.text.isNotEmpty && _selectedRole != null && _emailController.text.isNotEmpty) {
      setState(() {
        users.add(User(
          name: _nameController.text,
          email: _emailController.text,
          role: UserRoleExtension.fromString(_selectedRole!),
        ));
        _nameController.clear();
        _emailController.clear();
        _selectedRole = null;
      });
    }
  }

  void _editUser(int index) async {
    _nameController.text = users[index].name;
    _emailController.text = users[index].email;
    _selectedRole = users[index].role.value;

    final updatedUser = await showDialog<User>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                ],
                decoration: InputDecoration(labelText: 'Select Role'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, User(
                  name: _nameController.text,
                  email: _emailController.text,
                  role: UserRoleExtension.fromString(_selectedRole!),
                ));
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
          ],
        );
      },
    );

    if (updatedUser != null) {
      setState(() {
        users[index] = updatedUser;
      });
    }
  }

  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }
}

class User {
  String name;
  String email;
  UserRole role;

  User({required this.name, required this.email, required this.role});
}

enum UserRole { admin, chef, finance }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.chef:
        return 'chef';
      case UserRole.finance:
        return 'finance';
      default:
        return '';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'chef':
        return UserRole.chef;
      case 'finance':
        return UserRole.finance;
      default:
        throw ArgumentError('Invalid UserRole string: $value');
    }
  }
  
}
