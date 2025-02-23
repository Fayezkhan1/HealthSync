import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'loading.dart';
import 'main.dart';
import 'acne_result.dart';
import 'package:http/http.dart' as http;

class AcnePage extends StatefulWidget {
  const AcnePage({super.key});

  @override
  State<AcnePage> createState() => _AcnePageState();
}

class _AcnePageState extends State<AcnePage> {
  File? _firstSkinImage;
  File? _secondSkinImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String skinArea) async {
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
            if (skinArea == 'first') {
              _firstSkinImage = File(image.path);
            } else {
              _secondSkinImage = File(image.path);
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

  Future<void> _diagnoseAcne() async {
    if (_firstSkinImage == null || _secondSkinImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingPage()),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/acne'),
      );

      request.files.add(await http.MultipartFile.fromPath('acne1', _firstSkinImage!.path));
      request.files.add(await http.MultipartFile.fromPath('acne2', _secondSkinImage!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        Navigator.pop(context); // Remove loading page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AcneResultPage(responseData.body)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acne Diagnosis'),
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
                'Please upload two clear images of your skin from different angles to ensure accurate acne analysis.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              if (_firstSkinImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(
                    _firstSkinImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ElevatedButton(
                onPressed: () => _pickImage('first'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _firstSkinImage == null ? Colors.grey[300] : Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_firstSkinImage == null ? 'Add First Skin Image' : 'First Image Added'),
              ),
              const SizedBox(height: 30),
              if (_secondSkinImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(
                    _secondSkinImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ElevatedButton(
                onPressed: () => _pickImage('second'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondSkinImage == null ? Colors.grey[300] : Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_secondSkinImage == null ? 'Add Second Skin Image' : 'Second Image Added'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_firstSkinImage != null && _secondSkinImage != null) ? _diagnoseAcne : null,
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
