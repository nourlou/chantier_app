import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Financière du Chantier'),
        backgroundColor: const Color.fromARGB(255, 167, 178, 197),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Financière du Chantier',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ce graphique montre la performance financière du chantier au fil du temps.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Expanded(
                child: buildFinancialChart(),
              ),
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFinancialChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            margin: 10,
            interval: 1000, // Ajuster selon les données réelles
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            margin: 10,
            interval: 1, // Ajuster selon les données réelles
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 10000), // Exemple de données financières pour le chantier
              FlSpot(1, 12000),
              FlSpot(2, 15000),
              FlSpot(3, 18000),
              FlSpot(4, 20000),
              FlSpot(5, 25000),
              FlSpot(6, 30000),
            ],
            isCurved: true,
            colors: [Colors.blue],
            barWidth: 4,
            belowBarData: BarAreaData(show: true, colors: [
              Colors.blue.withOpacity(0.3)
            ]),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
