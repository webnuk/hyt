import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/price_tag.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../domain/tour_summary.dart';

class TourCard extends StatelessWidget {
  const TourCard({super.key, required this.tour, this.width});

  final TourSummary tour;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push('/tours/${tour.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: tour.featuredImage.isEmpty
                    ? Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported))
                    : CachedNetworkImage(
                        imageUrl: tour.featuredImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tour.tourTypeName != null)
                      Text(
                        tour.tourTypeName!.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      tour.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${tour.durationDays} days', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                    if (tour.reviewsCount > 0) ...[
                      const SizedBox(height: 4),
                      RatingStars(rating: tour.averageRating, reviewsCount: tour.reviewsCount),
                    ],
                    const SizedBox(height: 8),
                    PriceTag(amount: tour.price, currencySymbol: tour.currencySymbol, suffix: '/ person'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
