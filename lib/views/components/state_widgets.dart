import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3)),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ]
      ]),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = 'Nothing here yet', this.onRefresh, this.buttonText = 'Refresh'});
  final String message;
  final VoidCallback? onRefresh;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
        if (onRefresh != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(buttonText),
          ),
        ]
      ]),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ]),
      ),
    );
  }
}