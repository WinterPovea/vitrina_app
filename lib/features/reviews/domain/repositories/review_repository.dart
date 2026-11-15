import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getBySpecialist(String specialistId);

  /// Solo se puede reseñar un turno propio en estado `completed` (lo valida la BD).
  Future<Review> create({
    required String appointmentId,
    required String specialistId,
    required int rating,
    String? comment,
  });
}
