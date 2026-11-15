import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] as String,
          specialistId: json['specialist_id'] as String,
          rating: json['rating'] as int,
          createdAt: DateTime.parse(json['created_at'] as String),
          authorName: json['author_name'] as String?,
          comment: json['comment'] as String?,
        );
}
