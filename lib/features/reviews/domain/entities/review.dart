class Review {
  const Review({
    required this.id,
    required this.specialistId,
    required this.rating,
    required this.createdAt,
    this.authorName,
    this.comment,
  });

  final String id;
  final String specialistId;
  final int rating; // 1..5
  final DateTime createdAt;
  final String? authorName;
  final String? comment;
}
