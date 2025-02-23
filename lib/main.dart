import 'package:flutter/material.dart';
import 'login.dart';
import 'blink_rate.dart';
import 'cataract.dart';
import 'lungs.dart';
import 'acne.dart';
import 'dashboard_page.dart';

String Name = '';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Axxess Eye Diagnosis',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/cataract': (context) => const CataractPage(),
        '/lungs': (context) => const LungsPage(),
        '/acne': (context) => const AcnePage(),


      //  '/': (context) => const  DashboardPage(),
      },
    );
  }
}
