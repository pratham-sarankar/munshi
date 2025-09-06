import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/transactions/services/transaction_service.dart';
import 'package:munshi/features/transactions/models/transaction.dart';
import 'package:intl/intl.dart';

/// Form widget for adding income transactions.
/// 
/// This widget provides a user-friendly interface for entering income
/// transaction details including amount, source, category, date/time,
/// and optional description. It validates input and saves the transaction
/// to the database using the TransactionService.
class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});
  
  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  
  /// Transaction service for database operations
  late final TransactionService _transactionService;
  
  /// Flag to track form submission state
  bool _isSubmitting = false;

  /// Available income categories with their display information
  final List<Map<String, dynamic>> _incomeCategories = [
    {'value': 'Salary', 'label': 'Salary', 'icon': Iconsax.briefcase_outline},
    {'value': 'Freelance', 'label': 'Freelance', 'icon': Iconsax.code_outline},
    {'value': 'Business', 'label': 'Business', 'icon': Iconsax.shop_outline},
    {
      'value': 'Investment',
      'label': 'Investment',
      'icon': Iconsax.chart_outline,
    },
    {'value': 'Rental', 'label': 'Rental', 'icon': Iconsax.home_outline},
    {'value': 'Bonus', 'label': 'Bonus', 'icon': Iconsax.gift_outline},
    {'value': 'Interest', 'label': 'Interest', 'icon': Iconsax.percentage_square_outline},
    {'value': 'Dividend', 'label': 'Dividend', 'icon': Iconsax.trending_up_outline},
    {'value': 'Gift', 'label': 'Gift', 'icon': Iconsax.gift_outline},
    {'value': 'Other', 'label': 'Other', 'icon': Iconsax.more_outline},
  ];

  @override
  void initState() {
    super.initState();
    _transactionService = locator<TransactionService>();
  }

  /// Submits the income form and saves the transaction to the database.
  /// 
  /// Validates the form data, creates a new income transaction,
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
      final source = formData['source']?.toString() ?? '';
      final category = formData['category']?.toString() ?? '';
      final dateTime = formData['datetime'] as DateTime? ?? DateTime.now();
      final description = formData['description']?.toString();

      // Validate required fields
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      if (source.isEmpty) {
        throw Exception('Income source is required');
      }
      if (category.isEmpty) {
        throw Exception('Category is required');
      }

      // Format time for storage
      final timeString = DateFormat('h:mm a').format(dateTime);

      // Create the income transaction (amount is stored as positive for income)
      await _transactionService.addTransaction(
        merchant: source,
        amount: amount, // Positive amount for income
        date: dateTime,
        time: timeString,
        category: category,
        isIncome: true,
        description: description?.isNotEmpty == true ? description : null,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form
        _formKey.currentState?.reset();
        
        // Navigate back to the previous screen
        Navigator.of(context).pop();
      }

      if (kDebugMode) {
        print('Income saved: $source - ₹$amount in $category on ${DateFormat('yyyy-MM-dd').format(dateTime)}');
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add income: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (kDebugMode) {
        print('Error saving income: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
                prefixIcon: Icon(Iconsax.wallet_outline),
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
            const Text('Income Source'),
            const SizedBox(height: 5),
            FormBuilderTextField(
              name: 'source',
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.building_outline),
                hintText: 'Enter income source (e.g., Company Name, Client)',
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Income source is required'),
                FormBuilderValidators.maxLength(
                  100,
                  errorText: 'Source name cannot exceed 100 characters',
                ),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Income Category'),
            const SizedBox(height: 5),
            FormBuilderChoiceChips<String>(
              name: 'category',
              spacing: 5,
              runSpacing: 5,
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Please select a category',
              ),
              options: _incomeCategories
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
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ),
            const SizedBox(height: 20),
            const Text('Description (Optional)'),
            const SizedBox(height: 5),
            FormBuilderTextField(
              name: 'description',
              maxLines: 3,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.note_outline),
                hintText: 'Add a description...',
                alignLabelWithHint: true,
              ),
              validator: FormBuilderValidators.maxLength(
                200,
                errorText: 'Description too long',
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
                        Text("Adding Income..."),
                      ],
                    )
                  : const Text("Submit"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
