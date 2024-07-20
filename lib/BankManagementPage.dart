import 'package:flutter/material.dart';

class BankManagementPage extends StatefulWidget {
  @override
  _BankManagementPageState createState() => _BankManagementPageState();
}

class _BankManagementPageState extends State<BankManagementPage> {
  List<Bank> listOfBanks = [
    Bank(name: 'BIAT', location: 'Tunis'),
    Bank(name: 'STB', location: 'Sousse'),
    Bank(name: 'Zitouna', location: 'Sfax'),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isEditing = false;
  int _editedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Banques'),
        backgroundColor: Color.fromARGB(255, 118, 150, 175),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showAddBankDialog,
              child: Text('Ajouter une Banque'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 119, 140, 198),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: listOfBanks.length,
                itemBuilder: (context, index) {
                  final bank = listOfBanks[index];
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        bank.name,
                        style: TextStyle(
                          color: Color.fromARGB(255, 4, 55, 97),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(bank.location),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              _showEditBankDialog(context, index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteBank(index);
                            },
                          ),
                        ],
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

  void _showAddBankDialog() {
    _nameController.clear();
    _locationController.clear();
    _isEditing = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une Nouvelle Banque'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la Banque',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Emplacement de la Banque',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateBank();
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 220, 223, 226),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditBankDialog(BuildContext context, int index) {
    _nameController.text = listOfBanks[index].name;
    _locationController.text = listOfBanks[index].location;
    _isEditing = true;
    _editedIndex = index;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la Banque'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la Banque',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Emplacement de la Banque',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateBank();
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdateBank() {
    String name = _nameController.text.trim();
    String location = _locationController.text.trim();
    if (name.isNotEmpty && location.isNotEmpty) {
      setState(() {
        if (_isEditing) {
          listOfBanks[_editedIndex] = Bank(name: name, location: location);
        } else {
          listOfBanks.add(Bank(name: name, location: location));
        }
      });
    }
  }

  void _deleteBank(int index) {
    setState(() {
      listOfBanks.removeAt(index);
    });
  }
}

class Bank {
  final String name;
  final String location;

  Bank({required this.name, required this.location});
}
