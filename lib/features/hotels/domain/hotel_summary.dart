import '../../../core/utils/json_parsing.dart';

/// Maps to HotelResource — the shape returned by GET /hotels and /hotels/search.
class HotelSummary {
  const HotelSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.location,
    required this.starRating,
    required this.price,
    required this.currencySymbol,
    required this.image,
    required this.reviewsCount,
  });

  factory HotelSummary.fromJson(Map<String, dynamic> json) {
    return HotelSummary(
      id: parseInt(json['id']),
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      starRating: parseInt(json['star_rating']),
      price: parseDouble(json['price']),
      currencySymbol: json['currency_symbol']?.toString() ?? 'Nu.',
      image: json['image']?.toString() ?? '',
      reviewsCount: parseInt(json['reviews_count']),
    );
  }

  final int id;
  final String slug;
  final String name;
  final String location;
  final int starRating;
  final double price;
  final String currencySymbol;
  final String image;
  final int reviewsCount;
}
