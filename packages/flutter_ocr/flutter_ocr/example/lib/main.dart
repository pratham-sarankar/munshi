import 'package:flutter/material.dart';
import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _recognizedText = '';

  Future<void> _pickImageAndRecognizeText() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final text = await FlutterOcr.recognizeTextFromImage(image.path);
      setState(() {
        _recognizedText = text ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Example'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          children: [
            const SizedBox(height: 20),
            Text(
              'Recognized Text',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _recognizedText.split('\n').map<Widget>((line) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.grey[200],
                  child: Text(line),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _pickImageAndRecognizeText,
              child: const Text('Pick Image and Recognize Text'),
            ),
          ],
        ),
      ),
    );
  }
}
