import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, this.selectedColor});

  final Color? selectedColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  // Predefined color palette
  final List<Color> _colors = [
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Color',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Color preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Colors grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedColor),
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
