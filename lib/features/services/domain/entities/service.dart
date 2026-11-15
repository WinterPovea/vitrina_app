class Service {
  const Service({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.description,
    this.categoryId,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final int durationMinutes;

  /// Precio efectivo (si el especialista tiene precio propio, ya viene aplicado).
  final double price;
  final String? categoryId;
  final String? imageUrl;
}
