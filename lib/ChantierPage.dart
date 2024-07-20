import 'package:flutter/material.dart';

class ChantierPage extends StatefulWidget {
  @override
  _ChantierPageState createState() => _ChantierPageState();
}

class _ChantierPageState extends State<ChantierPage> {
  List<Chantier> chantiers = []; // Liste des chantiers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Chantiers'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: chantiers.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text(chantiers[index].nom, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Adresse: ${chantiers[index].adresse}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        _editChantier(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteChantier(index);
                      },
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
          _showAddChantierDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _showAddChantierDialog() {
    TextEditingController _nomController = TextEditingController();
    TextEditingController _adresseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Chantier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du Chantier'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse du Chantier'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveChantier(_nomController.text, _adresseController.text);
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveChantier(String nom, String adresse) {
    setState(() {
      chantiers.add(Chantier(nom: nom, adresse: adresse));
    });
  }

  void _editChantier(int index) {
    TextEditingController _nomController = TextEditingController(text: chantiers[index].nom);
    TextEditingController _adresseController = TextEditingController(text: chantiers[index].adresse);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Chantier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du Chantier'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse du Chantier'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateChantier(index, _nomController.text, _adresseController.text);
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateChantier(int index, String nom, String adresse) {
    setState(() {
      chantiers[index].nom = nom;
      chantiers[index].adresse = adresse;
    });
  }

  void _deleteChantier(int index) {
    setState(() {
      chantiers.removeAt(index);
    });
  }
}

class Chantier {
  String nom;
  String adresse;

  Chantier({required this.nom, required this.adresse});
}
