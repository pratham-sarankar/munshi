import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_ocr/flutter_ocr.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:munshi/features/receipt/services/receipt_service.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
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
  bool isProcessing = true;
  AIReceiptData? result;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    processReceipt();
  }

  Future<void> processReceipt() async {
    final imagePath = widget.media.attachments?.first?.path;
    if (imagePath == null) return;
    try {
      final filePath = widget.media.attachments?.first?.path;
      log('Processing file at path: $filePath');
      if (filePath == null) return;
      final file = File(filePath);
      final ocrResult = await FlutterOcr.recognizeTextFromImage(file.path);
      if (ocrResult == null) return;
      log('OCR result: $ocrResult');
      final jsonResponse = await locator<ReceiptAIService>()
          .extractReceiptDataFromText(ocrResult);
      setState(() {
        result = jsonResponse;
      });
      log('Extracted Receipt Data: $jsonResponse');
    } catch (e) {
      log('OCR Error: $e');
      setState(() {
        errorMessage = 'Something went wrong while processing the receipt.';
      });
      return;
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  double? _parseAmount(String rawAmount) {
    if (rawAmount.isEmpty) return null;
    final clean = rawAmount.replaceAll(RegExp('[^0-9.,-]'), '');
    return double.tryParse(clean.replaceAll(',', ''));
  }

  DateTime _buildDateTime(TransactionDetails details) {
    try {
      if (details.date.isEmpty) return DateTime.now();
      // Expecting date in a reasonably parseable format like YYYY-MM-DD
      final parsedDate = DateTime.tryParse(details.date) ?? DateTime.now();
      if (details.time.isEmpty) return parsedDate;

      final timeParts = details.time.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        return DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          hour,
          minute,
        );
      }
      return parsedDate;
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _handleContinueWithResult(BuildContext context) async {
    if (result == null) return;

    final txDetails = result!.transactionDetails;
    final amount = _parseAmount(
      txDetails.totalAmount.isNotEmpty
          ? txDetails.totalAmount
          : txDetails.subtotal,
    );

    if (amount == null || amount <= 0) {
      // Open transaction form to let user fill required fields
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (ctx) => TransactionFormScreen(
            onSubmit: (insertable) async {
              await ctx.read<TransactionProvider>().addTransaction(insertable);
            },
          ),
        ),
      );
      return;
    }

    final dateTime = _buildDateTime(txDetails);

    final transaction = TransactionsCompanion(
      amount: drift.Value(amount),
      categoryId: const drift.Value(null),
      type: const drift.Value(TransactionType.expense),
      date: drift.Value(dateTime),
      note: drift.Value(
        result!.merchantDetails.name.isNotEmpty
            ? 'Receipt - ${result!.merchantDetails.name}'
            : 'Receipt transaction',
      ),
    );

    await context.read<TransactionProvider>().addTransaction(transaction);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
      (route) => route.isFirst,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction Added Successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Iconsax.scan_barcode_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Receipt Scanner',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProcessing
                              ? 'Extracting transaction details from your receipt'
                              : (errorMessage != null
                                    ? "We couldn't process this receipt"
                                    : 'Review & save your transaction'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Iconsax.close_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: isProcessing
                      ? _buildProcessingState(context, colorScheme)
                      : (errorMessage != null
                            ? _buildErrorState(context, colorScheme)
                            : _buildSuccessState(context, colorScheme)),
                ),
              ),

              if (!isProcessing && errorMessage == null && result != null)
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () => _handleContinueWithResult(context),
                    icon: const Icon(Iconsax.tick_circle_outline),
                    label: const Text('Save Transaction'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 72,
          width: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
              Icon(
                Iconsax.document_text_outline,
                size: 30,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Scanning your receipt',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          "We're using AI to extract merchant, amount, and date from your receipt. This usually takes just a few seconds.",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        _buildStepper(colorScheme),
      ],
    );
  }

  Widget _buildStepper(ColorScheme colorScheme) {
    Widget dot(bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 8,
      width: active ? 32 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [dot(true), dot(false), dot(false)],
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.warning_2_bold,
            color: colorScheme.error,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Couldn't read this receipt",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? 'Please try again with a clearer photo.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2_outline),
          label: const Text('Back to app'),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, ColorScheme colorScheme) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    final tx = result!.transactionDetails;

    final amount = _parseAmount(
      tx.totalAmount.isNotEmpty ? tx.totalAmount : tx.subtotal,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Iconsax.shopping_bag_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result!.merchantDetails.name.isNotEmpty
                              ? result!.merchantDetails.name
                              : 'Unknown merchant',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx.date.isNotEmpty
                              ? '${tx.date}  ${tx.time}'
                              : 'Date not detected',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  Icon(Iconsax.tick_circle_bold, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                amount != null
                    ? '₹${amount.toStringAsFixed(2)}'
                    : 'Amount missing',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tx.paymentMethod.isNotEmpty
                    ? tx.paymentMethod
                    : 'Payment method not detected',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result!.items.isNotEmpty) ...[
                  Text(
                    'Items detected',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...result!.items
                      .take(5)
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            item.itemName.isNotEmpty
                                ? item.itemName
                                : 'Unnamed item',
                          ),
                          subtitle: Text(
                            '${item.quantity} x ${item.unitPrice}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          trailing: Text(
                            item.totalPrice.isNotEmpty ? item.totalPrice : '-',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  if (result!.items.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${result!.items.length - 5} more items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                Text(
                  "We'll create a transaction with these details. You can always edit it later from the Transactions tab.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
