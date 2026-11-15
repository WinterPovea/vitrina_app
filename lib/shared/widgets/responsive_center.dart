import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Centra el contenido y limita su ancho: en horizontal o tablet no se estira ni desborda.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = AppSpacing.maxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}
