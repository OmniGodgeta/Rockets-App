import 'package:flutter/material.dart';
import '../../app/theme.dart';

class LoadingOrErrorWrapper extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final Widget child;
  final String errorText;

  const LoadingOrErrorWrapper({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.child,
    this.errorText = 'Something went wrong.',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              errorText,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('RETRY')),
          ],
        ),
      );
    }

    return child;
  }
}
