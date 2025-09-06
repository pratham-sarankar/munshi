import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'food_dining',
      'label': 'Food & Dining',
      'icon': Iconsax.reserve_outline,
    },
    {
      'value': 'transportation',
      'label': 'Transportation',
      'icon': Iconsax.car_outline,
    },
    {
      'value': 'shopping',
      'label': 'Shopping',
      'icon': Iconsax.shopping_bag_outline,
    },
    {
      'value': 'entertainment',
      'label': 'Entertainment',
      'icon': Iconsax.music_outline,
    },
    {
      'value': 'healthcare',
      'label': 'Healthcare',
      'icon': Iconsax.health_outline,
    },
  ];

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Form is valid, get the values
      final formData = _formKey.currentState!.value;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Process the form data
      print('Form Data: $formData');
      print('Amount: ${formData['amount']}');
      print('Category: ${formData['category']}');
      print('DateTime: ${formData['datetime']}');
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
}
