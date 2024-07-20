import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepencePage extends StatefulWidget {
  @override
  _DepencePageState createState() => _DepencePageState();
}

class _DepencePageState extends State<DepencePage> {
  DateTime? _startDate;
  DateTime? _endDate;

  final _articleController = TextEditingController();
  final _chantierController = TextEditingController();
  final _categorieController = TextEditingController();
  final _totligController = TextEditingController();
  final _dateController = TextEditingController();

  List<Map<String, dynamic>> _depences = [];
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    fetchlignesAchat();
    fetchPayments();
  }

  Future<void> fetchlignesAchat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://192.168.1.7:8080/api/lignesAchat';

    try {
      var response = await dio.get(
        url,
        queryParameters: {
          'entrepriseId': entrepriseId,
          'article': _articleController.text,
          'chantier': _chantierController.text,
          'categorie': _categorieController.text,
          'totlig': _totligController.text,
          'dateAchat': _dateController.text,
        }, // Include filters as query parameters
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('fetch lignes Data from API: ${response.data}');

        List<Map<String, dynamic>> depences =
            response.data.map<Map<String, dynamic>>((depence) {
          return {
            'article': depence['article']?['libArt'] ?? '',
            'chantier': depence['chantierAchat']?['ref'] ?? '',
            'categorie': depence['article']?['categorie']?['libelle'] ?? '',
            'totlig': depence['totlig'] ?? 0.0,
            'dateAchat': depence['dateAchat'],
          };
        }).toList();

        print(depences);
        setState(() {
          _depences = depences;
        });
      } else {
        print('Error fetching data from backend: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch data. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      if (e is DioError) {
        print('Dio error: ${e.response?.statusCode}');
        print('Dio error data: ${e.response?.data}');
      } else {
        print('Unexpected error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
        ),
      );
    }
  }

  Future<void> fetchPayments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? entrepriseId = prefs.getInt('entrepriseId');

    Dio dio = Dio();
    dio.interceptors.add(AuthInterceptor(entrepriseId, authToken));

    var url = 'http://192.168.1.7:8080/api/payements';

    try {
      var response = await dio.get(
        url,
        queryParameters: {
          'entrepriseId': entrepriseId,
          'includeEmployee':
              true, // Ajoutez ce paramètre pour inclure les détails de l'employé
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('fetch payment Data from API: ${response.data}');

        List<Map<String, dynamic>> payments =
            List<Map<String, dynamic>>.from(response.data).map((payment) {
          return {
            'id': payment['id'],
            'montant': payment['montant'],
            'datePay': payment['datePay'],
            'chantier': payment['chantier']['libelle'],
            'prenom': payment['employe']['prenom'],
            'nom': payment['employe']['nom'],
          };
        }).toList();

        print(payments);
        setState(() {
          _payments = payments;
        });
      } else {
        print('Error fetching data from backend: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch data. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      if (e is DioError) {
        print('Dio error: ${e.response?.statusCode}');
        print('Dio error data: ${e.response?.data}');
      } else {
        print('Unexpected error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dépenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter section
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  color: const Color.fromARGB(255, 175, 201, 221)!,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Article field with icon
                    TextFormField(
                      controller: _articleController,
                      decoration: InputDecoration(
                        labelText: 'Article',
                        prefixIcon: Icon(Icons.article,
                            color: const Color.fromARGB(255, 158, 191, 218)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Chantier field with icon
                    TextFormField(
                      controller: _chantierController,
                      decoration: InputDecoration(
                        labelText: 'Chantier',
                        prefixIcon: Icon(Icons.build,
                            color: const Color.fromARGB(255, 158, 191, 218)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Catégorie field with icon
                    TextFormField(
                      controller: _categorieController,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category,
                            color: const Color.fromARGB(255, 158, 191, 218)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Date field with icon
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.date_range,
                            color: const Color.fromARGB(255, 158, 191, 218)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Totale field with icon
                    TextFormField(
                      controller: _totligController,
                      decoration: InputDecoration(
                        labelText: 'Totale',
                        prefixIcon: Icon(Icons.attach_money,
                            color: const Color.fromARGB(255, 158, 191, 218)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0),

            // List of lignesAchat (_depences)
            Expanded(
              child: ListView.builder(
                shrinkWrap:
                    true, // Réduit la hauteur de la ListView à la taille de son contenu
                itemCount: (_depences.length / 2)
                    .ceil(), // Nombre de lignes nécessaires
                itemBuilder: (context, index) {
                  int firstIndex = index * 2; // Premier index de la paire
                  int secondIndex =
                      firstIndex + 1; // Deuxième index de la paire

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (firstIndex < _depences.length)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: buildDepenceCard(
                                  firstIndex), // Construire la première carte de la paire
                            ),
                          ),
                        if (secondIndex < _depences.length)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: buildDepenceCard(
                                  secondIndex), // Construire la deuxième carte de la paire
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.0),

            // List of payments (_payments)
            Expanded(
              child: ListView.builder(
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 158, 191, 218)!,
                            width: 1.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Action à exécuter lorsque la carte est tapée
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '${_payments[index]['prenom'] ?? ''} ${_payments[index]['nom'] ?? ''}',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 8, 4, 115),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.work,
                                      color: const Color.fromARGB(
                                          255, 158, 191, 218),
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chantier: ${_payments[index]['chantier'] ?? ''}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.category,
                                      color: const Color.fromARGB(
                                          255, 158, 191, 218),
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Catégorie: Paiement',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: const Color.fromARGB(
                                          255, 158, 191, 218),
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Date: ${_payments[index]['datePay'] ?? ''}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.attach_money,
                                      color: const Color.fromARGB(
                                          255, 158, 191, 218),
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Montant: ${_payments[index]['montant'] ?? ''}',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget buildDepenceCard(int index) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: const Color.fromARGB(255, 158, 191, 218)!, width: 1.0),
    ),
    child: InkWell(
      onTap: () {
      
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Article
            Text(
              _depences[index]['article'] ?? '',
              style: TextStyle(
                color: Color.fromARGB(255, 8, 4, 115),
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            // Chantier
            Row(
              children: [
                Icon(Icons.work, color: const Color.fromARGB(255, 158, 191, 218), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chantier: ${_depences[index]['chantier'] ?? ''}',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Catégorie
            Row(
              children: [
                Icon(Icons.category, color: const Color.fromARGB(255, 158, 191, 218), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Catégorie: ${_depences[index]['categorie'] ?? ''}',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, color: const Color.fromARGB(255, 158, 191, 218), size: 20),
                SizedBox(width: 8),
                Text(
                  'Date: ${_depences[index]['dateAchat'] ?? ''}',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Totale
            Row(
              children: [
                Icon(Icons.attach_money, color: const Color.fromARGB(255, 158, 191, 218), size: 20),
                SizedBox(width: 8),
                Text(
                  'Totale: ${_depences[index]['totlig']?.toString() ?? ''}',
                  style: TextStyle(color: Colors.black, fontSize: 12),
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

class AuthInterceptor extends Interceptor {
  final int? entrepriseId;
  final String? authToken;

  AuthInterceptor(this.entrepriseId, this.authToken);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Authorization'] = 'Bearer $authToken';
    options.headers['Entreprise-ID'] = entrepriseId.toString();
    return super.onRequest(options, handler);
  }
}
