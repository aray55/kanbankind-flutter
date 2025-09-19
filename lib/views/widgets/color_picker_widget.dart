import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

class ColorPickerWidget extends StatefulWidget {
  final String selectedColor;
  final Function(String) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  // Predefined board colors
  static const List<String> boardColors = [
    '#3498db', // Blue
    '#e74c3c', // Red
    '#2ecc71', // Green
    '#f39c12', // Orange
    '#9b59b6', // Purple
    '#1abc9c', // Turquoise
    '#34495e', // Dark Blue Gray
    '#e67e22', // Carrot
    '#f1c40f', // Yellow
    '#e91e63', // Pink
    '#795548', // Brown
    '#607d8b', // Blue Gray
    '#ff9800', // Deep Orange
    '#4caf50', // Light Green
    '#00bcd4', // Cyan
    '#673ab7', // Deep Purple
  ];

  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  void didUpdateWidget(covariant ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() {
        _selectedColor = widget.selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color preview and hex input
        _buildColorPreview(context),

        const SizedBox(height: 16),

        // Predefined colors grid
        _buildColorGrid(context),
      ],
    );
  }

  Widget _buildColorPreview(BuildContext context) {
    final color = _parseColor(_selectedColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Color preview circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Hex input field
          Expanded(
            child: TextFormField(
              initialValue: _selectedColor,
              decoration: InputDecoration(
                labelText: LocalKeys.hexColor.tr,
                hintText: '#RRGGBB',
                prefixText: '#',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                final hexColor = value.startsWith('#') ? value : '#$value';
                if (_isValidHexColor(hexColor)) {
                  setState(() {
                    _selectedColor = hexColor;
                  });
                  widget.onColorSelected(hexColor);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final hexColor = value.startsWith('#') ? value : '#$value';
                if (!_isValidHexColor(hexColor)) {
                  return 'Invalid hex color';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalKeys.quickColors.tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: boardColors.length,
          itemBuilder: (context, index) {
            final colorHex = boardColors[index];
            final color = _parseColor(colorHex);
            final isSelected =
                _selectedColor.toLowerCase() == colorHex.toLowerCase();

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorHex;
                });
                widget.onColorSelected(colorHex);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _getContrastColor(color),
                        size: 20,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final colorString = hexColor.replaceFirst('#', '');
      final colorValue = int.parse(colorString, radix: 16);

      if (colorString.length == 6) {
        return Color(0xFF000000 + colorValue);
      } else if (colorString.length == 8) {
        return Color(colorValue);
      } else if (colorString.length == 3) {
        // Convert RGB to RRGGBB
        final r = colorString[0];
        final g = colorString[1];
        final b = colorString[2];
        return Color(0xFF000000 + int.parse('$r$r$g$g$b$b', radix: 16));
      }
    } catch (e) {
      // Fallback to default color if parsing fails
    }

    return Theme.of(context).colorScheme.primary;
  }

  bool _isValidHexColor(String hexColor) {
    final regex = RegExp(r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    return regex.hasMatch(hexColor);
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // Return white for dark colors, black for light colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
