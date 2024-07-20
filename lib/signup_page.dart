import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _societeController = TextEditingController(); // Renommé _SocieteController à _societeController
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _societeController,
                  decoration: InputDecoration(labelText: 'Societe Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Societe Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(); // Appeler la fonction de soumission du formulaire
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction de soumission du formulaire
  void _submitForm() async {
    // Récupérer les valeurs des champs
    final fullName = _fullNameController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final EntrepriseName = _societeController.text; 
    
    

    // Préparer les données à envoyer
    final Map<String, dynamic> formData = {
      'fullName': fullName,
      'EntrepriseName': EntrepriseName,
      'username': username,
      'password': password,
    };

    try {
      // Faire une requête POST à votre backend
      final response = await http.post(
        Uri.parse('http://192.168.1.7:8080/account/register'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200 ) {
        // Si la requête est réussie, affichez un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful!')),
        );
        // Rediriger l'utilisateur vers une autre page, par exemple SignInPage
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Gérez les erreurs si la requête a échoué
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed with status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Gérez les erreurs générales
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
