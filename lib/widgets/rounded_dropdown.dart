import 'package:flutter/material.dart';

class RoundedDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? icon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? contentPadding;

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
        color: backgroundColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
          icon: icon ?? Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 18,
          ),
          iconSize: 18,
          elevation: 12,
          borderRadius: BorderRadius.circular(borderRadius),
          dropdownColor: colorScheme.surface,
          padding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          menuMaxHeight: 250,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          // Enhanced focus and hover states
          focusColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}