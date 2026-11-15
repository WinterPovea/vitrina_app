import 'package:flutter/material.dart';

/// Chip de filtro (categorías). Activo = burgundy con texto blanco.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({super.key, required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
