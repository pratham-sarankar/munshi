import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});
  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final List<Map<String, dynamic>> _incomeCategories = [
    {'value': 'salary', 'label': 'Salary', 'icon': Iconsax.briefcase_outline},
    {'value': 'freelance', 'label': 'Freelance', 'icon': Iconsax.code_outline},
    {'value': 'business', 'label': 'Business', 'icon': Iconsax.shop_outline},
    {
      'value': 'investment',
      'label': 'Investment',
      'icon': Iconsax.chart_outline,
    },
    {'value': 'rental', 'label': 'Rental', 'icon': Iconsax.home_outline},
    {'value': 'bonus', 'label': 'Bonus', 'icon': Iconsax.gift_outline},
    {'value': 'other', 'label': 'Other', 'icon': Iconsax.more_outline},
  ];

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Form is valid, get the values
      final formData = _formKey.currentState!.value;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Income submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Process the form data
      if (kDebugMode) {
        print('Form Data: $formData');
        print('Amount: ${formData['amount']}');
        print('Category: ${formData['category']}');
        print('Frequency: ${formData['frequency']}');
        print('DateTime: ${formData['datetime']}');
        print('Description: ${formData['description']}');
        print('Is Taxable: ${formData['is_taxable']}');
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
