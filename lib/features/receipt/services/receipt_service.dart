import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:munshi/features/receipt/screens/ai_receipt_screen.dart';

/// A lightweight, cost-efficient service for extracting structured
/// transaction and item data from receipts using Gemini models via Firebase AI.
class ReceiptAIService {
  GenerativeModel model;

  ReceiptAIService(this.model);

  /// Extracts structured transaction data from OCR text of a receipt.
  Future<AIReceiptData> extractReceiptDataFromText(String ocrText) async {
    const systemPrompt = """
You are a precise receipt parser. 
Read the given text extracted from a receipt or invoice.
Return a compact JSON with merchant, transaction, and item details.
If data is missing, use empty strings. Do not add or assume information.
""";

    const userPrompt = """
From the following receipt text, extract all details and return only a valid JSON object:

{
  "merchant_details": {
    "name": "",
    "address": "",
    "phone_number": "",
    "email": "",
    "website": ""
  },
  "transaction_details": {
    "transaction_id": "",
    "date": "",
    "time": "",
    "payment_method": "",
    "payment_provider": "",
    "card_or_account_last4": "",
    "currency": "",
    "subtotal": "",
    "tax": "",
    "discount": "",
    "total_amount": ""
  },
  "items": [
    {
      "item_name": "",
      "quantity": "",
      "unit_price": "",
      "total_price": "",
      "category": ""
    }
  ],
  "additional_info": {
    "notes": "",
    "terminal_id": "",
    "invoice_number": "",
    "reference_number": "",
    "receipt_type": "",
    "country": "",
    "language": ""
  }
}
Text:
""";

    final response = await model.generateContent(
      [
        Content.model([TextPart(systemPrompt)]),
        Content.text('$userPrompt\n$ocrText'),
      ],
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final jsonResponse = jsonDecode(response.text ?? '{}');
    return AIReceiptData.fromJson(jsonResponse);
  }
}
