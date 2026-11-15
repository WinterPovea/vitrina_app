import '../entities/specialist.dart';

abstract class SpecialistRepository {
  /// Lista especialistas activos; [query] filtra por nombre o título.
  Future<List<Specialist>> getSpecialists({String? query});

  Future<Specialist> getSpecialist(String id);
}
