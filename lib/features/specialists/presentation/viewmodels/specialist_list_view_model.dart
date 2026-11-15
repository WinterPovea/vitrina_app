import '../../../../core/state/base_view_model.dart';
import '../../domain/entities/specialist.dart';
import '../../domain/repositories/specialist_repository.dart';

/// ViewModel de referencia: así deben escribirse los demás.
/// Dependencia por constructor, sin SDK remoto, estados carga/datos/vacío/error.
class SpecialistListViewModel extends BaseViewModel {
  SpecialistListViewModel(this._repository);

  final SpecialistRepository _repository;

  List<Specialist> _specialists = const [];
  String _query = '';

  List<Specialist> get specialists => _specialists;
  String get query => _query;

  Future<void> load() async {
    setLoading();
    try {
      _specialists = await _repository.getSpecialists(query: _query);
      setLoaded(isEmpty: _specialists.isEmpty);
    } catch (e) {
      setFailed(e);
    }
  }

  Future<void> search(String query) {
    _query = query.trim();
    return load();
  }
}
