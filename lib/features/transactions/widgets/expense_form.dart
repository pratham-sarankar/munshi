import 'package:drift/drift.dart' show Insertable, Value;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, required this.onSubmit, this.transaction});
  final Function(Insertable<Transaction> transaction) onSubmit;
  final Transaction? transaction;
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    _formKey = GlobalKey<FormBuilderState>();

    super.initState();
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
              valueTransformer: (value) {
                return double.parse(value!);
              },
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
            const Text('Category'),
            const SizedBox(height: 5),
            FormBuilderChoiceChips<TransactionCategory>(
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
              options: expenseCategories
                  .map(
                    (category) => FormBuilderChipOption<TransactionCategory>(
                      value: category,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 16),
                          const SizedBox(width: 4),
                          Text(category.name),
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
            FilledButton(
              onPressed: _submitForm,
              style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    try {
      if (_formKey.currentState?.saveAndValidate() ?? false) {
        // Form is valid, get the values
        final formData = _formKey.currentState!.value;

        // Submit the form data
        await widget.onSubmit(
          TransactionsCompanion(
            amount: Value(formData['amount']),
            category: Value(formData['category']),
            date: Value(formData['datetime']),
            type: Value(TransactionType.expense),
          ),
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors in the form'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }
}
