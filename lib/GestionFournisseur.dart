import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:chantier_test/interceptor.dart';
import 'package:http/http.dart' as http;

// Modèle de fournisseur
class Fournisseur {
  String raisonSociale;
  String codeTVA;
  String contact;
  String gsm1;
  String gsm2;
  String email;
  String adresse;
  String ville;
  int? id;

  Fournisseur({
    required this.raisonSociale,
    required this.codeTVA,
    required this.contact,
    required this.gsm1,
    required this.gsm2,
    required this.email,
    required this.adresse,
    required this.ville,
    this.id,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      raisonSociale: json['raisonSociale'] ?? '', // Provide default value if null
      codeTVA: json['codeTVA'] ?? '',
      contact: json['contact'] ?? '', // Ensure no null value is assigned to a String
      gsm1: json['gsm1'] ?? '',
      gsm2: json['gsm2'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] ?? '',
      ville: json['ville'] ?? '',
      id: json['id'] as int?, // Handle nullable integer fields
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
      if (id != null) 'id': id,
    };
  }
}




List<Fournisseur> parseFournisseur(List<dynamic> jsonList) {
  return jsonList.map((json) => Fournisseur.fromJson(json)).toList();
}

class GestionFournisseurPage extends StatefulWidget {
  @override
  _GestionFournisseurPageState createState() => _GestionFournisseurPageState();
}

class _GestionFournisseurPageState extends State<GestionFournisseurPage> {
  TextEditingController raisonSocialeController = TextEditingController();
  TextEditingController codeTVAController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController gsm1Controller = TextEditingController();
  TextEditingController gsm2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController villeController = TextEditingController();

  List<Fournisseur> fournisseurs = [];

  @override
  void initState() {
    super.initState();
    fetchDataFournisseur();
  }

  Future<void> fetchDataFournisseur() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/fournisseurs';

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
          fournisseurs = parseFournisseur(response.data);
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
          'Failed to fetch fournisseur details. Please try again later.';
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

  List<Fournisseur> parseFournisseur(dynamic data) {
    // Assuming you have a method to parse JSON data into a list of Fournisseur objects
    // Replace with your actual implementation
    return (data as List).map((json) => Fournisseur.fromJson(json)).toList();
  }

  final storage = FlutterSecureStorage();


Future<void> addFournisseur(Map<String, dynamic> fournisseurData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  if (authToken == null || entrepriseId == null) {
    _showSnackBar('Authentication error. Please log in again.');
    return;
  }

  Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

  var url = 'http://localhost:8080/api/fournisseurs/addFournisseur';

  // Ensure no null values in the data map
  final sanitizedData = fournisseurData.map((key, value) => MapEntry(key, value ?? ''));

  try {
    var response = await dio.post(
      url,
      data: jsonEncode(sanitizedData), // Send JSON encoded data
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 200) {
      _showSnackBar('Fournisseur added successfully!');
      fetchDataFournisseur();
    } else if (response.statusCode == 500) {
      var jsonResponse = response.data;
      print('Server error: ${jsonResponse['message']}');
      _showSnackBar('Server error: ${jsonResponse['message']}');
    } else {
      print('Failed to add fournisseur: ${response.statusCode}');
      print('Response body: ${response.data}');
      _showSnackBar('Failed to add fournisseur. Please try again.');
    }
  } catch (e) {
    print('Error during HTTP request: $e');
    _showSnackBar('Network error. Please try again later.');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


Future<void> updateFournisseur(Fournisseur fournisseur) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  if (authToken == null || entrepriseId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authentication error. Please log in again.'),
      ),
    );
    return;
  }

  Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

  var url = 'http://localhost:8080/api/fournisseurs/updateFournisseur/${fournisseur.id}';

