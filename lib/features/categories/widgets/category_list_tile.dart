import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';

class CategoryListTile extends StatefulWidget {
  const CategoryListTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final TransactionCategory category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<CategoryListTile> createState() => _CategoryListTileState();
}

class _CategoryListTileState extends State<CategoryListTile>
    with SingleTickerProviderStateMixin {
  late final SlidableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = widget.category.color;

    return Slidable(
      controller: _controller,
      key: ValueKey(widget.category.id),
      groupTag: 'categories',
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => widget.onTap(),
            backgroundColor: colorScheme.inverseSurface,
            foregroundColor: colorScheme.onInverseSurface,
            icon: Iconsax.edit_outline,
            label: 'Edit',
          ),
          if (!widget.category.isDefault)
            SlidableAction(
              onPressed: (context) => widget.onDelete(),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Iconsax.trash_outline,
              label: 'Delete',
            ),
        ],
      ),
      child: ListTile(
        onTap: widget.onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.category.icon, color: categoryColor, size: 22),
        ),
        title: Text(
          widget.category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: widget.category.isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Default',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
