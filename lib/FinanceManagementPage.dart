import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinanceManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Management'),
        backgroundColor: const Color.fromARGB(255, 167, 178, 197),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Financial Overview'),
              SizedBox(height: 10),
              _buildFinancialOverview(context),
              SizedBox(height: 20),
              _buildSectionHeader('Bank Management'),
              SizedBox(height: 10),
              _buildBankManagement(context),
              SizedBox(height: 20),
              _buildSectionHeader('Financial Transactions'),
              SizedBox(height: 10),
              _buildFinancialTransactions(context),
              SizedBox(height: 20),
              _buildSectionHeader('Financial Reports'),
              SizedBox(height: 10),
              _buildFinancialReports(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/financial_overview');
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.analytics, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                'View Financial Overview',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              _buildSampleChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankManagement(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/bank_management');
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance, size: 50, color: Colors.green),
              SizedBox(height: 10),
              Text(
                'Manage Banks',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialTransactions(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/financial_transactions');
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.attach_money, size: 50, color: Colors.orange),
              SizedBox(height: 10),
              Text(
                'View Financial Transactions',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialReports(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/financial_reports');
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description, size: 50, color: Colors.purple),
              SizedBox(height: 10),
              Text(
                'Generate Financial Reports',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 5),
                FlSpot(4, 3.5),
                FlSpot(5, 4),
                FlSpot(6, 3),
              ],
              isCurved: true,
              colors: [Colors.blue],
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
