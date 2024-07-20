import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchatPage extends StatefulWidget {
  @override
  _AchatPageState createState() => _AchatPageState();
}

class _AchatPageState extends State<AchatPage> {
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _numPceController = TextEditingController();
  final TextEditingController _uniteController = TextEditingController();
  final TextEditingController _prixAController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController();
  final TextEditingController _prixVController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final List<Map<String, dynamic>> _articlesList = [];

  final TextEditingController _raisonSocialeController =
      TextEditingController();
  final TextEditingController _codeTVAController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _gsm1Controller = TextEditingController();
  final TextEditingController _gsm2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final List<Map<String, dynamic>> _fournisseurList = [];

  final TextEditingController _refController = TextEditingController();
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _dateDebController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _mtDeviController = TextEditingController();
  final TextEditingController _observController = TextEditingController();
  final List<Map<String, dynamic>> _chantierList = [];

  String? _selectedFournisseur;
  String? _selectedChantier;
  String? _selectedArticle;
  String _gsm = '';

  final List<String> _fournisseurs = ['Fournisseur 1', 'Fournisseur 2'];
  final List<String> _chantiers = ['Chantier 1', 'Chantier 2'];
  final List<Map<String, String>> _articles = [
    {'id': '1', 'name': 'Article 1'},
    {'id': '2', 'name': 'Article 2'}
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _dateController.dispose();
    _numPceController.dispose();
    _uniteController.dispose();
    _prixAController.dispose();
    _tvaController.dispose();
    _prixVController.dispose();
    _quantiteController.dispose();
    _raisonSocialeController.dispose();
    _codeTVAController.dispose();
    _contactController.dispose();
    _gsm1Controller.dispose();
    _gsm2Controller.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _refController.dispose();
    _libelleController.dispose();
    _dateDebController.dispose();
    _dateFinController.dispose();
    _dateFinController.dispose();
    _mtDeviController.dispose();
    _observController.dispose();

    super.dispose();
  }

