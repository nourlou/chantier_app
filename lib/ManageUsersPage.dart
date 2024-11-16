import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/src/material/dropdown.dart';

class User {
  final int id; // Include this if your API returns an id
  final String name;
  final String email;
  final String password;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0, // Provide a default value if id is null
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

final List<User> users = []; // List of users

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  String? authToken;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final TextEditingController _entrepriseIdController = TextEditingController();

  String? _selectedRole;
  bool _obscurePassword = true;
  int? _selectedEntrepriseId;

  List<String> _roles = ['Chef de chantier', 'Financer'];
  User? _editingUser;

  @override
  void initState() {
    super.initState();
    _selectedRole = _roles.isNotEmpty ? _roles.first : null;
    print('Initial selected role: $_selectedRole');
    print('Roles: $_roles');
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    fetchAuthToken().then((_) {
      fetchDataUsers();
      setState(() {});
    });
  }

  Future<void> fetchAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void saveAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> loginUser(String email, String password) async {
    Dio dio = Dio();
    var url = 'http://localhost:8080/api/account/login';
    try {
      var response =
          await dio.post(url, data: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        String authToken = response.data['token'];
        saveAuthToken(authToken);
      } else {
        print('Login failed');
      }
    } catch (e) {
      print('Error logging in: $e');
    }
  }

  Future<void> fetchDataUsers() async {
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authorization token is missing. Please log in again.'),
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(authToken!));

    var url =
        'http://localhost:8080/api/utilisateurs?entrepriseId=$entrepriseId';

    try {
      var response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          users.clear();
          users.addAll(parseUser(response.data));
        });
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch user data. Please try again later.'),
        ),
      );
    }
  }

  Future<void> addUser(
    String name, String email, String password, int entrepriseId) async {
  Dio dio = Dio();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');

  if (authToken == null) {
    print('Authentication token is missing.');
    return;
  }

  // Validate input
  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    print('Validation error: All fields are required.');
    return;
  }

  try {
    Map<String, dynamic> data = {
      'fullname': name,
      'username': email,
      'password': password,
      'role': _selectedRole,
      'entrepriseId': entrepriseId
    };

    print('Request Data: $data');

    Response response = await dio.post(
      'http://localhost:8080/api/utilisateurs/addUtilisateur?entrepriseId=$entrepriseId',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      // Si l'utilisateur a été ajouté avec succès, récupère les informations renvoyées
      User newUser = User.fromJson(response.data);

      setState(() {
        users.add(newUser); // Ajoute le nouvel utilisateur à la liste des utilisateurs
      });

      print('User added successfully');
    } else {
      print('Error adding user: ${response.statusCode}');
      print('Error details: ${response.data}');
    }
  } on DioError catch (e) {
    print('Error adding user: ${e.message}');
    if (e.response != null) {
      print('Error details: ${e.response?.data}');
    }
  }
}


  Future<void> deleteUser(User user) async {
    if (authToken == null) return;

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(authToken!));

    try {
      var response = await dio.delete(
        'http://localhost:8080/api/utilisateurs/deleteUtilisateur/${user.id}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          users.remove(user); // Remove user from list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user. Please try again later.'),
        ),
      );
    }
  }

Future<void> editUser(User user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  if (authToken == null || entrepriseId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authorization token or entrepriseId is missing.'),
      ),
    );
    return;
  }

  Dio dio = Dio();
  var url =
      'http://localhost:8080/api/utilisateurs/updateUtilisateur/${user.id}?entrepriseId=$entrepriseId';

  print('Updating user with ID: ${user.id}');
  print('Entreprise ID: $entrepriseId');

  try {
    var response = await dio.put(
      url,
      data: {
        'name': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      // Update the user in the list
      setState(() {
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = User(
            id: user.id,
            name: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            role: _selectedRole!,
          );
        }
      });
      _showSnackBar('User updated successfully');
    } else {
      throw Exception(
          'Impossible de mettre à jour l''utilisateur: ${response.statusCode} - ${response.statusMessage}');
    }
  } catch (e) {
    _showSnackBar('Impossible de mettre à jour l''utilisateur. Veuillez réessayer plus tard.');
    print('Error: $e');
  }
}

void _showUserDialog(BuildContext context, {User? user}) {
  _editingUser = user;
  final _formKey = GlobalKey<FormState>();

  if (user != null) {
    _fullNameController.text = user.name;
    _emailController.text = user.email;
    _passwordController.text = user.password;
    _selectedRole = user.role;
  } else {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedRole = _roles.isNotEmpty ? _roles.first : null;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(user == null ? 'Ajouter nouveau utilisateur' : 'Modifier utilisateur'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Nom Complet'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un nom complet';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un email';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Veuillez saisir un email valide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un mot de passe';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un rôle';
                    }
                    return null;
                  },
                ),
                if (user == null)
                  TextFormField(
                    controller: _entrepriseIdController,
                    decoration: InputDecoration(labelText: 'Entreprise ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un ID d\'entreprise';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Veuillez saisir un ID d\'entreprise valide';
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (user == null) {
                  int? entrepriseId =
                      int.tryParse(_entrepriseIdController.text);
                  if (entrepriseId != null) {
                    addUser(
                      _fullNameController.text,
                      _emailController.text,
                      _passwordController.text,
                      entrepriseId,
                    ).then((_) {
                      fetchDataUsers();
                      Navigator.pop(context);
                    });
                  } else {
                    _showSnackBar('Entreprise ID invalide');
                  }
                } else {
                  editUser(user).then((_) {
                    fetchDataUsers();
                    Navigator.pop(context);
                  });
                }
              }
            },
            child: Text(user == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      );
    },
  );
}
_isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _validateFields() {
    if (_fullNameController.text.isEmpty) {
      _showSnackBar('Veuillez saisir un nom complet');
      return false;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Veuillez saisir un email');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Veuillez saisir un email valide');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Veuillez saisir un mot de passe');
      return false;
    }
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _showSnackBar('Veuillez sélectionner un rôle');
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

  List<User> parseUser(dynamic data) {
  if (data is List) {
    return data.map((json) {
      String name = json['fullName'] ?? json['name'] ?? ''; // Utilisez la propriété qui existe
      return User.fromJson({
        'id': json['id'] ?? 0,
        'name': name,
        'email': json['username'] ?? '',
        'password': json['password'] ?? '',
        'role': json['role'] ?? '',
      });
    }).toList();
  } else {
    return [];
  }
}

  int? parseEntrepriseId(dynamic value) {
    try {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

 Widget _buildUserCard(User user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color.fromARGB(255, 206, 242, 244),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showUserDialog(context, user: user);
                        },
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          _confirmDeleteUser(user);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text('Role: ${user.role}'),
                  SizedBox(height: 8),
                  Text('Email: ${user.email}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 222, 239, 245),
      appBar: AppBar(
        title: Text('Gestion Utilisateurs'),
        backgroundColor: Colors.blue,
      ),

      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(users[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer utilisateur'),
          content: Text('Etes-vous sûr de vouloir supprimer cet utilisateur?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                deleteUser(user); // Call delete function
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    _showUserDialog(context);
  }
}

class AuthInterceptor extends Interceptor {
  final String authToken;

  AuthInterceptor(this.authToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $authToken';
    super.onRequest(options, handler);
  }
} 