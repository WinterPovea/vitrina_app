import '../../../../core/network/api_service.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../models/organization_model.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl(this._api, this._organizationId);

  final ApiService _api;
  final String _organizationId;

  @override
  Future<Organization> getCurrent() => _api.guard(() async {
        final row = await _api.client
            .from('organizations')
            .select()
            .eq('id', _organizationId)
            .single();
        return OrganizationModel.fromJson(row);
      });
}
