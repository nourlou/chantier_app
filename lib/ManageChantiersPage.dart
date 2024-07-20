import 'dart:convert';

import 'package:chantier_test/interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe représentant un chantier
class Project {
  String ref;
  String libelle;
  DateTime dateDeb;
  DateTime datefin;
  String mtDevi;
  String observ;
  int? id;

  Project({
    required this.ref,
    required this.libelle,
    required this.dateDeb,
    required this.datefin,
    required this.mtDevi,
    required this.observ,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref': ref,
      'libelle': libelle,
      'dateDeb': dateDeb.toIso8601String(),
      'datefin': datefin.toIso8601String(),
      'mtDevi': mtDevi,
      'observ': observ,
    };
  }
}

List parseIdChantier(List<dynamic> jsonList) {
  return jsonList.map((json) => json['id']).toList();
}

List<Project> parseProjects(List<dynamic> jsonList) {
  return jsonList
      .map((json) => Project(
            id: json['id'],
            ref: json['ref'],
            libelle: json['libelle'],
            dateDeb: DateTime.parse(json["dateDeb"]),
            datefin: DateTime.parse(json['datefin']),
            mtDevi: json['mtDevi'].toString(),
            observ: json['observ'],
          ))
      .toList();
}


class ManageProjectsPage extends StatefulWidget {
  @override
  _ManageProjectsPageState createState() => _ManageProjectsPageState();
}

class _ManageProjectsPageState extends State<ManageProjectsPage> {
  List<Project> projects = [];
  //int index_chantier = 0;
//  List id_chantier = [];

  late TextEditingController _referenceController;
  late TextEditingController _libelleController;
  DateTime? _datedebut;
  DateTime? _datefin;
  late TextEditingController _montantController;
  late TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController();
    _libelleController = TextEditingController();
    _montantController = TextEditingController();
    _observationController = TextEditingController();
    fetchDataFromBackend(); 
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _libelleController.dispose();
    _montantController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> fetchDataFromBackend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://192.168.1.7:8080/api/chantiers';

