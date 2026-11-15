import '../../domain/entities/category.dart';
import '../../domain/entities/service.dart';

class ServiceModel extends Service {
  ServiceModel.fromJson(Map<String, dynamic> json, {double? priceOverride})
      : super(
          id: json['id'] as String,
          name: json['name'] as String,
          description: json['description'] as String?,
          durationMinutes: json['duration_minutes'] as int,
          price: priceOverride ?? (json['price'] as num).toDouble(),
          categoryId: json['category_id'] as String?,
          imageUrl: json['image_url'] as String?,
        );
}

class CategoryModel extends Category {
  CategoryModel.fromJson(Map<String, dynamic> json)
      : super(id: json['id'] as String, name: json['name'] as String);
}
