import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:chantier_test/interceptor.dart';

// Modèle de client
class Client {
  String raisonSociale;
  String codeTVA;
  String contact;
  String gsm1;
  String gsm2;
  String email;
  String adresse;
  String ville;
  int categorie; // Change to int
  int? id;

  Client({
    required this.raisonSociale,
    required this.codeTVA,
    required this.contact,
    required this.gsm1,
    required this.gsm2,
    required this.email,
    required this.adresse,
    required this.ville,
    required this.categorie,
    this.id,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      raisonSociale: json['raisonSociale'] ?? '',
      codeTVA: json['codeTVA'] ?? '',
      contact: json['contact'] ?? '',
      gsm1: json['gsm1'] ?? '',
      gsm2: json['gsm2'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] ?? '',
      ville: json['ville'] ?? '',
      categorie: json['categorie'] ?? 0, // Default to 0 if not provided
      id: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raisonSociale': raisonSociale,
      'codeTVA': codeTVA,
      'contact': contact,
      'gsm1': gsm1,
      'gsm2': gsm2,
      'email': email,
      'adresse': adresse,
      'ville': ville,
      'categorie': categorie, // Change to int
      if (id != null) 'id': id,
    };
  }
}


List<Client> parseClient(List<dynamic> jsonList) {
  return jsonList.map((json) => Client.fromJson(json)).toList();
}

class GestionClientPage extends StatefulWidget {
  @override
  _GestionClientPageState createState() => _GestionClientPageState();
}

class _GestionClientPageState extends State<GestionClientPage> {
  TextEditingController raisonSocialeController = TextEditingController();
  TextEditingController codeTVAController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController gsm1Controller = TextEditingController();
  TextEditingController gsm2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController villeController = TextEditingController();
  TextEditingController categorieController =
      TextEditingController(); // Nouveau contrôleur pour la catégorie

  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    fetchDataClient();
  }

  Future<void> fetchDataClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/clients';

    try {
      var response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          clients = parseClient(response.data);
        });
      } else {
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          type: DioErrorType.response,
          error: 'Failed to load data - status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      String errorMessage =
          'Failed to fetch client details. Please try again later.';
      if (e is DioError) {
        if (e.response != null) {
          errorMessage =
              'HTTP error ${e.response!.statusCode}: ${e.response!.statusMessage}';
          // Log additional details
          print('Error data: ${e.response!.data}');
          print('Error headers: ${e.response!.headers}');
        } else {
          errorMessage = 'Request failed due to network issues or timeout.';
          print('Error message: ${e.message}');
        }
      } else {
        print('Unexpected error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  Future<void> addClient(Map<String, dynamic> clientData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    if (authToken == null || entrepriseId == null) {
      _showSnackBar('Authentication error. Please log in again.');
      return;
    }

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/clients/addClient';

    final sanitizedData = {
      "raisonSociale": clientData["raisonSociale"] ?? '',
      "codeTVA": clientData["codeTVA"] ?? '',
      "contact": clientData["contact"] ?? '',
      "gsm1": clientData["gsm1"] ?? '',
      "gsm2": clientData["gsm2"] ?? '',
      "email": clientData["email"] ?? '',
      "adresse": clientData["adresse"] ?? '',
      "ville": clientData["ville"] ?? '',
    };

    try {
      var response = await dio.post(
        url,
        data: jsonEncode(sanitizedData),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Client added successfully!');
        fetchDataClient();
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        _showSnackBar('Error: ${response.data}');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      _showSnackBar('Network error. Please try again later.');
    }
  }
void _showEditClientDialog(BuildContext context, Client client) {
  // Initialize text controllers with current client data
  raisonSocialeController.text = client.raisonSociale;
  codeTVAController.text = client.codeTVA;
  contactController.text = client.contact;
  gsm1Controller.text = client.gsm1;
  gsm2Controller.text = client.gsm2;
  emailController.text = client.email;
  adresseController.text = client.adresse;
  villeController.text = client.ville;
  categorieController.text = client.categorie.toString();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Client'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: raisonSocialeController,
                decoration: InputDecoration(labelText: 'Raison Sociale'),
              ),
              TextField(
                controller: codeTVAController,
                decoration: InputDecoration(labelText: 'Code TVA'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: gsm1Controller,
                decoration: InputDecoration(labelText: 'GSM1'),
              ),
              TextField(
                controller: gsm2Controller,
                decoration: InputDecoration(labelText: 'GSM2'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextField(
                controller: villeController,
                decoration: InputDecoration(labelText: 'Ville'),
              ),
              TextField(
                controller: categorieController,
                decoration: InputDecoration(labelText: 'Categorie'),
                keyboardType: TextInputType.number, // Ensure numeric input
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
  onPressed: () {
    // Debugging: Add print statements to ensure this block is executed
    print('Update button pressed');

    int categorie;
    try {
      categorie = int.parse(categorieController.text);
      print('Categorie parsed: $categorie');
    } catch (e) {
      print('Error parsing categorie: $e');
      return;
    }

    final updatedClient = Client(
      id: client.id,
      raisonSociale: raisonSocialeController.text,
      codeTVA: codeTVAController.text,
      contact: contactController.text,
      gsm1: gsm1Controller.text,
      gsm2: gsm2Controller.text,
      email: emailController.text,
      adresse: adresseController.text,
      ville: villeController.text,
      categorie: categorie,
    );

    print('Updated client: ${updatedClient.toJson()}');
    
    // Call the updateClient function and check if it gets executed
    updateClient(updatedClient);
  },
  child: Text('Update Client'),
),

        ],
      );
    },
  );
}

