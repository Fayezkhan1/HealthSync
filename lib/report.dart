import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart'; // Import Dashboard Page

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  Future<void> _getReport(BuildContext context) async {
    try {
      var response = await http.get(Uri.parse('http://127.0.0.1:5000/report'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Page'),
        backgroundColor: const Color(0xFFB31B1B),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _getReport(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB31B1B),
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Get Report',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
