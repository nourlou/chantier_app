import 'package:flutter/material.dart';

class User {
  String name;
  String email;
  String password;
  String role;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

final List<User> users = []; // Liste des utilisateurs

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedRole;
  bool _obscurePassword = true;
  SortOptions _sortOption = SortOptions.name;

  final List<String> roles = ['Chef', 'Finance']; // Liste des rôles

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _validateFields() {
    if (_fullNameController.text.isEmpty) {
      _showSnackBar('Please enter a full name');
      return false;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter an email');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Please enter a valid email');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password');
      return false;
    }
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _showSnackBar('Please select a role');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void _sortUsers(SortOptions option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case SortOptions.name:
          users.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOptions.email:
          users.sort((a, b) => a.email.compareTo(b.email));
          break;
        case SortOptions.role:
          users.sort((a, b) => a.role.compareTo(b.role));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        actions: [
          PopupMenuButton<SortOptions>(
            onSelected: _sortUsers,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOptions>>[
              const PopupMenuItem<SortOptions>(
                value: SortOptions.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.email,
                child: Text('Sort by Email'),
              ),
              const PopupMenuItem<SortOptions>(
                value: SortOptions.role,
                child: Text('Sort by Role'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate(users));
            },
          ),
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                'No users available. Add some users!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        user.name[0],
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('${user.email} - ${user.role}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.green,
                          onPressed: () {
                            _showEditUserDialog(context, user);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              users.removeAt(index);
                            });
                            _showSnackBar('User deleted');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedRole = roles[0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: _obscurePassword,
                ),
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
                  // Ajouter l'utilisateur à la liste
                  User newUser = User(
                    name: _fullNameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    role: _selectedRole ?? '', // Utiliser le rôle sélectionné
                  );
                  setState(() {
                    users.add(newUser);
                  });
                  // Effacer les contrôleurs de texte
                  _fullNameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                  // Fermer la boîte de dialogue
                  Navigator.of(context).pop();
                  _showSnackBar('User added');
                }
              },
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Couleur du bouton Ajouter
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    // Créer des contrôleurs de texte avec les valeurs initiales des propriétés de l'utilisateur
    TextEditingController fullNameController =
        TextEditingController(text: user.name);
    TextEditingController emailController =
        TextEditingController(text: user.email);
    TextEditingController passwordController =
        TextEditingController(text: user.password);

    String? selectedRole = user.role; // Stocker le rôle sélectionné

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
                  // Mettre à jour l'utilisateur avec les nouvelles valeurs
                  setState(() {
                    user.name = fullNameController.text;
                    user.email = emailController.text;
                    user.password = passwordController.text;
                    user.role = selectedRole ?? user.role;
                  });
                  Navigator.of(context).pop();
                  _showSnackBar('User updated');
                }
              },
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Couleur du bouton Mettre à jour
              ),
            ),
          ],
        );
      },
    );
  }
}

class UserSearchDelegate extends SearchDelegate<User> {
  final List<User> users;

  UserSearchDelegate(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = users
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            close(context, user);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = users
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final user = suggestions[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            query = user.name;
            showResults(context);
          },
        );
      },
    );
  }
}

enum SortOptions { name, email, role }

void main() {
  runApp(MaterialApp(
    home: ManageUsersPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
