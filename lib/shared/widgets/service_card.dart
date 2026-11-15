import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../features/services/domain/entities/service.dart';

/// Tarjeta de servicio: nombre, duración, precio y acción "Agregar/Seleccionado".
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.selected = false,
    this.onSelect,
    this.currencySymbol = r'$',
  });

  final Service service;
  final bool selected;
  final VoidCallback? onSelect;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.duration(service.durationMinutes),
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (service.description != null) ...[
                    const SizedBox(height: 6),
                    Text(service.description!, style: theme.textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.price(service.price, symbol: currencySymbol),
                  style: theme.textTheme.headlineSmall?.copyWith(color: scheme.primary),
                ),
                if (onSelect != null) ...[
                  const SizedBox(height: 8),
                  selected
                      ? FilledButton.icon(
                          onPressed: onSelect,
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Elegido'),
                        )
                      : OutlinedButton(
                          onPressed: onSelect,
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                          child: const Text('+ Agregar'),
                        ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
