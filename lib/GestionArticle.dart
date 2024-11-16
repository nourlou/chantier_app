import 'dart:convert';

import 'package:chantier_test/ManageChantiersPage.dart';
import 'package:chantier_test/interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniteDTO {
  int id;
  String libelle;

  UniteDTO({required this.id, required this.libelle});

  factory UniteDTO.fromJson(Map<String, dynamic> json) {
    return UniteDTO(
      id: json['id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }

  @override
  String toString() {
    return libelle;
  }

  static UniteDTO fromString(String libelle) {
    return UniteDTO(id: 0, libelle: libelle);
  }
}

class CategorieDTO {
  int id;
  String libelle;

  CategorieDTO({required this.id, required this.libelle});

  factory CategorieDTO.fromJson(Map<String, dynamic> json) {
    return CategorieDTO(
      id: json['id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }

  @override
  String toString() {
    return libelle;
  }

  static CategorieDTO fromString(String libelle) {
    return CategorieDTO(id: 0, libelle: libelle);
  }
}

// Classe représentant un article
class Article {
  CategorieDTO categorie;
  String refArt;
  String libArt;
  double prixA;
  int tva;
  double prixV;
  UniteDTO unite;
  int? id;

  Article({
    required this.categorie,
    required this.refArt,
    required this.libArt,
    required this.prixA,
    required this.tva,
    required this.prixV,
    required this.unite,
    this.id,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      refArt: json['refArt'],
      libArt: json['libArt'],
      prixA: json['prixA'],
      tva: json['tva'],
      prixV: json['prixV'],
      unite: UniteDTO.fromJson(json['unite']),
      categorie: CategorieDTO.fromJson(json['categorie']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refArt': refArt,
      'libArt': libArt,
      'prixA': prixA,
      'tva': tva,
      'prixV': prixV,
      'unite': unite,
      'categorie': categorie,
    };
  }
}

List parseIdArticle(List<dynamic> jsonList) {
  return jsonList.map((json) => json['id']).toList();
}

/*List<Article> parseArticle(List<dynamic> jsonList) {
  return jsonList
      .map((json) => Article(
            id: json['id'],
          //  categorie: json['categorie'],
            refArt: json['refArt'],
            libArt: json['libArt'],
            prixA: json['prixA'],
            tva: json['tva'],
            prixV: json['prixV'],
            unite: json['unite'],
          ))
      .toList();
}*/
List<Article> parseArticle(List<dynamic> jsonList) {
  return jsonList.map((json) => Article.fromJson(json)).toList();
}

class GestionarticlePage extends StatefulWidget {
  @override
  _GestionArticlesPageState createState() => _GestionArticlesPageState();
}

class _GestionArticlesPageState extends State<GestionarticlePage> {
  List<Article> articles = [];

  late TextEditingController _categorieController;
  late TextEditingController _referenceController;
  late TextEditingController _libelleController;
  late TextEditingController _puhtController;
  late TextEditingController _tvaController;
  late TextEditingController _puttcController;
  late TextEditingController _unitesController;

  @override
  void initState() {
    super.initState();
    _categorieController = TextEditingController();
    _referenceController = TextEditingController();
    _libelleController = TextEditingController();
    _puhtController = TextEditingController();
    _tvaController = TextEditingController();
    _puttcController = TextEditingController();
    _unitesController = TextEditingController();
    fetchDataFromBackend();
  }

  @override
  void dispose() {
    _categorieController.dispose();
    _referenceController.dispose();
    _libelleController.dispose();
    _puhtController.dispose();
    _tvaController.dispose();
    _puttcController.dispose();
    _unitesController.dispose();
    super.dispose();
  }

  Future<void> fetchDataFromBackend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/articles';

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
          articles = parseArticle(response.data);
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
      String errorMessage = 'Failed to fetch data. Please try again later.';
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

  List<Article> parseArticle(dynamic data) {
    return (data as List).map((json) => Article.fromJson(json)).toList();
  }

  Future<void> addArticle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/articles/addArticle';
    CategorieDTO categorie = CategorieDTO(id: 1, libelle: "Default");
    String refArt = _referenceController.text;
    String libArt = _libelleController.text;
    double prixA = double.tryParse(_puhtController.text) ?? 0.0;
    int tva = int.tryParse(_tvaController.text) ?? 0;
    double prixV = double.tryParse(_puttcController.text) ?? 0.0;
    UniteDTO unite = UniteDTO(id: 1, libelle: "Default");
    var body = jsonEncode({
      'categorie': categorie.toJson(),
      'refArt': refArt,
      'libArt': libArt,
      'prixA': prixA,
      'tva': tva,
      'prixV': prixV,
      'unite': unite.toJson(),
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
        articles.add(Article(
          categorie: categorie,
          refArt: refArt,
          libArt: libArt,
          prixA: prixA,
          tva: tva,
          prixV: prixV,
          unite: unite,
        ));
      });
      _showSnackBar('Article ajouté');
    } catch (e) {
      print('Error: $e');
      if (e is DioError) {
        print('DioError response: ${e.response}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add Article'),
        ),
      );
    }
  }

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}



Future<void> deleteArticle(Article article) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  if (authToken == null || entrepriseId == null) {
    print('Token or entrepriseId is null');
    return;
  }

  Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

  var url = 'http://localhost:8080/api/articles/deleteArticle/${article.id}';

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
        articles.remove(article);
      });
      _showSnackBar('Article supprimé');
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete Article'),
      ),
    );
  }
}


  bool _validateFields() {
    if (_categorieController.text.isEmpty ||
        _referenceController.text.isEmpty ||
        _libelleController.text.isEmpty ||
        _puhtController.text.isEmpty ||
        _tvaController.text.isEmpty ||
        _puttcController.text.isEmpty ||
        _unitesController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return false;
    }
    return true;
  }



