import 'package:flutter/material.dart';

// Modèle de client
class Client {
  String raisonSociale;
  String categorie;
  String codeTVA;
  String contact;
  String gsm1;
  String gsm2;
  String email;
  String adresse;
  String ville;
  String imageUrl;

  Client({
    required this.raisonSociale,
    required this.categorie,
    required this.codeTVA,
    required this.contact,
    required this.gsm1,
    required this.gsm2,
    required this.email,
    required this.adresse,
    required this.ville,
    this.imageUrl = '',
  });
}

final List<Client> clients = [
  Client(
    raisonSociale: 'Client Alpha',
    categorie: 'Catégorie A',
    codeTVA: '1234567890',
    contact: 'nour louhichi',
    gsm1: '123456789',
    gsm2: '987654321',
    email: 'nour@gmail.com',
    adresse: 'adresse',
    ville: 'nabeul',
    imageUrl: 'image/nour.jpg',
  ),
];

// Page de gestion des clients
class GestionClientPage extends StatefulWidget {
  @override
  _GestionClientPageState createState() => _GestionClientPageState();
}

class _GestionClientPageState extends State<GestionClientPage> {
  // Contrôleurs pour les champs de formulaire
  TextEditingController raisonSocialeController = TextEditingController();
  TextEditingController categorieController = TextEditingController();
  TextEditingController codeTVAController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController gsm1Controller = TextEditingController();
  TextEditingController gsm2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController villeController = TextEditingController();

  // Fonction pour supprimer un client
  void _deleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce client ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue de confirmation
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  clients.remove(client); // Supprimer le client de la liste
                });
                Navigator.of(context).pop(); // Fermer la boîte de dialogue de confirmation
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher la boîte de dialogue d'ajout de client
  void _showAddClientDialog(BuildContext context) {
    // Initialiser les contrôleurs pour le formulaire d'ajout de client
    raisonSocialeController.clear();
    categorieController.clear();
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
          title: Text('Ajouter un Client'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: raisonSocialeController,
                  decoration: InputDecoration(labelText: 'Raison sociale'),
                ),
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: codeTVAController,
                  decoration: InputDecoration(labelText: 'Code TVA'),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact'),
                ),
                TextField(
                  controller: gsm1Controller,
                  decoration: InputDecoration(labelText: 'Gsm1'),
                ),
                TextField(
                  controller: gsm2Controller,
                  decoration: InputDecoration(labelText: 'Gsm2'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: adresseController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: villeController,
                  decoration: InputDecoration(labelText: 'Ville'),
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
                // Ajouter le client à la liste
                setState(() {
                  clients.add(Client(
                    raisonSociale: raisonSocialeController.text,
                    categorie: categorieController.text,
                    codeTVA: codeTVAController.text,
                    contact: contactController.text,
                    gsm1: gsm1Controller.text,
                    gsm2: gsm2Controller.text,
                    email: emailController.text,
                    adresse: adresseController.text,
                    ville: villeController.text,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }


  // Function to show edit client dialog
  void _showEditClientDialog(BuildContext context, Client client) {
    // Initialize controllers with current client data
    raisonSocialeController.text = client.raisonSociale;
    categorieController.text = client.categorie;
    codeTVAController.text = client.codeTVA;
    contactController.text = client.contact;
    gsm1Controller.text = client.gsm1;
    gsm2Controller.text = client.gsm2;
    emailController.text = client.email;
    adresseController.text = client.adresse;
    villeController.text = client.ville;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Client'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: raisonSocialeController,
                  decoration: InputDecoration(labelText: 'Raison sociale'),
                ),
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: codeTVAController,
                  decoration: InputDecoration(labelText: 'Code TVA'),
                ),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact'),
                ),
                TextField(
                  controller: gsm1Controller,
                  decoration: InputDecoration(labelText: 'Gsm1'),
                ),
                TextField(
                  controller: gsm2Controller,
                  decoration: InputDecoration(labelText: 'Gsm2'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: adresseController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: villeController,
                  decoration: InputDecoration(labelText: 'Ville'),
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
                  // Update client data
                  client.raisonSociale = raisonSocialeController.text;
                  client.categorie = categorieController.text;
                  client.codeTVA = codeTVAController.text;
                  client.contact = contactController.text;
                  client.gsm1 = gsm1Controller.text;
                  client.gsm2 = gsm2Controller.text;
                  client.email = emailController.text;
                  client.adresse = adresseController.text;
                  client.ville = villeController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
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
        title: Text('Gestion des Clients'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search if needed
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return _buildClientCard(context, clients[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddClientDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

Widget _buildClientCard(BuildContext context, Client client) {
  return GestureDetector(
    onTap: () {
      _showEditClientDialog(context, client); // Ouvre la boîte de dialogue de modification lors du tap
    },
    child: Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100], // Fond de carte plus doux
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [

                  CircleAvatar(
                    radius: 20,
                    backgroundImage: client.imageUrl != null && client.imageUrl.isNotEmpty
                        ? NetworkImage(client.imageUrl)
                        : AssetImage('image/nour.jpg'),
                  ),


                      SizedBox(width: 12),
                      Text(
                        client.raisonSociale,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showEditClientDialog(context, client);
                        },
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteClient(context, client);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8), // Espacement entre le titre et les informations
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Catégorie', client.categorie),
                  _buildInfoRow('Code TVA', client.codeTVA),
                  _buildInfoRow('Contact', client.contact),
                  _buildInfoRow('Gsm1', client.gsm1),
                  _buildInfoRow('Gsm2', client.gsm2),
                  _buildInfoRow('Email', client.email),
                  _buildInfoRow('Adresse', client.adresse),
                  _buildInfoRow('Ville', client.ville),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(width: 12), // Espacement entre le label et la valeur
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

  

void main() {
  runApp(MaterialApp(
    home: GestionClientPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

}