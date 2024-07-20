import 'package:chantier_test/ManageChantiersPage.dart';
import 'package:chantier_test/interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GestionProjetPage extends StatefulWidget {
  static const List<Color> chantierGradient = [
    Color.fromARGB(255, 12, 43, 69),
    Color(0xFF64B5F6)
  ];
  static const List<Color> articleGradient = [
    Color.fromARGB(255, 42, 105, 116),
    Color(0xFF42A5F5)
  ];
  static const List<Color> fournisseurGradient = [
    Color.fromARGB(255, 75, 119, 162),
    Color(0xFF2196F3)
  ];
  static const List<Color> clientGradient = [
    Color.fromARGB(255, 23, 81, 86),
    Color(0xFF1E88E5)
  ];

  @override
  _GestionProjetPageState createState() => _GestionProjetPageState();
}

class _GestionProjetPageState extends State<GestionProjetPage> {
  final List<DashboardTile> _allTiles = [
    DashboardTile(
      icon: Icons.add_business,
      title: 'Gestion chantier',
      //  subtitle: 'Ajouter un nouveau chantier',
      routeName: '/projects',
      gradientColors: GestionProjetPage.chantierGradient,
    ),
    DashboardTile(
      icon: Icons.add_circle,
      title: 'Gestion article',
      //  subtitle: 'Ajouter un nouvel article',
      routeName: '/ajouter_article',
      gradientColors: GestionProjetPage.articleGradient,
    ),
    DashboardTile(
      icon: Icons.local_shipping,
      title: 'Gestion Fournisseur',
      //  subtitle: 'Gestion des fournisseurs',
      routeName: '/fournisseur',
      gradientColors: GestionProjetPage.fournisseurGradient,
    ),
    DashboardTile(
      icon: Icons.person,
      title: 'Gestion Client',
      //  subtitle: 'Gestion des clients',
      routeName: '/client',
      gradientColors: GestionProjetPage.clientGradient,
    ),
  ];

  List<DashboardTile> _filteredTiles = [];
  String _searchText = '';

  @override
  void initState() {
    _filteredTiles = _allTiles;
    super.initState();
  }

  void _filterTiles(String query) {
    List<DashboardTile> filteredList = _allTiles.where((tile) {
      return tile.title.toLowerCase().contains(query.toLowerCase());
      //  tile.subtitle.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredTiles = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Gestion des Projets', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 60, 64, 104),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenue sur la gestion des projets',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 60, 64, 104),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                    _filterTiles(value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    labelText: 'Recherche',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTiles.isEmpty
                ? Center(
                    child: Text(
                      'Aucun résultat trouvé',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTiles.length,
                    itemBuilder: (context, index) {
                      return _buildDashboardTile(
                          context, _filteredTiles[index]);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Divider(),
                Text(
                  'Statistiques',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Chantiers', '10',
                        GestionProjetPage.chantierGradient.first),
                    _buildStatCard('Articles', '50',
                        GestionProjetPage.articleGradient.first),
                    _buildStatCard('Fournisseurs', '8',
                        GestionProjetPage.fournisseurGradient.first),
                    _buildStatCard('Clients', '25',
                        GestionProjetPage.clientGradient.first),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, DashboardTile tile) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, tile.routeName);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tile.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tile.icon, size: 36.0, color: Colors.white),
            SizedBox(height: 8),
            Text(
              tile.title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            /*  Text(
              tile.subtitle,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class DashboardTile {
  final IconData icon;
  final String title;
//  final String subtitle;
  final String routeName;
  final List<Color> gradientColors;

  DashboardTile({
    required this.icon,
    required this.title,
    //  required this.subtitle,
    required this.routeName,
    required this.gradientColors,
  });
}
