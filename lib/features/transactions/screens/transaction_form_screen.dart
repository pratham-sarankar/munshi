import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:munshi/features/transactions/widgets/form_builder_category_chips.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.onSubmit,
    this.transaction,
  });
  final Transaction? transaction;
  final Function(drift.Insertable<Transaction> transaction) onSubmit;
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GlobalKey<FormBuilderState> _formKey;

  @override
  void initState() {
    super.initState();
    // Set initial tab based on transaction type when editing
    final initialTabIndex = widget.transaction?.type == TransactionType.income
        ? 1
        : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTabIndex,
    )..addListener(() => setState(() {}));
    _formKey = GlobalKey<FormBuilderState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Iconsax.arrow_left_outline),
        ),
        title: Text(
          widget.transaction != null ? "Edit Transaction" : "Add Transaction",
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Expense"),
            Tab(text: "Income"),
          ],
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount'),
                const SizedBox(height: 5),
                FormBuilderTextField(
                  name: 'amount',
                  initialValue: widget.transaction?.amount.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.wallet_outline),
                    hintText: 'Enter amount',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Amount is required',
                    ),
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
                Text(
                  _tabController.index == 0
                      ? 'Expense Category'
                      : 'Income Category',
                ),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: FormBuilderCategoryChips(
                    key: ValueKey(_tabController.index),
                    name: _tabController.index == 0
                        ? "expense_category"
                        : "income_category",
                    type: _tabController.index == 0
                        ? TransactionType.expense
                        : TransactionType.income,
                    initialValue: widget.transaction?.category,
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Date & Time'),
                const SizedBox(height: 5),
                FormBuilderDateTimePicker(
                  name: 'datetime',
                  format: DateFormat('d MMM, h:mm a'),
                  inputType: InputType.both,
                  initialValue: widget.transaction?.date ?? DateTime.now(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.calendar_edit_outline),
                    hintText: 'Select date and time',
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Date & Time is required',
                  ),
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 365 * 2),
                  ),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
                const SizedBox(height: 20),
                const Text('Description (Optional)'),
                const SizedBox(height: 5),
                FormBuilderTextField(
                  name: 'description',
                  initialValue: widget.transaction?.note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.note_outline),
                    hintText: 'Add a description...',
                    alignLabelWithHint: true,
                  ),
                  validator: FormBuilderValidators.maxLength(
                    200,
                    errorText: 'Description too long',
                    checkNullOrEmpty: false,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submitForm,
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(double.infinity, 50),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Text(widget.transaction != null ? "Update" : "Submit"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final type = _tabController.index == 0
          ? TransactionType.expense
          : TransactionType.income;
      final amount = double.parse(formData['amount']);
      final category = type == TransactionType.expense
          ? formData['expense_category']
          : formData['income_category'];
      final datetime = formData['datetime'] as DateTime;
      final description = formData['description'] as String?;

      final transaction = widget.transaction != null
          ? TransactionsCompanion(
              id: drift.Value(
                widget.transaction!.id,
              ), // Keep existing ID for updates
              amount: drift.Value(amount),
              category: drift.Value(category),
              type: drift.Value(type),
              date: drift.Value(datetime),
              note: drift.Value(description),
            )
          : TransactionsCompanion(
              amount: drift.Value(amount),
              category: drift.Value(category),
              type: drift.Value(type),
              date: drift.Value(datetime),
              note: drift.Value(description),
            );

      widget.onSubmit(transaction);
      Navigator.of(context).pop();
    } else {
      // Handle validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form properly.')),
      );
    }
  }
}
