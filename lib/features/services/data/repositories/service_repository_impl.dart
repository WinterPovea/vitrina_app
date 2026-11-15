import '../../../../core/network/api_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<Category>> getCategories() => _api.guard(() async {
        final rows = await _api.client.from('categories').select().order('sort_order');
        return rows.map<Category>(CategoryModel.fromJson).toList();
      });

  @override
  Future<List<Service>> getServices({String? categoryId}) => _api.guard(() async {
        var builder = _api.client.from('services').select().eq('is_active', true);
        if (categoryId != null) builder = builder.eq('category_id', categoryId);
        final rows = await builder.order('name');
        return rows.map<Service>((r) => ServiceModel.fromJson(r)).toList();
      });

  @override
  Future<List<Service>> getServicesBySpecialist(String specialistId) => _api.guard(() async {
        final rows = await _api.client
            .from('specialist_services')
            .select('price_override, services(*)')
            .eq('specialist_id', specialistId);
        final result = <Service>[];
        for (final row in rows) {
          final svc = row['services'] as Map<String, dynamic>?;
          if (svc == null || svc['is_active'] != true) continue;
          result.add(ServiceModel.fromJson(
            svc,
            priceOverride: (row['price_override'] as num?)?.toDouble(),
          ));
        }
        return result;
      });
}
