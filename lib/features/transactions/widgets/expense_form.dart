import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/transactions/services/transaction_service.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
import 'package:intl/intl.dart';

/// Form widget for adding expense transactions.
/// 
/// This widget provides a user-friendly interface for entering expense
/// transaction details including amount, merchant, category, date/time,
/// and optional description. It validates input and saves the transaction
/// to the database using the TransactionService.
class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});
  
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  
  /// Transaction service for database operations
  late final TransactionService _transactionService;
  
  /// Flag to track form submission state
  bool _isSubmitting = false;

  /// Available expense categories with their display information
  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'Food & Dining',
      'label': 'Food & Dining',
      'icon': Iconsax.reserve_outline,
    },
    {
      'value': 'Transportation',
      'label': 'Transportation',
      'icon': Iconsax.car_outline,
    },
    {
      'value': 'Shopping',
      'label': 'Shopping',
      'icon': Iconsax.shopping_bag_outline,
    },
    {
      'value': 'Entertainment',
      'label': 'Entertainment',
      'icon': Iconsax.music_outline,
    },
    {
      'value': 'Healthcare',
      'label': 'Healthcare',
      'icon': Iconsax.health_outline,
    },
    {
      'value': 'Bills & Utilities',
      'label': 'Bills & Utilities',
      'icon': Iconsax.receipt_outline,
    },
    {
      'value': 'Education',
      'label': 'Education',
      'icon': Iconsax.book_outline,
    },
    {
      'value': 'Insurance',
      'label': 'Insurance',
      'icon': Iconsax.shield_tick_outline,
    },
    {
      'value': 'Other',
      'label': 'Other',
      'icon': Iconsax.more_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _transactionService = locator<TransactionService>();
  }

  /// Submits the expense form and saves the transaction to the database.
  /// 
  /// Validates the form data, creates a new expense transaction,
  /// and saves it using the TransactionService. Shows appropriate
  /// feedback to the user on success or error.
  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the form values
      final formData = _formKey.currentState!.value;
      
      // Extract and validate form data
      final amount = double.tryParse(formData['amount']?.toString() ?? '0') ?? 0.0;
      final merchant = formData['merchant']?.toString() ?? '';
      final category = formData['category']?.toString() ?? '';
      final dateTime = formData['datetime'] as DateTime? ?? DateTime.now();
      final description = formData['description']?.toString();

      // Validate required fields
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      if (merchant.isEmpty) {
        throw Exception('Merchant name is required');
      }
      if (category.isEmpty) {
        throw Exception('Category is required');
      }

      // Format time for storage
      final timeString = DateFormat('h:mm a').format(dateTime);

      // Create the expense transaction (amount is stored as negative for expenses)
      await _transactionService.addTransaction(
        merchant: merchant,
        amount: -amount, // Negative amount for expenses
        date: dateTime,
        time: timeString,
        category: category,
        isIncome: false,
        description: description?.isNotEmpty == true ? description : null,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form
        _formKey.currentState?.reset();
        
        // Navigate back to the previous screen
        Navigator.of(context).pop();
      }

      if (kDebugMode) {
        print('Expense saved: $merchant - ₹$amount in $category on ${DateFormat('yyyy-MM-dd').format(dateTime)}');
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (kDebugMode) {
        print('Error saving expense: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount'),
            const SizedBox(height: 5),
            FormBuilderTextField(
              name: 'amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.empty_wallet_outline),
                hintText: 'Enter amount',
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Amount is required'),
                FormBuilderValidators.numeric(
                  errorText: 'Please enter a valid number',
                ),
                FormBuilderValidators.min(
                  0.01,
                  errorText: 'Amount must be greater than zero',
                ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Merchant'),
            const SizedBox(height: 5),
            FormBuilderTextField(
              name: 'merchant',
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.shop_outline),
                hintText: 'Enter merchant name (e.g., Amazon, Zomato)',
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Merchant name is required'),
                FormBuilderValidators.maxLength(
                  100,
                  errorText: 'Merchant name cannot exceed 100 characters',
                ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Category'),
            const SizedBox(height: 5),
            FormBuilderChoiceChips<String>(
              name: 'category',
              spacing: 5,
              runSpacing: 5,
              validator: FormBuilderValidators.required(
                errorText: 'Please select a category',
              ),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              options: _categories
                  .map(
                    (category) => FormBuilderChipOption<String>(
                      value: category['value'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category['icon'], size: 16),
                          const SizedBox(width: 4),
                          Text(category['label']),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Date & Time'),
            const SizedBox(height: 5),
            FormBuilderDateTimePicker(
              name: 'datetime',
              inputType: InputType.both,
              initialValue: DateTime.now(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.calendar_edit_outline),
                hintText: 'Select date and time',
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Date & Time is required',
              ),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 20),
            const Text('Description (Optional)'),
            const SizedBox(height: 5),
            FormBuilderTextField(
              name: 'description',
              maxLines: 3,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.note_outline),
                hintText: 'Add a note about this expense (optional)',
              ),
              validator: FormBuilderValidators.maxLength(
                500,
                errorText: 'Description cannot exceed 500 characters',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              child: _isSubmitting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("Adding Expense..."),
                      ],
                    )
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
