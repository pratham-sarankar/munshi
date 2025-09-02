import 'package:flutter/material.dart';

/// A custom dropdown widget with rounded corners for enhanced UI design.
///
/// This widget wraps Flutter's standard [DropdownButton] with a rounded
/// container that provides modern styling while maintaining full functionality.
class RoundedDropdown<T> extends StatelessWidget {
  /// The currently selected value for the dropdown.
  final T? value;

  /// The list of items to display in the dropdown menu.
  final List<DropdownMenuItem<T>> items;

  /// Callback function triggered when a new value is selected.
  final ValueChanged<T?>? onChanged;

  /// Custom icon widget for the dropdown. Defaults to a rounded arrow down icon.
  final Widget? icon;

  /// Border radius for both the container and dropdown menu. Defaults to 12.0.
  final double borderRadius;

  /// Background color for the dropdown container. Defaults to theme surface color.
  final Color? backgroundColor;

  /// Border color for the dropdown container. Defaults to theme outline color.
  final Color? borderColor;

  /// Padding inside the dropdown container.
  final EdgeInsetsGeometry? contentPadding;

  /// Creates a rounded dropdown with customizable styling.
  const RoundedDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon:
              icon ??
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 18,
              ),
          iconSize: 18,
          elevation: 12,
          borderRadius: BorderRadius.circular(borderRadius),
          dropdownColor: colorScheme.surface,
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          menuMaxHeight: 250,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          focusColor: colorScheme.primary.withValues(alpha: 0.1),
          isExpanded: false,
          isDense: true,
        ),
      ),
    );
  }
}
