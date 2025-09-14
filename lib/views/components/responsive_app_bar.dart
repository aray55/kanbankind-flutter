import 'package:flutter/material.dart';
import 'package:kanbankit/views/components/responsive_text.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Mobile layout
        if (screenWidth < 600) {
          return AppBar(
            leading: leading,
            title: ResponsiveText(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: actions,
            elevation: elevation ?? 0,
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
          );
        }
        // Tablet/Desktop layout
        else {
          return AppBar(
            leading: leading,
            title: ResponsiveText(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            actions: actions,
            elevation: elevation ?? 0,
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
            centerTitle: false, // Align title to the left on larger screens
            toolbarHeight: 65, // A bit taller for larger screens
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
