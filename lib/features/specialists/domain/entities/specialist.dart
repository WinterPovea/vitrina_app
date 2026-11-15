class Specialist {
  const Specialist({
    required this.id,
    required this.organizationId,
    required this.displayName,
    this.title,
    this.bio,
    this.avatarUrl,
    this.yearsExperience,
    this.phone,
    this.whatsapp,
    this.avgRating = 0,
    this.reviewCount = 0,
  });

  final String id;
  final String organizationId;
  final String displayName;
  final String? title;
  final String? bio;
  final String? avatarUrl;
  final int? yearsExperience;
  final String? phone;
  final String? whatsapp;
  final double avgRating;
  final int reviewCount;

  bool get hasReviews => reviewCount > 0;
}
