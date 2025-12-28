import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:share_handler/share_handler.dart';

/// A lightweight, cost-efficient service for extracting structured
/// transaction and item data from receipts using Gemini models via Firebase AI.
class ReceiptAIService {
  ReceiptAIService(this.model);
  GenerativeModel model;

  Future<AIReceiptData?> process(SharedMedia media) async {
    final imagePath = media.attachments?.first?.path;
    if (imagePath == null) return null;

    try {
      final file = File(imagePath);
      log('Processing receipt at path: $imagePath');

      // Fetch expense categories from database
      final db = locator<AppDatabase>();
      final expenseCategories = await db.categoriesDao.getExpenseCategories();
      log('Fetched ${expenseCategories.length} expense categories');

      // Perform OCR
      final ocrResult = await FlutterOcr.recognizeTextFromImage(file.path);
      if (ocrResult == null) {
        log('OCR returned null');
        return null;
      }

      log('OCR result: $ocrResult');

      // Extract data using AI with available categories
      final aiData = await _extractReceiptDataFromText(
        ocrResult,
        availableCategories: expenseCategories,
      );

      log('Extracted Receipt Data: $aiData');
      return aiData;
    } on Exception catch (e, stackTrace) {
      log('Error processing receipt: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// Extracts structured transaction data from OCR text of a receipt.
  /// [availableCategories] - List of expense categories to suggest from
  Future<AIReceiptData> _extractReceiptDataFromText(
    String ocrText, {
    List<TransactionCategory> availableCategories = const [],
  }) async {
    const systemPrompt = '''
You are a precise receipt parser for a personal finance app.
Read the given text extracted from a receipt or invoice.
Extract only the essential transaction details needed for expense tracking.
If data is missing, use empty strings. Do not add or assume information.
''';

    // Build category options string from available categories
    final categoryOptions = availableCategories.isNotEmpty
        ? availableCategories.map((c) => c.name).join(', ')
        : 'Food & Dining, Shopping, Transportation, Utilities, Entertainment, Healthcare, Other';

    final userPrompt =
        '''
From the following receipt text, extract the essential transaction details and return only a valid JSON object with these fields:

{
  "amount": "",           // Total amount (numeric value only, e.g., "150.50")
  "merchant_name": "",    // Name of the store/merchant
  "category_suggestion": "", // Suggested expense category name - MUST be EXACTLY one of: $categoryOptions
  "date": "",            // Date in YYYY-MM-DD format
  "time": ""             // Time in HH:MM format (24-hour)
}

Guidelines:
- amount: Extract the total/final amount to be paid. Remove currency symbols and commas.
- merchant_name: Business or store name from the receipt header
- category_suggestion: Infer the BEST matching category from the available options: $categoryOptions. Choose the category name EXACTLY as written. If no good match, use the closest one.
- date: Convert to YYYY-MM-DD format if possible
- time: Convert to HH:MM 24-hour format if available

Text:
''';

    final response = await model.generateContent(
      [
        Content.model([const TextPart(systemPrompt)]),
        Content.text('$userPrompt\n$ocrText'),
      ],
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final jsonResponse =
        jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
    return AIReceiptData.fromJson(
      jsonResponse,
      availableCategories: availableCategories,
    );
  }
}