  Future<void> fetchChanierFromBackend(String ChantierId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    if (entrepriseId == null) {
      print('entrepriseId is null. Unable to make request.');
      return;
    }

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/chantiers/$ChantierId';

    // Specify query parameters to fetch only dateDeb and datefin
    var queryParameters = {
      'fields': 'dateDeb,datefin',
    };

    try {
      var response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      print(response.data);
      _updateChantierDetails(response.data);
    } catch (e) {
      print('Error fetching chantier details from backend: $e');
      String errorMessage =
          'Failed to fetch chantier details. Please try again later.';

      if (e is DioError) {
        if (e.response != null) {
          errorMessage =
              'HTTP error ${e.response!.statusCode}: ${e.response!.statusMessage}';
          print('Response data: ${e.response!.data}');
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

  Future<void> fetchDataFromBackend(String articleId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/articles/$articleId';

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
      _updateArticleDetails(response.data);
    } catch (e) {
      print('Error fetching article details from backend: $e');
      String errorMessage =
          'Failed to fetch article details. Please try again later.';
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

  Future<void> fetchDataFournisseur(String fournisseurId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://localhost:8080/api/fournisseurs/$fournisseurId';

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
      _updateFournisseurDetails(response.data);
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

   void _updateChantierDetails(Map<String, dynamic> chantier) {
    setState(() {
      _refController.text = chantier['ref'] ?? '';
      _libelleController.text = chantier['libelle'] ?? '';
      _dateDebController.text = chantier['dateDeb'] ?? '';
      _dateFinController.text = chantier['dateFin'] ?? '';
      _mtDeviController.text = chantier['mtDevi'] ?? '';
      _observController.text = chantier['observ'] ?? '';
    });
  }


  void _updateArticleDetails(Map<String, dynamic> article) {
    setState(() {
      _uniteController.text = article['unite']?['libelle'] ?? '';
      _prixAController.text = (article['prixA'] ?? 0).toString();
      _tvaController.text = (article['tva'] ?? 0).toString();
      _prixVController.text = (article['prixV'] ?? 0).toString();
      _quantiteController.text = '1';
    });
  }

  void _updateFournisseurDetails(dynamic fournisseurResponse) {
    if (fournisseurResponse is List) {
      if (fournisseurResponse.isNotEmpty) {
        var firstFournisseur = fournisseurResponse[0];
        setState(() {
          _raisonSocialeController.text =
              firstFournisseur['raisonSociale'] ?? '';
          _codeTVAController.text = firstFournisseur['codeTVA'] ?? '';
          _contactController.text = firstFournisseur['contact'] ?? '';
          _gsm1Controller.text = firstFournisseur['gsm1'] ?? '';
          _gsm2Controller.text = firstFournisseur['gsm2'] ?? '';
          _emailController.text = firstFournisseur['email'] ?? '';
          _adresseController.text = firstFournisseur['adresse'] ?? '';
          _villeController.text = firstFournisseur['ville'] ?? '';
        });
      } else {
        print('Empty list received for fournisseur details');
      }
    } else {
      print('Unexpected response format for fournisseur details');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Entrez votre $label',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDateTime = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.dark(),
                child: child!,
              );
            },
          );

          if (pickedDateTime != null) {
            controller.text =
                '${pickedDateTime.day}-${pickedDateTime.month}-${pickedDateTime.year}';
          }
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Sélectionnez une date pour $label',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        onChanged: (value) {
          onChanged(value);

          if (label == 'Article' && value != null) {
            var selectedArticle = _articles.firstWhere(
              (article) => article['name'] == value,
              orElse: () => {'id': '', 'name': ''},
            );
            fetchDataFromBackend(selectedArticle['id']!);
          } else if (label == 'Fournisseur' && value != null) {
            var fournisseurId = _fournisseurList.firstWhere(
              (fournisseur) => fournisseur['raisonSociale'] == value,
              orElse: () => {'id': '', 'raisonSociale': ''},
            )['id'];
            if (fournisseurId != null) {
              fetchDataFournisseur(fournisseurId);
            }
          } else if (label == 'Chantier' && value != null) {
            var chantierId = _chantierList.firstWhere(
              (chantier) => chantier['name'] == value,
              orElse: () => {'id': '', 'name': ''},
            )['id'];
            if (chantierId != null) {
              fetchChanierFromBackend(chantierId);
            }
          }
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  void _ajouterArticle() {
    setState(() {
      _articlesList.add({
        'article': _selectedArticle,
        'unite': _uniteController.text,
        'prixV': double.tryParse(_prixVController.text) ?? 0,
        'quantite': int.tryParse(_quantiteController.text) ?? 1,
        'totalTTC': (double.tryParse(_prixVController.text) ?? 0) *
            (int.tryParse(_quantiteController.text) ?? 1),
      });
    });
  }

  void _saveAchat() {
    print('Achat saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achat'),
        backgroundColor: Color.fromARGB(255, 38, 76, 110),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_numeroController, 'Numéro'),
              _buildDateField(_dateController, 'Date'),
              _buildDropdown(
                'Fournisseur',
                _fournisseurs,
                _selectedFournisseur,
                (value) {
                  setState(() {
                    _selectedFournisseur = value;
                  });
                },
              ),
              _buildTextField(_numPceController, 'Num Pce Originale'),
              _buildDropdown(
                'Chantier',
                _chantiers,
                _selectedChantier,
                (value) {
                  setState(() {
                    _selectedChantier = value;
                  });
                },
              ),
              _buildDropdown(
                'Article',
                _articles.map((article) => article['name']!).toList(),
                _selectedArticle,
                (value) {
                  setState(() {
                    _selectedArticle = value;
                  });
                },
              ),
              _buildTextField(_uniteController, 'Unité'),
              _buildTextField(_prixAController, 'PrixA',
                  inputType: TextInputType.number),
              _buildTextField(_tvaController, 'TVA',
                  inputType: TextInputType.number),
              _buildTextField(_prixVController, 'PrixV',
                  inputType: TextInputType.number),
              _buildTextField(_quantiteController, 'Quantité',
                  inputType: TextInputType.number),
              Center(
                child: ElevatedButton(
                  onPressed: _ajouterArticle,
                  child: Text('Ajouter Article'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 38, 76, 110),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              _buildTextField(_raisonSocialeController, 'Raison Sociale'),
              _buildTextField(_codeTVAController, 'Code TVA'),
              _buildTextField(_contactController, 'Contact'),
              _buildTextField(_gsm1Controller, 'GSM1'),
              _buildTextField(_gsm2Controller, 'GSM2'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_adresseController, 'Adresse'),
              _buildTextField(_villeController, 'Ville'),
              Center(
                child: ElevatedButton(
                  onPressed: _saveAchat,
                  child: Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 38, 76, 110),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              DataTable(
                columns: [
                  DataColumn(label: Text('Article')),
                  //  DataColumn(label: Text('Unité')),
                  DataColumn(label: Text('PrixV')),
                  DataColumn(label: Text('Quantité')),
                  DataColumn(label: Text('TotalTTC')),
                ],
                rows: _articlesList.map((article) {
                  return DataRow(cells: [
                    DataCell(Text(article['article'] ?? '')),
                    //    DataCell(Text(article['unite'] ?? '')),
                    DataCell(Text(article['prixV'].toString())),
                    DataCell(Text(article['quantite'].toString())),
                    DataCell(Text(article['totalTTC'].toString())),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthInterceptor extends Interceptor {
  final int? entrepriseId;
  final String? authToken;

  AuthInterceptor(this.entrepriseId, this.authToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (entrepriseId != null) {
      options.headers['entreprise'] = entrepriseId.toString();
    }
    if (authToken != null) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }
    super.onRequest(options, handler);
  }
}

