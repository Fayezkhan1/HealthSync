import 'package:flutter/material.dart';
import 'dart:convert';

class BlinkRateResultPage extends StatelessWidget {
  final String blinkRate;
  final String caption;
  final String graphImageBase64;

  const BlinkRateResultPage({
    super.key,
    required this.blinkRate,
    required this.caption,
    required this.graphImageBase64,
  });

  @override
  Widget build(BuildContext context) {
    final int roundedBlinkRate = double.parse(blinkRate).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blink Rate Result'),
        backgroundColor: const Color(0xFFB31B1B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Blink Rate: $roundedBlinkRate blinks/min',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              caption,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Blink Rate Graph:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: graphImageBase64.isNotEmpty
                  ? Image.memory(base64Decode(graphImageBase64))
                  : const Text("No graph available"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
  Navigator.pushNamed(context, '/lungs');
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB31B1B),
                  ),
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
