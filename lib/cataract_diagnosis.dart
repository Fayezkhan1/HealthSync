import 'package:axxess/blink_rate.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CataractDiagnosisPage extends StatelessWidget {
  final String responseBody;

  const CataractDiagnosisPage(this.responseBody, {super.key});

  @override
  Widget build(BuildContext context) {
    // Decode the response
    final responseJson = jsonDecode(responseBody);

    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eye Diagnosis Result'),
          backgroundColor: const Color(0xFFB31B1B),
          automaticallyImplyLeading: false, // Remove back icon
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                'Left Eye:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(
                base64Decode(responseJson['left_eye']['image']),
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                responseJson['left_eye']['caption'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'Right Eye:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(
                base64Decode(responseJson['right_eye']['image']),
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                responseJson['right_eye']['caption'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BlinkRatePage()),
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
