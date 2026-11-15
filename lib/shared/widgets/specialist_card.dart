import 'package:flutter/material.dart';

import '../../features/specialists/domain/entities/specialist.dart';
import 'avatar_image.dart';
import 'rating_badge.dart';

class SpecialistCard extends StatelessWidget {
  const SpecialistCard({super.key, required this.specialist, this.onTap});

  final Specialist specialist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarImage(name: specialist.displayName, url: specialist.avatarUrl, radius: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(specialist.displayName, style: theme.textTheme.titleMedium),
                    if (specialist.title != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        specialist.title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 8),
                    RatingBadge(rating: specialist.avgRating, count: specialist.reviewCount),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
