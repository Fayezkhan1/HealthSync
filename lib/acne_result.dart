import 'package:flutter/material.dart';
import 'dart:convert';
import 'report.dart';

class AcneResultPage extends StatelessWidget {
  final String responseBody;

  const AcneResultPage(this.responseBody, {super.key});

  @override
  Widget build(BuildContext context) {
    final responseJson = jsonDecode(responseBody);

    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Acne Diagnosis Result'),
          backgroundColor: const Color(0xFFB31B1B),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                'Acne 1:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(
                base64Decode(responseJson['acne1']['image']),
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                'Detected Labels: ${responseJson['acne1']['label'].join(", ")}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'Acne 2:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(
                base64Decode(responseJson['acne2']['image']),
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                'Detected Labels: ${responseJson['acne2']['label'].join(", ")}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB31B1B),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