    try {
      var response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      print(response.data);
      setState(() {
        projects = parseProjects(response.data);
      });
    } catch (e) {
      print('Error fetch data from backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
        ),
      );
    }
  }

  Future<void> addChantier() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://192.168.1.7:8080/api/chantiers/addChantier';

    String ref = _referenceController.text;
    String libelle = _libelleController.text;
    String dateDeb = DateFormat('yyyy-MM-dd').format(_datedebut!);
    String dateFin = DateFormat('yyyy-MM-dd').format(_datefin!);
    String mtDevi = _montantController.text;
    String observ = _observationController.text;
    var body = jsonEncode({
      'ref': ref,
      'libelle': libelle,
      'dateDeb': dateDeb,
      'datefin': dateFin,
      'mtDevi': mtDevi,
      'observ': observ,
    });

    try {
      var response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      setState(() {
        fetchDataFromBackend();
        projects.add(Project(
          ref: ref,
          libelle: libelle,
          dateDeb: _datedebut!,
          datefin: _datefin!,
          mtDevi: mtDevi,
          observ: observ,
        ));
      });
      _showSnackBar('Chantier ajouté');
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add Chantier'),
        ),
      );
    }
  }

  Future<void> editChantier(Project project) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));
    print(project.id);
    var url =
        'http://192.168.1.7:8080/api/chantiers/updateChantier/${project.id}';
    print(url);
    project.ref = _referenceController.text;
    project.libelle = _libelleController.text;

    project.mtDevi = _montantController.text;
    project.observ = _observationController.text;
    project.dateDeb = _datedebut != null
        ? DateFormat('yyyy-MM-dd').parse(_datedebut!.toString())
        : project.dateDeb;
    project.datefin = _datefin != null
        ? DateFormat('yyyy-MM-dd').parse(_datefin!.toString())
        : project.datefin;
    print('Updated project: $project');
    var body = project.toJson();
    print(body);

    try {
      var response = await dio.put(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      _showSnackBar('Chantier modifié avec succès');
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la modification du chantier'),
        ),
      );
    }
  }

  Future<void> _deleteChantier(Project project) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    if (authToken == null || entrepriseId == null) {
      print('Token or entrepriseId is null');
      return;
    }

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    print(project.id);
    var url =
        'http://192.168.1.7:8080/api/chantiers/deleteChantier/${project.id}';

    try {
      print('Sending DELETE request to: $url');
      var response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      print('Response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        setState(() {
          projects.remove(project);
        });
        _showSnackBar('Chantier supprimé');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete Chantier'),
        ),
      );
    }
  }

  bool _validateFields() {
    if (_referenceController.text.isEmpty) {
      _showSnackBar('Veuillez entrer la référence du projet');
      return false;
    }
    if (_observationController.text.isEmpty) {
      _showSnackBar('Veuillez entrer l\'observation du projet');
      return false;
    }
    if (_libelleController.text.isEmpty) {
      _showSnackBar('Veuillez entrer un libellé de projet');
      return false;
    }
    if (_montantController.text.isEmpty) {
      _showSnackBar('Veuillez entrer un montant de projet');
      return false;
    }
    if (_datedebut == null) {
      _showSnackBar('Veuillez sélectionner une date de début');
      return false;
    }
    if (_datefin == null) {
      _showSnackBar('Veuillez sélectionner une date de fin');
      return false;
    }
    if (_datefin!.isBefore(_datedebut!)) {
      _showSnackBar('La date de fin ne peut pas être avant la date de début');
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

  Widget _buildProjectCard(Project project) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final startDateFormatted = dateFormatter.format(project.dateDeb);
    final endDateFormatted = dateFormatter.format(project.datefin);

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
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.ref,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showEditProjectDialog(context, project);
                        },
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Supprimer le projet'),
                                content: Text(
                                  'Êtes-vous sûr de vouloir supprimer ce projet ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteChantier(project);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.libelle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Date de début: $startDateFormatted'),
                  SizedBox(height: 4),
                  Text('Date de fin: $endDateFormatted'),
                  SizedBox(height: 4),
                  Text('Montant: ${project.mtDevi}'),
                  SizedBox(height: 4),
                  Text('Observation: ${project.observ}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProjectDialog(
      BuildContext context, Project project) async {
    _referenceController.text = project.ref;
    _libelleController.text = project.libelle;
    _datedebut = project.dateDeb;
    _datefin = project.datefin;
    _montantController.text = project.mtDevi;
    _observationController.text = project.observ;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le projet'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(labelText: 'Référence'),
                ),
                TextField(
                  controller: _libelleController,
                  decoration: InputDecoration(labelText: 'Libellé'),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _datedebut == null
                            ? 'Sélectionner la date de début'
                            : 'Date de début: ${DateFormat('dd/MM/yyyy').format(_datedebut!)}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _datedebut ?? DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365 * 10)),
                          lastDate:
                              DateTime.now().add(Duration(days: 365 * 10)),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _datedebut = selectedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _datefin == null
                            ? 'Sélectionner la date de fin'
                            : 'Date de fin: ${DateFormat('dd/MM/yyyy').format(_datefin!)}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _datefin ?? DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365 * 10)),
                          lastDate:
                              DateTime.now().add(Duration(days: 365 * 10)),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _datefin = selectedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _montantController,
                  decoration: InputDecoration(labelText: 'Montant'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _observationController,
                  decoration: InputDecoration(labelText: 'Observation'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                if (_validateFields()) {
                  editChantier(project);
                  Navigator.of(context).pop();
                }
              },
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
        title: Text('Gestion des Chantiers'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataFromBackend,
        child: ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            //  index_chantier = index;
            return _buildProjectCard(projects[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Ajouter un chantier'),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _referenceController,
                        decoration: InputDecoration(labelText: 'Référence'),
                      ),
                      TextField(
                        controller: _libelleController,
                        decoration: InputDecoration(labelText: 'Libellé'),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _datedebut == null
                                  ? 'Sélectionner la date de début'
                                  : 'Date de début: ${DateFormat('dd/MM/yyyy').format(_datedebut!)}',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: _datedebut ?? DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365 * 10)),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 365 * 10)),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  _datedebut = selectedDate;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _datefin == null
                                  ? 'Sélectionner la date de fin'
                                  : 'Date de fin: ${DateFormat('dd/MM/yyyy').format(_datefin!)}',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: _datefin ?? DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365 * 10)),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 365 * 10)),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  _datefin = selectedDate;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _montantController,
                        decoration: InputDecoration(labelText: 'Montant'),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _observationController,
                        decoration: InputDecoration(labelText: 'Observation'),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Ajouter'),
                    onPressed: () {
                      if (_validateFields()) {
                        addChantier();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Ajouter un chantier',
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    color: Colors.blue,
    home: ManageProjectsPage(),
  ));
}
