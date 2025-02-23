import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double heartRate = 75;
  double bloodOxygen = 98;
  String mood = "Happy";
  int stepCount = 0;
  bool fallDetected = false;
  int standingTime = 0;
  double bodyTemperature = 36.5;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        heartRate = 60 + random.nextInt(50).toDouble();
        bloodOxygen = 90 + random.nextDouble() * 10;
        mood = random.nextBool() ? "Happy" : "Stressed";
        stepCount += random.nextInt(20);
        fallDetected = random.nextInt(100) < 5;
        standingTime += 1;
        bodyTemperature = 35.5 + random.nextDouble() * 2.0;

        _checkThresholds();
      });
    });
  }

  void _checkThresholds() {
    if (heartRate > 100) _sendAlert("High Heart Rate", "Heart rate is above 100 bpm.");
    if (bloodOxygen < 94) _sendAlert("Low Blood Oxygen", "SpO2 is below 94%.");
    if (fallDetected) _sendAlert("Fall Detected", "A fall has been detected.");
    if (standingTime > 60) _sendAlert("Take a Break", "You have been standing for too long.");
    if (bodyTemperature > 37.5) _sendAlert("High Body Temperature", "Temperature above 37.5°C.");
  }

  Future<void> _sendAlert(String title, String message) async {
    try {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000/alert'),
        headers: {'Content-Type': 'application/json'},
        body: '{"title": "$title", "message": "$message"}',
      );

      if (response.statusCode == 200) {
        print("✅ Alert sent: $title");
      } else {
        print("❌ Failed to send alert: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error sending alert: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Dashboard"),
        backgroundColor: const Color(0xFFB31B1B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHealthCard("Heart Rate", "$heartRate bpm", heartRate > 100),
            _buildHealthCard("Blood Oxygen", "$bloodOxygen%", bloodOxygen < 94),
            _buildHealthCard("Mood", mood, mood == "Stressed"),
            _buildHealthCard("Step Count", "$stepCount steps", false),
            _buildHealthCard("Fall Detection", fallDetected ? "Fall Detected!" : "No Fall", fallDetected),
            _buildHealthCard("Standing Time", "$standingTime min", standingTime > 60),
            _buildHealthCard("Body Temperature", "$bodyTemperature°C", bodyTemperature > 37.5),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, String value, bool isCritical) {
    return Card(
      color: isCritical ? Colors.red.shade100 : Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
        trailing: isCritical ? const Icon(Icons.warning, color: Colors.red) : null,
      ),
    );
  }
}
