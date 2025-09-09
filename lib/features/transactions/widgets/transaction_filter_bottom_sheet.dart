import 'package:flutter/material.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  const TransactionFilterBottomSheet({super.key});

  @override
  State<TransactionFilterBottomSheet> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<TransactionFilterBottomSheet> {
  final List<String> _timeframeOptions = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  String _selectedTimeframe = 'This Month';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Sort',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Time Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _timeframeOptions.map((timeframe) {
              final isSelected = _selectedTimeframe == timeframe;
              return FilterChip(
                label: Text(timeframe),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTimeframe = timeframe);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
