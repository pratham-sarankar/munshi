import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:share_handler/share_handler.dart';

import '../services/receipt_service.dart';

class AiReceiptScreen extends StatefulWidget {
  const AiReceiptScreen({super.key, required this.media});
  final SharedMedia media;
  @override
  State<AiReceiptScreen> createState() => _AiReceiptScreenState();
}

class _AiReceiptScreenState extends State<AiReceiptScreen> {
  bool isProcessing = true;
  AIReceiptData? result;

  @override
  void initState() {
    super.initState();
    processReceipt();
  }

  void processReceipt() async {
    final imagePath = widget.media.attachments?.first?.path;
    if (imagePath == null) return null;
    try {
      final filePath = widget.media.attachments?.first?.path;
      log('Processing file at path: $filePath');
      if (filePath == null) return null;
      final file = File(filePath);
      final ocrResult = await FlutterOcr.recognizeTextFromImage(file.path);
      if (ocrResult == null) return null;
      log('OCR result: $ocrResult');
      final jsonResponse = await locator<ReceiptAIService>()
          .extractReceiptDataFromText(ocrResult);
      setState(() {
        result = jsonResponse;
      });
      log('Extracted Receipt Data: $jsonResponse');
    } catch (e) {
      log('OCR Error: $e');
      return null;
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  String prettyPrintJson(Map<String, dynamic> jsonMap) {
    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(jsonMap);
    log(pretty); // or print(pretty)
    return pretty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Processing receipt...'),
            ] else ...[
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text('Receipt processed successfully!'),
              const SizedBox(height: 16),
              if (result != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(prettyPrintJson(result!.toJson())),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
