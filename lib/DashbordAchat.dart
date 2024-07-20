import 'package:flutter/material.dart';

class DashbordProjetPage extends StatefulWidget {
  @override
  _DashbordProjetPageState createState() => _DashbordProjetPageState();
}

class _DashbordProjetPageState extends State<DashbordProjetPage> {
  final List<DashboardTile> _allTiles = [
    DashboardTile(
      icon: Icons.shopping_cart,
      title: 'Achats',
      routeName: '/ajoutAchats',
    ),
    DashboardTile(
      icon: Icons.money_off,
      title: 'Dépenses',
      routeName: '/depences',
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
    }).toList();

    setState(() {
      _filteredTiles = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMA-', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 13, 51, 86),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 51, 86), // Background color
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
        child: Row(
          children: [
            Icon(tile.icon, size: 36.0, color: Colors.white),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                tile.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 13, 37, 56),
          ),
        ),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class DashboardTile {
  final IconData icon;
  final String title;
  final String routeName;

  DashboardTile({
    required this.icon,
    required this.title,
    required this.routeName,
  });
}
