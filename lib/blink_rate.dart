

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'loading.dart';
import 'blink_rate_result.dart';

class BlinkRatePage extends StatefulWidget {
  const BlinkRatePage({super.key});

  @override
  State<BlinkRatePage> createState() => _BlinkRatePageState();
}

class _BlinkRatePageState extends State<BlinkRatePage> {
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  Future<void> _diagnoseBlinkRate() async {
  if (_videoFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please upload or record a video first.')),
    );
    return;
  }

  // Navigate to Loading Page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoadingPage()),
  );

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:5000/blink_rate'),
    );

    // Attach video file
    request.files.add(await http.MultipartFile.fromPath('video', _videoFile!.path));

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // Extracting data from response
      String blinkRate = responseData['blink_rate'].toString();
      String caption = responseData['caption'];
      String graphImageBase64 = responseData['graph_image'];

      // Navigate to Blink Rate Result Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BlinkRateResultPage(
            blinkRate: blinkRate,
            caption: caption,
            graphImageBase64: graphImageBase64,
          ),
        ),
      );
    } else {
      Navigator.pop(context); // Exit Loading Page
      _showErrorDialog("Error: ${response.statusCode}");
    }
  } catch (e) {
    Navigator.pop(context); // Exit Loading Page
    _showErrorDialog("An error occurred: $e");
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blink Rate Diagnosis'),
          backgroundColor: const Color(0xFFB31B1B),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $Name,',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please upload or record a video of you blinking for analysis.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_videoFile != null)
                Column(
                  children: [
                    const Text(
                      'Selected Video:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          _videoFile!.path.split('/').last,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Upload Video'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _recordVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record Video'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _diagnoseBlinkRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB31B1B),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Diagnose',
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
