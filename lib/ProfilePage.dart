import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String userEmail = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Nom inconnu";
      userEmail = prefs.getString('userEmail') ?? "Email inconnu";
      userRole = prefs.getString('userRole') ?? "Rôle inconnu";
    });
  }

  Future<void> _deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Token deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil utilisateur'),
        backgroundColor: const Color.fromARGB(255, 167, 178, 197),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil et section d'information
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('image/nour.jpg'),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 20),
            Text(
              'Informations de l\'utilisateur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blueAccent),
                title: Text('Nom'),
                subtitle: Text(userName),
              ),
            ),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.blueAccent),
                title: Text('Email'),
                subtitle: Text(userEmail),
              ),
            ),
            Card(
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.security, color: Colors.blueAccent),
                title: Text('Rôle'),
                subtitle: Text(userRole),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _deleteToken();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout),
              label: Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
