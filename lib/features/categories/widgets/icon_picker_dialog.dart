import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({
    super.key,
    this.selectedIcon,
  });

  final IconData? selectedIcon;

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  late IconData? _selectedIcon;
  String _searchQuery = '';

  // Curated list of commonly used icons from Iconsax
  final List<IconData> _icons = [
    // Finance & Money
    Iconsax.wallet_outline,
    Iconsax.money_outline,
    Iconsax.card_outline,
    Iconsax.dollar_circle_outline,
    Iconsax.coin_outline,
    
    // Food & Dining
    Iconsax.reserve_outline,
    Iconsax.coffee_outline,
    Iconsax.cake_outline,
    
    // Transportation
    Iconsax.car_outline,
    Iconsax.bus_outline,
    Iconsax.airplane_outline,
    Iconsax.ship_outline,
    Iconsax.gas_station_outline,
    
    // Shopping
    Iconsax.shopping_bag_outline,
    Iconsax.shopping_cart_outline,
    Iconsax.tag_outline,
    Iconsax.bag_outline,
    
    // Entertainment
    Iconsax.music_outline,
    Iconsax.video_play_outline,
    Iconsax.game_outline,
    Iconsax.ticket_outline,
    Iconsax.headphone_outline,
    
    // Healthcare
    Iconsax.health_outline,
    Iconsax.heart_outline,
    Iconsax.hospital_outline,
    Iconsax.activity_outline,
    
    // Work & Business
    Iconsax.briefcase_outline,
    Iconsax.shop_outline,
    Iconsax.code_outline,
    Iconsax.chart_outline,
    Iconsax.bank_outline,
    
    // Home & Living
    Iconsax.home_outline,
    Iconsax.lamp_outline,
    Iconsax.building_outline,
    Iconsax.electricity_outline,
    
    // Education
    Iconsax.book_outline,
    Iconsax.teacher_outline,
    Iconsax.award_outline,
    
    // Gifts & Others
    Iconsax.gift_outline,
    Iconsax.more_outline,
    Iconsax.star_outline,
    Iconsax.crown_outline,
    
    // Bills & Utilities
    Iconsax.receipt_outline,
    Iconsax.document_outline,
    Iconsax.receipt_item_outline,
    
    // Sports & Fitness
    Iconsax.weight_outline,
    Iconsax.flag_outline,
    
    // Pets & Animals
    Iconsax.pet_outline,
    
    // Beauty & Personal Care
    Iconsax.scissor_outline,
    Iconsax.brush_outline,
    
    // Communication
    Iconsax.call_outline,
    Iconsax.message_outline,
    Iconsax.sms_outline,
    
    // Technology
    Iconsax.mobile_outline,
    Iconsax.monitor_outline,
    Iconsax.wifi_outline,
    
    // Clothing
    Iconsax.shirt_outline,
    
    // Additional
    Iconsax.trend_up_outline,
    Iconsax.trend_down_outline,
    Iconsax.percentage_circle_outline,
    Iconsax.box_outline,
    Iconsax.category_outline,
    Iconsax.setting_outline,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  List<IconData> get _filteredIcons {
    if (_searchQuery.isEmpty) return _icons;
    // For simplicity, just return all icons when searching
    // In a real app, you might want to add icon names and filter by them
    return _icons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Icon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Iconsax.close_circle_outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search icons...',
                  prefixIcon: const Icon(Iconsax.search_normal_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Icons grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (context, index) {
                  final icon = _filteredIcons[index];
                  final isSelected = _selectedIcon?.codePoint == icon.codePoint;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedIcon == null
                        ? null
                        : () => Navigator.of(context).pop(_selectedIcon),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
