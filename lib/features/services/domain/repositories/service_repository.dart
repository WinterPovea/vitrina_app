import '../entities/category.dart';
import '../entities/service.dart';

abstract class ServiceRepository {
  Future<List<Category>> getCategories();

  /// Catálogo completo de la organización (opcionalmente por categoría).
  Future<List<Service>> getServices({String? categoryId});

  /// Servicios que ofrece un especialista, con su precio propio si lo tiene.
  Future<List<Service>> getServicesBySpecialist(String specialistId);
}
