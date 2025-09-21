import 'package:flutter/material.dart';

class CardTitleText extends StatelessWidget {
  final String title;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;

  const CardTitleText({
    Key? key,
    required this.title,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
