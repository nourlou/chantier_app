import 'package:chantier_test/DashbordAchat.dart';
import 'package:chantier_test/depences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:chantier_test/AjoutAchats.dart';
import 'package:chantier_test/GestionArticle.dart';
import 'package:chantier_test/GestionClient.dart';
import 'package:chantier_test/GestionFournisseur.dart';
import 'package:chantier_test/ManageChantiersPage.dart';
import 'package:chantier_test/gestionProjet.dart';
import 'package:flutter/material.dart';

import 'AdminPage.dart';
import 'HomePage.dart';
import 'SignIn.dart';
import 'signup_page.dart';
import 'ProfilePage.dart';
import 'FinancialOverviewPage.dart';
import 'BankManagementPage.dart';
import 'FinancialTransactionsPage.dart';
import 'FinancialReportsPage.dart';
import 'ChantierPage.dart';
import 'DashboardPage.dart';
import 'FinanceManagementPage.dart';
import 'ManageUsersPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Entreprises de Bâtiments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/admin_dashboard': (context) => AdminPage(adminName: 'Admin'),
        '/chantiers': (context) => ChantierPage(),
        '/dashboard': (context) => DashboardPage(userName: 'User', userEmail: '',),
        '/manage_users': (context) => ManageUsersPage(),
        '/projects' : (context)=> ManageProjectsPage(),
        '/finance_management': (context) => FinanceManagementPage(),
        '/financial_overview': (context) => FinancialOverviewPage(),
        '/bank_management': (context) => BankManagementPage(),
        '/financial_transactions': (context) => FinancialTransactionsPage(),
        '/financial_reports': (context) => FinancialReportsPage(),
        '/profile': (context) => ProfilePage(userName: '', userEmail: '',),
        '/gestion':(context)=>GestionProjetPage(),
        '/ajouter_article':(context)=>GestionarticlePage(),
        '/fournisseur' :(context)=>GestionFournisseurPage(),
        '/client':(context)=>GestionClientPage(),
        '/achats' :(context)=>DashbordProjetPage(),
        '/ajoutAchats':(context)=>AchatPage(),
        '/depences':(context)=>DepencePage(),
      },
    );
  }
}
