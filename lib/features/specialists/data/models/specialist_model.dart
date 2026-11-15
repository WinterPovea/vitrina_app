import '../../domain/entities/specialist.dart';

class SpecialistModel extends Specialist {
  SpecialistModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] as String,
          organizationId: json['organization_id'] as String,
          displayName: json['display_name'] as String,
          title: json['title'] as String?,
          bio: json['bio'] as String?,
          avatarUrl: json['avatar_url'] as String?,
          yearsExperience: json['years_experience'] as int?,
          phone: json['phone'] as String?,
          whatsapp: json['whatsapp'] as String?,
          avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
          reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
        );
}
