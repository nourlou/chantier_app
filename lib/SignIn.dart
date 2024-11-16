import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chantier_test/constants.dart'; // Assuming this is where `prColor` is defined

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<void> _handleSignIn() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez entrer à la fois le nom d\'utilisateur et le mot de passe')),
    );
    return;
  }

  var url = Uri.parse('http://localhost:8080/account/login'); // Adjust URL as needed
  var body = jsonEncode({
    'username': username,
    'password': password,
  });

  try {
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        print('Response body: ${response.body}'); // Log the entire response for debugging

        var token = jsonResponse['token'] ?? '';
        var userId = jsonResponse['user']?['id'] ?? 0;
        var entrepriseId = jsonResponse['user']?['entreprise']?['id'] ?? 0;
        var userRole = jsonResponse['user']?['role'] ?? '';
        var userName = jsonResponse['user']?['fullName'] ?? 'Unknown User'; // Use fullName
        var userEmail = jsonResponse['user']?['username'] ?? 'Unknown Email'; // Use username

        print('User ID: $userId');
        print('Entreprise ID: $entrepriseId');
        print('Token: $token');
        print('User Role: $userRole');
        print('User Name: $userName');
        print('User Email: $userEmail');

        // Save the token and other data in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);
        await prefs.setInt('entrepriseId', entrepriseId);
        await prefs.setString('userRole', userRole);
        await prefs.setString('userName', userName); // Save fullName
        await prefs.setString('userEmail', userEmail); // Save username

        // Navigate to the appropriate dashboard based on the user role
        if (userRole.toLowerCase() == 'admin') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (userRole.toLowerCase() == 'chef') {
          Navigator.pushReplacementNamed(context, '/gestionChantierPourChef');
        } else if (userRole.toLowerCase() == 'finance') {
          Navigator.pushReplacementNamed(context, '/DashboardFiance');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rôle d\'utilisateur inconnu : $userRole. Veuillez contacter le support.')),
          );
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'analyse de la réponse du serveur.')),
        );
      }
    } else {
      print('Failed to sign in: ${response.statusCode}');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la connexion. Veuillez vérifier vos identifiants.')),
      );
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur réseau. Veuillez réessayer plus tard.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'image/image1.jpg',
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                ),
              ),
              Row(
                children: [
                  Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Add logic for changing the password here
                    },
                    child: Text(
                      "Changer le mot de passe",
                      style: TextStyle(color: prColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Connexion'),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous n'avez pas de compte ?",
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(color: prColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
