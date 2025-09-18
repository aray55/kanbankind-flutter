import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? customText;
  final MainAxisAlignment alignment;
  final bool isHero;
  
  const AppLogo({
    super.key,
    this.size = 48,
    this.showText = false,
    this.customText,
    this.alignment = MainAxisAlignment.center,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = Image.asset(
      'assets/images/app_logo.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Icon(
          Icons.dashboard_rounded,
          size: size,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );

    if (isHero) {
      logoWidget = Hero(
        tag: 'app_logo',
        child: logoWidget,
      );
    }

    if (!showText) {
      return logoWidget;
    }

    return Column(
      mainAxisAlignment: alignment,
      children: [
        logoWidget,
        const SizedBox(height: 12),
        Text(
          customText ?? 'KanbanKit',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organize your tasks efficiently',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}