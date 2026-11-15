import 'package:flutter/material.dart';

/// Foto circular con respaldo a iniciales si no hay URL o falla la carga.
class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, required this.name, this.url, this.radius = 28});

  final String name;
  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final fallback = Container(
      width: radius * 2,
      height: radius * 2,
      color: scheme.secondary,
      alignment: Alignment.center,
      child: Text(initial, style: TextStyle(color: scheme.primary, fontSize: radius * 0.8, fontWeight: FontWeight.w600)),
    );
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: (url == null || url!.isEmpty)
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
              ),
      ),
    );
  }
}
