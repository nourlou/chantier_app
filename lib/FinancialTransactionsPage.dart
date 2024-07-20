import 'package:flutter/material.dart';

class FinancialTransactionsPage extends StatefulWidget {
  @override
  _FinancialTransactionsPageState createState() =>
      _FinancialTransactionsPageState();
}

class _FinancialTransactionsPageState extends State<FinancialTransactionsPage> {
  List<FinancialEntry> _financialEntries = [];

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isEditing = false;
  int _editedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi Financier'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _showAddFinancialEntryDialog,
              child: Text('Ajouter une Entrée Financière'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                textStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _financialEntries.length,
                itemBuilder: (context, index) {
                  final entry = _financialEntries[index];
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        entry.description,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '\$${entry.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.indigo),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditFinancialEntryDialog(context, index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteFinancialEntry(index);
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

  void _showAddFinancialEntryDialog() {
    _descriptionController.clear();
    _amountController.clear();
    _isEditing = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une Nouvelle Entrée Financière'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                _addOrUpdateFinancialEntry();
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditFinancialEntryDialog(BuildContext context, int index) {
    _descriptionController.text = _financialEntries[index].description;
    _amountController.text = _financialEntries[index].amount.toString();
    _isEditing = true;
    _editedIndex = index;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier l\'Entrée Financière'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                _addOrUpdateFinancialEntry();
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdateFinancialEntry() {
    final description = _descriptionController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (description.isNotEmpty && amount != 0.0) {
      setState(() {
        if (_isEditing) {
          _financialEntries[_editedIndex] = FinancialEntry(
              description: description, amount: amount);
        } else {
          _financialEntries.add(FinancialEntry(
              description: description, amount: amount));
        }
      });
    }
  }

  void _deleteFinancialEntry(int index) {
    setState(() {
      _financialEntries.removeAt(index);
    });
  }
}

class FinancialEntry {
  final String description;
  final double amount;

  FinancialEntry({required this.description, required this.amount});
}
