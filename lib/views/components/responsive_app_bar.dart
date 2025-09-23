import 'package:flutter/material.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';


class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;
  final bool showLogo;
  final double? logoSize;
  final PreferredSizeWidget? bottom;
  final TextOverflow overflow;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.elevation,
    this.backgroundColor,
    this.showLogo = true,
    this.logoSize,
    this.bottom,
    this.overflow = TextOverflow.ellipsis,
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
            title: _buildTitleWithLogo(context, true, overflow),
            actions: actions,
            elevation: elevation ?? 0,
            centerTitle: true,
            bottom: bottom,
            
          );
        }
        // Tablet/Desktop layout
        else {
          return AppBar(
            leading: leading,
            title: _buildTitleWithLogo(context, false, overflow),
            actions: actions,
            elevation: elevation ?? 0,
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.surface,
            centerTitle: false, // Align title to the left on larger screens
            toolbarHeight: 65, // A bit taller for larger screens
            bottom: bottom,
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildTitleWithLogo(BuildContext context, bool isMobile,  overflow) {
    if (!showLogo) {
      return AppText(
        title,
        variant: AppTextVariant.h1,
        overflow: overflow,
      );
    }

    final double logoSizeValue = logoSize ?? (isMobile ? 28 : 32);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/app_logo.png',
          height: logoSizeValue,
          width: logoSizeValue,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Icon(
              Icons.dashboard,
              size: logoSizeValue,
              color: Theme.of(context).colorScheme.primary,
            );
          },
        ),
        const SizedBox(width: 8),
        AppText(
          title,
          variant: AppTextVariant.h1,
          overflow: overflow,
        ),
      ],
    );
  }
}
