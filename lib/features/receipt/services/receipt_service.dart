import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';

/// A lightweight, cost-efficient service for extracting structured
/// transaction and item data from receipts using Gemini models via Firebase AI.
class ReceiptAIService {
  ReceiptAIService(this.model);
  GenerativeModel model;

  /// Extracts structured transaction data from OCR text of a receipt.
  Future<AIReceiptData> extractReceiptDataFromText(String ocrText) async {
    const systemPrompt = '''
You are a precise receipt parser for a personal finance app.
Read the given text extracted from a receipt or invoice.
Extract only the essential transaction details needed for expense tracking.
If data is missing, use empty strings. Do not add or assume information.
''';

    const userPrompt = '''
From the following receipt text, extract the essential transaction details and return only a valid JSON object with these fields:

{
  "amount": "",           // Total amount (numeric value only, e.g., "150.50")
  "merchant_name": "",    // Name of the store/merchant
  "category_suggestion": "", // Suggested expense category (e.g., "Food & Dining", "Shopping", "Transportation", "Utilities", "Entertainment", "Healthcare", "Other")
  "date": "",            // Date in YYYY-MM-DD format
  "time": ""             // Time in HH:MM format (24-hour)
}

Guidelines:
- amount: Extract the total/final amount to be paid. Remove currency symbols and commas.
- merchant_name: Business or store name from the receipt header
- category_suggestion: Infer category from merchant name or items (use common categories like Food & Dining, Shopping, Transportation, Entertainment, Healthcare, Utilities, or Other)
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
    return AIReceiptData.fromJson(jsonResponse);
  }
}
