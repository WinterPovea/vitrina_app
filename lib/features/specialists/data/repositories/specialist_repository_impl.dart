import '../../../../core/network/api_service.dart';
import '../../domain/entities/specialist.dart';
import '../../domain/repositories/specialist_repository.dart';
import '../models/specialist_model.dart';

class SpecialistRepositoryImpl implements SpecialistRepository {
  SpecialistRepositoryImpl(this._api);

  final ApiService _api;

  // Se consulta la vista `specialist_overview` (especialista + promedio de reseñas).
  static const _view = 'specialist_overview';

  @override
  Future<List<Specialist>> getSpecialists({String? query}) => _api.guard(() async {
        var builder = _api.client.from(_view).select().eq('is_active', true);
        final q = query?.replaceAll(RegExp(r'[,()%*]'), ' ').trim();
        if (q != null && q.isNotEmpty) {
          builder = builder.or('display_name.ilike.%$q%,title.ilike.%$q%');
        }
        final rows = await builder.order('display_name');
        return rows.map<Specialist>(SpecialistModel.fromJson).toList();
      });

  @override
  Future<Specialist> getSpecialist(String id) => _api.guard(() async {
        final row = await _api.client.from(_view).select().eq('id', id).single();
        return SpecialistModel.fromJson(row);
      });
}
