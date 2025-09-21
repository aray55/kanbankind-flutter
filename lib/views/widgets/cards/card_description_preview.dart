import 'package:flutter/material.dart';

class CardDescriptionPreview extends StatelessWidget {
  final String? description;
  final int maxLines;

  const CardDescriptionPreview({Key? key, this.description, this.maxLines = 2})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      description!,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
