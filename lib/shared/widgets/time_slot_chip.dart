import 'package:flutter/material.dart';

import '../../core/config/brand.dart';

/// Hora seleccionable. Seleccionada = aro dorado; deshabilitada = tachada.
class TimeSlotChip extends StatelessWidget {
  const TimeSlotChip({super.key, required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: 'Horario $label',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Brand.tertiary : Brand.secondary,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: enabled ? Brand.foreground : Brand.disabled,
              decoration: enabled ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}
