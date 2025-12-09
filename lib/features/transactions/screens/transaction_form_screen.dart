import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/receipt/models/ai_receipt_data.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:munshi/features/transactions/models/transaction_with_category.dart';
import 'package:munshi/features/transactions/widgets/form_builder_category_chips.dart';
import 'package:munshi/widgets/shimmer_loading.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    required this.onSubmit,
    super.key,
    this.transaction,
    this.aiProcessingFuture,
  });
  final TransactionWithCategory? transaction;
  final void Function(drift.Insertable<Transaction> transaction) onSubmit;

  /// Optional future that processes AI receipt data
  /// When provided, the form will show shimmer loading and auto-fill on completion
  final Future<AIReceiptData?>? aiProcessingFuture;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GlobalKey<FormBuilderState> _formKey;

  // AI processing state
  bool _isAIProcessing = false;
  AIReceiptData? _aiResult;

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

    // Start AI processing if future is provided
    if (widget.aiProcessingFuture != null) {
      _processAIData();
    }
  }

  Future<void> _processAIData() async {
    setState(() {
      _isAIProcessing = true;
    });

    try {
      final result = await widget.aiProcessingFuture;
      if (result != null && mounted) {
        setState(() {
          _aiResult = result;
          _isAIProcessing = false;
        });
      } else if (mounted) {
        setState(() {
          _isAIProcessing = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _isAIProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process receipt. Please fill manually.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Iconsax.arrow_left_outline),
        ),
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        label: Text(widget.transaction != null ? 'Update' : 'Save'),
        icon: Icon(
          widget.transaction != null
              ? Iconsax.tick_circle_bold
              : Iconsax.save_2_bold,
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Processing Indicator
                if (_isAIProcessing) const AIProcessingIndicator(),

                const Text('Amount'),
                const SizedBox(height: 5),
                if (_isAIProcessing)
                  const ShimmerPlaceholder()
                else
                  FormBuilderTextField(
                    name: 'amount',
                    autofocus: true,
                    initialValue:
                        _aiResult?.amount?.toString() ??
                        widget.transaction?.amount.toString(),
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
                        ? 'expense_category'
                        : 'income_category',
                    type: _tabController.index == 0
                        ? TransactionType.expense
                        : TransactionType.income,
                    initialValue:
                        _aiResult?.category ?? widget.transaction?.category,
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Date & Time'),
                const SizedBox(height: 5),
                if (_isAIProcessing)
                  const ShimmerPlaceholder()
                else
                  FormBuilderDateTimePicker(
                    name: 'datetime',
                    format: DateFormat('d MMM, h:mm a'),
                    initialValue:
                        _aiResult?.dateTime ??
                        widget.transaction?.date ??
                        DateTime.now(),
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
                if (_isAIProcessing)
                  const ShimmerPlaceholder(height: 88)
                else
                  FormBuilderTextField(
                    name: 'description',
                    initialValue: _aiResult?.description.isNotEmpty == true
                        ? _aiResult!.description
                        : widget.transaction?.note,
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
                const SizedBox(height: 80), // Extra space to account for FAB
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
      final amount = double.parse(formData['amount'] as String);
      final category =
          (type == TransactionType.expense
                  ? formData['expense_category']
                  : formData['income_category'])
              as TransactionCategory?;
      final datetime = formData['datetime'] as DateTime;
      final description = formData['description'] as String?;

      final transaction = widget.transaction != null
          ? TransactionsCompanion(
              id: drift.Value(
                widget.transaction!.id,
              ), // Keep existing ID for updates
              amount: drift.Value(amount),
              categoryId: category != null
                  ? drift.Value(category.id)
                  : const drift.Value(
                      null,
                    ), // Explicitly set to null for updates
              type: drift.Value(type),
              date: drift.Value(datetime),
              note: drift.Value(description),
            )
          : TransactionsCompanion(
              amount: drift.Value(amount),
              categoryId: category != null
                  ? drift.Value(category.id)
                  : const drift.Value(null), // Use absent for new transactions
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