Future<void> updateClient(Client client) async {
  print('Starting updateClient');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  if (authToken == null || entrepriseId == null) {
    print('Auth token or entrepriseId is null');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authentication error. Please log in again.'),
      ),
    );
    return;
  }

  if (client.raisonSociale.isEmpty ||
      client.codeTVA.isEmpty ||
      client.contact.isEmpty ||
      client.gsm1.isEmpty ||
      client.email.isEmpty ||
      client.adresse.isEmpty ||
      client.ville.isEmpty ||
      client.categorie <= 0) {
    print('Validation failed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All fields must be filled.'),
      ),
    );
    return;
  }

  Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

  var url = 'http://localhost:8080/api/clients/updateClient/${client.id}';

  try {
    var dataToSend = client.toJson();
    print('Data to be sent: $dataToSend');

    var response = await dio.put(
      url,
      data: jsonEncode(dataToSend),
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Client updated successfully');
      fetchDataClient();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client updated successfully.'),
        ),
      );
    } else {
      print('Failed to update client: ${response.statusCode}');
      print('Response body: ${response.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update client. Please try again.'),
        ),
      );
    }
  } catch (e) {
    print('Error updating client: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error. Please try again later.'),
      ),
    );
  }
}



  Future<void> deleteClient(Client client) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/clients/deleteClient/${client.id}';

    try {
      var response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      if (response.statusCode == 204) {
        fetchDataClient();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client deleted successfully.'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting client: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete client. Please try again later.'),
        ),
      );
    }
  }


  void _showDeleteConfirmationDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Client'),
          content: Text('Are you sure you want to delete this client?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteClient(client);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

void _showAddClientDialog() {
  raisonSocialeController.clear();
  codeTVAController.clear();
  contactController.clear();
  gsm1Controller.clear();
  gsm2Controller.clear();
  emailController.clear();
  adresseController.clear();
  villeController.clear();
  categorieController.clear(); // This should be handled as integer selection

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Client'),
        content: Column(
          children: [
            TextField(
              controller: raisonSocialeController,
              decoration: InputDecoration(labelText: 'Raison Sociale'),
            ),
            TextField(
              controller: codeTVAController,
              decoration: InputDecoration(labelText: 'Code TVA'),
            ),
            TextField(
              controller: contactController,
              decoration: InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: gsm1Controller,
              decoration: InputDecoration(labelText: 'GSM1'),
            ),
            TextField(
              controller: gsm2Controller,
              decoration: InputDecoration(labelText: 'GSM2'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: adresseController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextField(
              controller: villeController,
              decoration: InputDecoration(labelText: 'Ville'),
            ),
            // Convert to DropdownButton or other suitable input for integers
            TextField(
              controller: categorieController,
              keyboardType: TextInputType.number, // Ensure numeric input
              decoration: InputDecoration(labelText: 'Categorie (ID)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newClient = Client(
                raisonSociale: raisonSocialeController.text,
                codeTVA: codeTVAController.text,
                contact: contactController.text,
                gsm1: gsm1Controller.text,
                gsm2: gsm2Controller.text,
                email: emailController.text,
                adresse: adresseController.text,
                ville: villeController.text,
                categorie: int.tryParse(categorieController.text) ?? 0, // Convert to int
              );
              addClient(newClient.toJson());
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Gestion des Clients'),
      backgroundColor: const Color.fromARGB(255, 187, 203, 216),
    ),
    backgroundColor: Color(0xFFdeedfb), // Bleu ciel pour le fond du Scaffold
    body: ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          color: Colors.white, // Fond blanc pour les cartes pour le contraste
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(
              client.raisonSociale,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Contact: ${client.contact}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code TVA: ${client.codeTVA}'),
                    Text('contact: ${client.contact}'),
                    Text('GSM1: ${client.gsm1}'),
                    Text('GSM2: ${client.gsm2}'),
                    Text('Email: ${client.email}'),
                    Text('Adresse: ${client.adresse}'),
                    Text('Ville: ${client.ville}'),
                    Text('categorie: ${client.categorie}'),
                  ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditClientDialog(context, client),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context, client),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddClientDialog,
      child: Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 185, 203, 218),
    ),
  );
}

}
