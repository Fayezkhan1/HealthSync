import 'package:axxess/cataract_diagnosis.dart' show CataractDiagnosisPage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'loading.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

class CataractPage extends StatefulWidget {
  const CataractPage({super.key});

  @override
  State<CataractPage> createState() => _CataractPageState();
}

class _CataractPageState extends State<CataractPage> {
  File? _rightEyeImage;
  File? _leftEyeImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String eye) async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Upload from Gallery'),
            ),
          ],
        ),
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            if (eye == 'right') {
              _rightEyeImage = File(image.path);
            } else {
              _leftEyeImage = File(image.path);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Diagnosis'),
        centerTitle: true,
        backgroundColor: const Color(0xFFB31B1B),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey $Name,',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please provide a photo of your right eye',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (_rightEyeImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(
                    _rightEyeImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ElevatedButton(
                onPressed: () => _pickImage('right'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rightEyeImage == null ? Colors.grey[300] : Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_rightEyeImage == null ? 'Add Right Eye Photo' : 'Right Eye Added'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Please provide a photo of your left eye',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
           
              if (_leftEyeImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(
                    _leftEyeImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ElevatedButton(
                onPressed: () => _pickImage('left'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _leftEyeImage == null ? Colors.grey[300] : Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_leftEyeImage == null ? 'Add Left Eye Photo' : 'Left Eye Added'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
  onPressed: (_rightEyeImage != null && _leftEyeImage != null)
      ? () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoadingPage()),
          );

          try {
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('http://127.0.0.1:5000/cataract'),
            );

            request.files.add(await http.MultipartFile.fromPath('right_eye', _rightEyeImage!.path));
            request.files.add(await http.MultipartFile.fromPath('left_eye', _leftEyeImage!.path));

            var response = await request.send();

            if (response.statusCode == 200) {
              var responseData = await http.Response.fromStream(response);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CataractDiagnosisPage(responseData.body),
                ),
              );
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Diagnosis failed: ${response.statusCode}')),
              );
            }
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error sending images: $e')),
            );
          }
        }
      : null,
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: const Color(0xFFB31B1B),
  ),
  child: const Text(
    'Diagnose',
    style: TextStyle(color: Colors.white),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}