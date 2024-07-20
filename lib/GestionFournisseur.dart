import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:chantier_test/interceptor.dart';

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
      raisonSociale: json['raisonSociale'],
      codeTVA: json['codeTVA'],
      contact: json['respo'],
      gsm1: json['gsm1'],
      gsm2: json['gsm2'],
      email: json['email'],
      adresse: json['adresse'],
      ville: json['ville'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raisonSociale': raisonSociale,
      'codeTVA': codeTVA,
      'respo': contact,
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

      setState(() {
        fournisseurs = parseFournisseur(response.data);
      });
    } catch (e) {
      print('Error fetching fournisseur details from backend: $e');
      String errorMessage =
          'Failed to fetch fournisseur details. Please try again later.';
      if (e is DioError) {
        if (e.response != null) {
          errorMessage =
              'HTTP error ${e.response!.statusCode}: ${e.response!.statusMessage}';
        } else {
          errorMessage = 'Request failed due to network issues.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  Future<void> addFournisseur(Fournisseur fournisseur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/fournisseurs';

    try {
      var response = await dio.post(
        url,
        data: fournisseur.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      if (response.statusCode == 201) {
        fetchDataFournisseur();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fournisseur ajouté avec succès.'),
          ),
        );
      }
    } catch (e) {
      print('Error adding fournisseur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add fournisseur. Please try again later.'),
        ),
      );
    }
  }

  Future<void> updateFournisseur(Fournisseur fournisseur) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/fournisseurs/${fournisseur.id}';

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
            content: Text('Fournisseur mis à jour avec succès.'),
          ),
        );
      }
    } catch (e) {
      print('Error updating fournisseur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update fournisseur. Please try again later.'),
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

    var url = 'http://192.168.1.7:8080/api/fournisseurs/${fournisseur.id}';

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
          content: Text('Failed to delete fournisseur. Please try again later.'),
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
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataFournisseur,
        child: ListView.builder(
          itemCount: fournisseurs.length,
          itemBuilder: (context, index) {
            final fournisseur = fournisseurs[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raison sociale: ${fournisseur.raisonSociale}',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text('Code TVA: ${fournisseur.codeTVA}'),
                    SizedBox(height: 4.0),
                    Text('Contact: ${fournisseur.contact}'),
                    SizedBox(height: 4.0),
                    Text('Gsm1: ${fournisseur.gsm1}'),
                    SizedBox(height: 4.0),
                    Text('Gsm2: ${fournisseur.gsm2}'),
                    SizedBox(height: 4.0),
                    Text('Email: ${fournisseur.email}'),
                    SizedBox(height: 4.0),
                    Text('Adresse: ${fournisseur.adresse}'),
                    SizedBox(height: 4.0),
                    Text('Ville: ${fournisseur.ville}'),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showEditFournisseurDialog(context, fournisseur);
                          },
                          child: Text('Modifier'),
                        ),
                        SizedBox(width: 8.0),
                        TextButton(
                          onPressed: () {
                            deleteFournisseur(fournisseur);
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
    contactController.clear();
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
                // Create a new fournisseur object
                Fournisseur newFournisseur = Fournisseur(
                  raisonSociale: raisonSocialeController.text,
                  codeTVA: codeTVAController.text,
                  contact: contactController.text,
                  gsm1: gsm1Controller.text,
                  gsm2: gsm2Controller.text,
                  email: emailController.text,
                  adresse: adresseController.text,
                  ville: villeController.text,
                );

                // Call add method
                addFournisseur(newFournisseur);

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