Widget _buildArticleCard(Article article) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100, // Une nuance de bleu clair
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                article.libArt,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      int index = articles.indexOf(article);
                      _showEditArticleDialog(context, index);
                    },
                    icon: Icon(Icons.edit, color: Colors.blue.shade700), // Bleu plus foncé
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Supprimer l\'article'),
                                  SizedBox(height: 16),
                                  Text(
                                    'Êtes-vous sûr de vouloir supprimer cet article ?',
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Annuler'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await deleteArticle(article);
                                        },
                                        child: Text('Supprimer'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50, // Une autre nuance de bleu très clair
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text('Référence: ${article.refArt}',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('Prix HT: ${article.prixA} €',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('TVA: ${article.tva} %', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('Prix TTC: ${article.prixV} €',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('Unités: ${article.unite}',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showEditArticleDialog(BuildContext context, int index) {
  Article article = articles[index];

  final _formKey = GlobalKey<FormState>();

  TextEditingController categorieController = TextEditingController(
    text: article.categorie.libelle.trim());
  TextEditingController referenceController =
      TextEditingController(text: article.refArt);
  TextEditingController libelleController =
      TextEditingController(text: article.libArt);
  TextEditingController puhtController =
      TextEditingController(text: article.prixA.toString());
  TextEditingController tvaController =
      TextEditingController(text: article.tva.toString());
  TextEditingController puttcController =
      TextEditingController(text: article.prixV.toString());
  TextEditingController unitesController =
      TextEditingController(text: article.unite.toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Modifier l\'article'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer la catégorie' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: referenceController,
                  decoration: InputDecoration(labelText: 'Référence'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer la référence' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: libelleController,
                  decoration: InputDecoration(labelText: 'Libellé'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer le libellé' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: puhtController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Prix HT'),
                  validator: (value) => double.tryParse(value ?? '') == null ? 'Veuillez entrer un prix valide' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: tvaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'TVA (%)'),
                  validator: (value) => int.tryParse(value ?? '') == null ? 'Veuillez entrer un pourcentage valide' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: puttcController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Prix TTC'),
                  validator: (value) => double.tryParse(value ?? '') == null ? 'Veuillez entrer un prix valide' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: unitesController,
                  decoration: InputDecoration(labelText: 'Unités'),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer les unités' : null,
                ),
              ],
            ),
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
  if (_formKey.currentState?.validate() ?? false) {
    // Fetch existing IDs for Categorie and Unite (replace 1 and 2 with the correct logic)
    int categorieId = article.categorie.id; // Use the original category ID or fetch from a dropdown or other method
    int uniteId = article.unite.id; // Use the original unit ID or fetch from a dropdown or other method

    // Create a new Article object with updated values
    Article updatedArticle = Article(
      categorie: CategorieDTO(id: categorieId, libelle: categorieController.text),
      refArt: referenceController.text,
      libArt: libelleController.text,
      prixA: double.parse(puhtController.text),
      tva: int.parse(tvaController.text),
      prixV: double.parse(puttcController.text),
      unite: UniteDTO(id: uniteId, libelle: unitesController.text),
      id: article.id, // Keep the same ID for updating
    );

    // Call the updateArticle function
    updateArticle(updatedArticle);

    Navigator.of(context).pop();
  }
},

            child: Text('Modifier'),
          ),
        ],
      );
    },
  );
}


