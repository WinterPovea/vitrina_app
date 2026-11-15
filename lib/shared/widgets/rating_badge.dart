import 'package:flutter/material.dart';

/// Estrella dorada + promedio + cantidad de reseñas. Sin reseñas muestra "Nuevo".
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (count == 0) {
      return Text('Nuevo', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.tertiary));
    }
    return Semantics(
      label: 'Calificación $rating de 5, $count reseñas',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 18, color: theme.colorScheme.tertiary),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1), style: theme.textTheme.labelLarge),
          const SizedBox(width: 4),
          Text('($count)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
