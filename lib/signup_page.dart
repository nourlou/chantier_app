import 'dart:convert';
import 'package:chantier_test/DashboardPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _societeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S\'inscrire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nom complet
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Nom complet'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom complet';
                    }
                    return null;
                  },
                ),
                // E-mail
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse e-mail';
                    } else if (!_validateEmail(value)) {
                      return 'Veuillez entrer une adresse e-mail valide';
                    }
                    return null;
                  },
                ),
                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    } else if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    } else if (!_validatePassword(value)) {
                      return 'Le mot de passe doit contenir au moins un chiffre et un caractère spécial';
                    }
                    return null;
                  },
                ),
                // Nom de la société
                TextFormField(
                  controller: _societeController,
                  decoration: InputDecoration(labelText: 'Nom de la société'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de votre société';
                    }
                    return null;
                  },
                ),
                // Numéro de téléphone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    } else if (!_validatePhone(value)) {
                      return 'Le numéro de téléphone doit contenir exactement 8 chiffres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm();
                    }
                  },
                  child: Text('S\'inscrire'),
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
  final fullName = _fullNameController.text;
  final username = _usernameController.text;
  final password = _passwordController.text;
  final EntrepriseName = _societeController.text;
  final phone = _phoneController.text;

  final Map<String, dynamic> formData = {
    'fullName': fullName,
    'EntrepriseName': EntrepriseName,
    'username': username,
    'password': password,
    'phone': phone,
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/account/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(formData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userName: fullName,
            userEmail: username,
          ),
        ),
      );
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : Cet e-mail ou nom d\'utilisateur est déjà utilisé.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'inscription : ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}


  // Validation du format de l'e-mail
  bool _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  // Validation du mot de passe (minimum un chiffre et un caractère spécial)
  bool _validatePassword(String value) {
    final passwordRegex = RegExp(r'^(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(value);
  }

  // Validation du numéro de téléphone (exactement 8 chiffres)
  bool _validatePhone(String value) {
    final phoneRegex = RegExp(r'^\d{8}$');
    return phoneRegex.hasMatch(value);
  }
}
