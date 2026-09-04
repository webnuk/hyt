import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/price_tag.dart';
import '../../domain/hotel_summary.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({super.key, required this.hotel, this.width});

  final HotelSummary hotel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push('/hotels/${hotel.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: hotel.image.isEmpty
                    ? Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported))
                    : CachedNetworkImage(
                        imageUrl: hotel.image,
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
                    Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    if (hotel.starRating > 0)
                      Row(
                        children: List.generate(
                          hotel.starRating,
                          (_) => const Icon(Icons.star, size: 13, color: Color(0xFFF5B301)),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            hotel.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PriceTag(amount: hotel.price, currencySymbol: hotel.currencySymbol, suffix: '/ night'),
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