  try {
    var response = await dio.put(
      url,
      data: fournisseur.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode == 200) {
      fetchDataFournisseur();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fournisseur updated successfully.'),
        ),
      );
    } else {
      print('Failed to update fournisseur: ${response.statusCode}');
      print('Response body: ${response.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update fournisseur. Please try again.'),
        ),
      );
    }
  } catch (e) {
    print('Error updating fournisseur: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error. Please try again later.'),
      ),
    );
  }
}

  Future<void> deleteFournisseur(Fournisseur fournisseur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/fournisseurs/deleteFournisseur/${fournisseur.id}';

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
        fetchDataFournisseur();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fournisseur supprimé avec succès.'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting fournisseur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to delete fournisseur. Please try again later.'),
        ),
      );
    }
  }

  // Function to show edit supplier dialog
  void _showEditFournisseurDialog(
      BuildContext context, Fournisseur fournisseur) {
    // Initialize controllers with current supplier data
    raisonSocialeController.text = fournisseur.raisonSociale;
    codeTVAController.text = fournisseur.codeTVA;
    contactController.text = fournisseur.contact;
    gsm1Controller.text = fournisseur.gsm1;
    gsm2Controller.text = fournisseur.gsm2;
    emailController.text = fournisseur.email;
    adresseController.text = fournisseur.adresse;
    villeController.text = fournisseur.ville;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Fournisseur'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: raisonSocialeController,
                  label: 'Raison sociale',
                ),
                _buildTextField(
                  controller: codeTVAController,
                  label: 'Code TVA',
                ),
                _buildTextField(
                  controller: contactController,
                  label: 'Contact',
                ),
                _buildTextField(
                  controller: gsm1Controller,
                  label: 'Gsm1',
                ),
                _buildTextField(
                  controller: gsm2Controller,
                  label: 'Gsm2',
                ),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                ),
                _buildTextField(
                  controller: adresseController,
                  label: 'Adresse',
                ),
                _buildTextField(
                  controller: villeController,
                  label: 'Ville',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update supplier data
                  fournisseur.raisonSociale = raisonSocialeController.text;
                  fournisseur.codeTVA = codeTVAController.text;
                  fournisseur.contact = contactController.text;
                  fournisseur.gsm1 = gsm1Controller.text;
                  fournisseur.gsm2 = gsm2Controller.text;
                  fournisseur.email = emailController.text;
                  fournisseur.adresse = adresseController.text;
                  fournisseur.ville = villeController.text;

                  // Call update method
                  updateFournisseur(fournisseur);

                  Navigator.of(context).pop();
                });
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  

  // Function to build text field with label
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Gestion des Fournisseurs'),
      backgroundColor: Color.fromARGB(255, 205, 219, 231), // Couleur bleue pour l'AppBar
    ),
    body: RefreshIndicator(
      onRefresh: fetchDataFournisseur,
      child: ListView.builder(
        itemCount: fournisseurs.length,
        itemBuilder: (context, index) {
          final fournisseur = fournisseurs[index];
          return Card(
            color: Color.fromARGB(255, 170, 215, 239), // Couleur bleue pour la Card
            margin: EdgeInsets.all(8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raison sociale: ${fournisseur.raisonSociale}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 6, 40), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Code TVA: ${fournisseur.codeTVA}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 0, 0, 0), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Gsm1: ${fournisseur.gsm1}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 19, 0, 0), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Gsm2: ${fournisseur.gsm2}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 35, 0, 0), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Email: ${fournisseur.email}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 44, 0, 0), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Adresse: ${fournisseur.adresse}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 8, 2, 2), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Ville: ${fournisseur.ville}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: const Color.fromARGB(255, 0, 0, 0), // Texte en blanc pour le contraste
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showEditFournisseurDialog(context, fournisseur);
                        },
                        child: Text(
                          'Modifier',
                          style: TextStyle(
                            color: Color.fromARGB(255, 75, 124, 187), // Blanc pour un meilleur contraste sur le bleu
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Confirmation'),
                                content: Text(
                                    'Êtes-vous sûr de vouloir supprimer ce fournisseur ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      deleteFournisseur(fournisseur);
                                    },
                                    child: Text('Supprimer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 213, 230, 243), // Bleu pour le bouton flottant
      onPressed: () {
        _showAddFournisseurDialog(context);
      },
      child: Icon(Icons.add),
    ),
  );
}



  void _showAddFournisseurDialog(BuildContext context) {
    // Clear all text editing controllers
    raisonSocialeController.clear();
    codeTVAController.clear();
    
    gsm1Controller.clear();
    gsm2Controller.clear();
    emailController.clear();
    adresseController.clear();
    villeController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Fournisseur'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: raisonSocialeController,
                  label: 'Raison sociale',
                ),
                _buildTextField(
                  controller: codeTVAController,
                  label: 'Code TVA',
                ),
                
                _buildTextField(
                  controller: gsm1Controller,
                  label: 'Gsm1',
                ),
                _buildTextField(
                  controller: gsm2Controller,
                  label: 'Gsm2',
                ),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                ),
                _buildTextField(
                  controller: adresseController,
                  label: 'Adresse',
                ),
                _buildTextField(
                  controller: villeController,
                  label: 'Ville',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Create a map to represent the fournisseur data
                Map<String, dynamic> fournisseurData = {
                  'raisonSociale': raisonSocialeController.text.trim(),
                  'codeTVA': codeTVAController.text.trim(), 
                  
                  'gsm1': gsm1Controller.text.trim(),
                  'gsm2': gsm2Controller.text.trim(),
                  'email': emailController.text.trim(),
                  'adresse': adresseController.text.trim(),
                  'ville': villeController.text.trim(),
                };

                int entrepriseId = 1; // Replace with the actual entrepriseId

                // Call the addFournisseur function and await its completion
                await addFournisseur(fournisseurData);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
