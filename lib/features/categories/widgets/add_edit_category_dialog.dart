import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/categories/widgets/color_picker_dialog.dart';
import 'package:munshi/features/categories/widgets/icon_picker_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class AddEditCategoryDialog extends StatefulWidget {
  const AddEditCategoryDialog({super.key, required this.type, this.category});

  final String type; // 'expense' or 'income'
  final Category? category;

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late IconData _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = IconData(
        widget.category!.iconCodePoint,
        fontFamily: widget.category!.iconFontFamily,
        fontPackage: widget.category!.iconFontPackage,
      );
      _selectedColor = Color(widget.category!.colorValue);
    } else {
      _selectedIcon = Iconsax.category_outline;
      _selectedColor = Colors.blue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectIcon() async {
    final icon = await showDialog<IconData>(
      context: context,
      builder: (context) => IconPickerDialog(selectedIcon: _selectedIcon),
    );
    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  Future<void> _selectColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(selectedColor: _selectedColor),
    );
    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<CategoryProvider>();
    final name = _nameController.text.trim();

    // Check if name already exists
    final nameExists = await provider.categoryNameExists(
      name,
      widget.type,
      excludeId: widget.category?.id,
    );

    if (nameExists && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A category with this name already exists'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      if (widget.category != null) {
        // Update existing category
        final updatedCategory = widget.category!.copyWith(
          name: name,
          iconCodePoint: _selectedIcon.codePoint,
          iconFontFamily: drift.Value(_selectedIcon.fontFamily),
          iconFontPackage: drift.Value(_selectedIcon.fontPackage),
          colorValue: _selectedColor.value,
        );
        await provider.updateCategory(updatedCategory);
      } else {
        // Add new category
        final newCategory = CategoriesCompanion.insert(
          name: name,
          iconCodePoint: _selectedIcon.codePoint,
          iconFontFamily: drift.Value(_selectedIcon.fontFamily),
          iconFontPackage: drift.Value(_selectedIcon.fontPackage),
          colorValue: _selectedColor.value,
          type: widget.type,
        );
        await provider.addCategory(newCategory);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.category != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Category' : 'Add Category',
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

            // Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'Enter category name',
                        prefixIcon: const Icon(Iconsax.text_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Icon selector
                    InkWell(
                      onTap: _selectIcon,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _selectedColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_selectedIcon, color: _selectedColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Select Icon',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color selector
                    InkWell(
                      onTap: _selectColor,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Select Color',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveCategory,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
