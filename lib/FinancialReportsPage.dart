import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapports Financiers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bilan Financier',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildFinancialStatement(),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Transactions Récentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildRecentTransactions(),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                // Fonction pour afficher des détails supplémentaires
              },
              child: Text(
              'Afficher les Détails',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStatement() {
    // Simulation de données pour le bilan financier
    List<PieChartSectionData> pieData = [
      PieChartSectionData(value: 40, color: Colors.green, title: 'Revenus'),
      PieChartSectionData(value: 30, color: Colors.red, title: 'Dépenses'),
      PieChartSectionData(value: 20, color: Colors.blue, title: 'Bénéfices'),
    ];

    return Column(
      children: [
        Container(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: pieData,
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 40,
              sectionsSpace: 0,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegend(color: Colors.green, title: 'Revenus'),
            _buildLegend(color: Colors.red, title: 'Dépenses'),
            _buildLegend(color: Colors.blue, title: 'Bénéfices'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String title}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 5),
        Text(title),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    // Simulation de données pour les transactions récentes
    List<String> recentTransactions = [
      'Paiement employé - \$300',
      'Achat de fournitures - \$200',
      'Achat de matériel - \$500',
    ];

    return Column(
      children: recentTransactions
          .map(
            (transaction) => ListTile(
              title: Text(
                transaction,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward,
                color: Colors.grey,
              ),
              onTap: () {
                // Action à effectuer lorsque l'utilisateur clique sur une transaction
              },
            ),
          )
          .toList(),
    );
  }
}
