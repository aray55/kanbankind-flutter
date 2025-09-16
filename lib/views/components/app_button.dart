import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon ?? Icons.check),
      label: Text(label),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}