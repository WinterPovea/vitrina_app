import 'package:flutter/material.dart';

import '../../core/state/base_view_model.dart';

/// Pinta los 4 estados obligatorios: cargando, datos, vacío y error (con "Reintentar").
/// Úsalo en TODA pantalla que lea datos remotos.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.status,
    required this.dataBuilder,
    this.errorMessage,
    this.canRetry = true,
    this.onRetry,
    this.emptyMessage = 'Aún no hay nada por aquí.',
    this.emptyIcon = Icons.inbox_outlined,
  });

  final ViewStatus status;
  final WidgetBuilder dataBuilder;
  final String? errorMessage;
  final bool canRetry;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ViewStatus.idle:
      case ViewStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewStatus.error:
        return _Message(
          icon: canRetry ? Icons.wifi_off_rounded : Icons.error_outline,
          text: errorMessage ?? 'Ocurrió un error inesperado.',
          actionLabel: canRetry && onRetry != null ? 'Reintentar' : null,
          onAction: onRetry,
        );
      case ViewStatus.empty:
        return _Message(icon: emptyIcon, text: emptyMessage);
      case ViewStatus.data:
        return dataBuilder(context);
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.actionLabel, this.onAction});

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
