import 'acne.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class LungsPage extends StatefulWidget {
  const LungsPage({super.key});

  @override
  State<LungsPage> createState() => _LungsPageState();
}

class _LungsPageState extends State<LungsPage> {
  File? _audioFile;
  String? _diagnosisResult;
  bool _isLoading = false;

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio file selected.')),
      );
    }
  }

  Future<void> _diagnoseAudio() async {
    if (_audioFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/lungs'),
      );

      request.files.add(await http.MultipartFile.fromPath('audio_file', _audioFile!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          _diagnosisResult = responseData.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diagnosis failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during diagnosis: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lung Auscultation Diagnosis'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB31B1B),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Hey $Name,',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please upload a recording of your lung auscultation taken using a digital stethoscope.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: _audioFile == null ? Colors.grey[300] : Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_audioFile == null ? 'Upload Lung Sound' : 'Audio Uploaded'),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const CircularProgressIndicator(), // ✅ Loading Indicator
            if (_diagnosisResult != null)
              Expanded(
                child: Center(
                  child: Text(
                    'Diagnosis Result:\n$_diagnosisResult',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_diagnosisResult == null && !_isLoading)
              ElevatedButton(
                onPressed: _audioFile != null ? _diagnoseAudio : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFB31B1B),
                ),
                child: const Text(
                  'Diagnose',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (_diagnosisResult != null)
              ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AcnePage()),
    );
  },
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.green,
  ),
  child: const Text(
    'Continue',
    style: TextStyle(color: Colors.white),
  ),
),
          ],
        ),
      ),
    );
  }
}