Future<void> updateArticle(Article article) async {
  print('Attempting to update article: ${article.toJson()}');
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? authToken = prefs.getString('token');
  int? entrepriseId = prefs.getInt('entrepriseId');

  Dio dio = Dio();
  dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

  var url = 'http://localhost:8080/api/articles/updateArticle/${article.id}';
  print('Request URL: $url');

  var body = jsonEncode(article.toJson());
  print('Request Body: $body');

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

    print('Response Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');

    if (response.statusCode == 200) {
      _showSnackBar('Article modifié avec succès');
    } else {
      _showSnackBar('Échec de la modification de l\'article');
    }
  } catch (e) {
    if (e is DioError) {
      print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('Error: $e');
    }
    _showSnackBar('Échec de la modification de l\'article');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Articles'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ArticleSearchDelegate(articles),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return _buildArticleCard(articles[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddArticleDialog(context);
        },
      ),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    // Clear the controllers
    _categorieController.clear();
    _referenceController.clear();
    _libelleController.clear();
    _puhtController.clear();
    _tvaController.clear();
    _puttcController.clear();
    _unitesController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Ajouter un Article'),
                SizedBox(height: 16),
                TextFormField(
                  controller: _categorieController,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: 'Référence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list_alt),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _libelleController,
                  decoration: InputDecoration(
                    labelText: 'Libellé',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _puhtController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prix HT',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _tvaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'TVA (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _puttcController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prix TTC',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money_off),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _unitesController,
                  decoration: InputDecoration(
                    labelText: 'Unités',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_validateFields()) {
                          // Call addArticle and pass the necessary data
                          await addArticle();
                          Navigator.of(context).pop();
                          _showSnackBar('Article ajouté');
                        }
                      },
                      child: Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Classe pour la recherche d'articles
class ArticleSearchDelegate extends SearchDelegate<Article> {
  final List<Article> articles;

  ArticleSearchDelegate(this.articles);

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
    final results = articles
        .where((article) =>
            article.libArt.toLowerCase().contains(query.toLowerCase()) ||
            //  article.categorie.toLowerCase().contains(query.toLowerCase()) ||
            article.refArt.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final article = results[index];
        return ListTile(
          title: Text(article.libArt),
          /*  subtitle: Text(
              'Référence: ${article.refArt}, Catégorie: ${article.categorie}'),*/
          onTap: () {
            close(context, article);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = articles
        .where((article) =>
            article.libArt.toLowerCase().contains(query.toLowerCase()) ||
            //  article.categorie.toLowerCase().contains(query.toLowerCase()) ||
            article.refArt.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final article = suggestions[index];
        return ListTile(
          title: Text(article.libArt),
          /*  subtitle: Text(
              'Référence: ${article.refArt}, Catégorie: ${article.categorie}'),*/
          onTap: () {
            query = article.libArt;
            showResults(context);
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GestionarticlePage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
