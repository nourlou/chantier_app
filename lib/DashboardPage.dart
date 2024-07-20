import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const DashboardPage({Key? key, required this.userName, required this.userEmail}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _dashboardItems = [
    {
      'icon': Icons.business,
      'title': 'Manage Projects',
      'subtitle': 'Add, view, and update construction projects',
      'routeName': '/gestion',
      'color': Color.fromARGB(255, 18, 57, 135),
    },
    {
      'icon': Icons.people,
      'title': 'Manage Users',
      'subtitle': 'Add, view, and update user information',
      'routeName': '/manage_users',
      'color': Color.fromARGB(255, 138, 166, 231),
    },
    {
  'icon': Icons.shopping_cart,
  'title': 'ACHATS',
  'subtitle': 'Manage budget, expenses, and financial reports',
  'routeName': '/achats',
  'color': Color.fromARGB(255, 175, 212, 212),
   },
    {
      'icon': Icons.attach_money,
      'title': 'Finance Management',
      'subtitle': 'Manage budget, expenses, and financial reports',
      'routeName': '/finance_management',
      'color': Color.fromARGB(255, 14, 98, 98),
    },
    

  ];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _dashboardItems;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _dashboardItems.where((item) {
        return item['title'].toLowerCase().contains(query) ||
            item['subtitle'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userName}'), // Titre dynamique avec le nom d'utilisateur
        backgroundColor: Color.fromARGB(255, 188, 190, 215), // Couleur d'arrière-plan de l'AppBar
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            activeIcon: Icon(Icons.home, color: Colors.blueAccent),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, color: Colors.grey),
            activeIcon: Icon(Icons.business, color: Colors.blueAccent),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.grey),
            activeIcon: Icon(Icons.account_circle, color: Colors.blueAccent),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/projects');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              _buildStatisticsCards(),
              SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 60, 64, 104)),
                  labelText: 'How can we help you?',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 60, 64, 104)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(255, 60, 64, 104)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 400,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: _filteredItems.map((item) {
                    return _buildDashboardCard(
                      context,
                      icon: item['icon'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      routeName: item['routeName'],
                      color: item['color'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatisticsCard('Projects', '24', Icons.business, Color.fromARGB(255, 114, 152, 227)),
        _buildStatisticsCard('Users', '58', Icons.people, Color.fromARGB(255, 171, 190, 234)),
        _buildStatisticsCard('Finance', '\$45K', Icons.attach_money, Color.fromARGB(255, 75, 167, 167)),
      ],
    );
  }

  Widget _buildStatisticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 8, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
