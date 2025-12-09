import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:munshi/features/receipt/services/receipt_service.dart';
import 'package:munshi/features/transactions/providers/transaction_provider.dart';
import 'package:munshi/features/transactions/screens/transaction_form_screen.dart';
import 'package:munshi/features/transactions/screens/transactions_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';

class AiReceiptScreen extends StatefulWidget {
  const AiReceiptScreen({required this.media, super.key});
  final SharedMedia media;

  @override
  State<AiReceiptScreen> createState() => _AiReceiptScreenState();
}

class _AiReceiptScreenState extends State<AiReceiptScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to transaction form immediately with AI processing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToTransactionForm();
    });
  }

  void _navigateToTransactionForm() {
    final aiProcessingFuture = _processReceipt();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => TransactionFormScreen(
          aiProcessingFuture: aiProcessingFuture,
          onSubmit: (insertable) async {
            await context.read<TransactionProvider>().addTransaction(
              insertable,
            );

            // Navigate back to transactions screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => const TransactionsScreen(),
              ),
              (route) => route.isFirst,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction Added Successfully')),
            );
          },
        ),
      ),
    );
  }

  Future<AIReceiptData?> _processReceipt() async {
    final imagePath = widget.media.attachments?.first?.path;
    if (imagePath == null) return null;

    try {
      final file = File(imagePath);
      log('Processing receipt at path: $imagePath');

      // Perform OCR
      final ocrResult = await FlutterOcr.recognizeTextFromImage(file.path);
      if (ocrResult == null) {
        log('OCR returned null');
        return null;
      }

      log('OCR result: $ocrResult');

      // Extract data using AI
      final aiData = await locator<ReceiptAIService>()
          .extractReceiptDataFromText(ocrResult);

      log('Extracted Receipt Data: $aiData');
      return aiData;
    } on Exception catch (e, stackTrace) {
      log('Error processing receipt: $e', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This screen is just a transition screen
    // The actual UI is in TransactionFormScreen
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
