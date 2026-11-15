import '../entities/organization.dart';

abstract class OrganizationRepository {
  /// Datos de la organización a la que pertenece esta app.
  Future<Organization> getCurrent();
}
