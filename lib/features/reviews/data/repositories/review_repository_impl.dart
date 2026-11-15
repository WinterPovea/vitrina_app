import '../../../../core/network/api_service.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<Review>> getBySpecialist(String specialistId) => _api.guard(() async {
        final rows = await _api.client
            .from('reviews')
            .select()
            .eq('specialist_id', specialistId)
            .order('created_at', ascending: false);
        return rows.map<Review>(ReviewModel.fromJson).toList();
      });

  @override
  Future<Review> create({
    required String appointmentId,
    required String specialistId,
    required int rating,
    String? comment,
  }) =>
      _api.guard(() async {
        final row = await _api.client
            .from('reviews')
            .insert({
              'appointment_id': appointmentId,
              'specialist_id': specialistId,
              'rating': rating,
              if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
            })
            .select()
            .single();
        return ReviewModel.fromJson(row);
      });
}
