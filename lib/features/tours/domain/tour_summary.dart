import '../../../core/utils/json_parsing.dart';

/// Maps to TourResource — the shape returned by GET /tours, /tours/search,
/// and inside a tour-detail response's `related_tours`.
class TourSummary {
  const TourSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.currencySymbol,
    required this.featuredImage,
    required this.averageRating,
    required this.reviewsCount,
    this.tourTypeName,
    this.locationNames,
  });

  /// Handles two slightly different shapes: TourResource (used by /tours,
  /// /tours/search — has price/currency_symbol/tour_type_name flat) and the
  /// leaner `related_tours` shape inside a tour-detail response (raw
  /// show_price, nested tour_type object, no currency_symbol).
  factory TourSummary.fromJson(Map<String, dynamic> json) {
    final tourType = json['tour_type'];
    return TourSummary(
      id: parseInt(json['id']),
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tourTypeName: json['tour_type_name']?.toString() ??
          (tourType is Map ? tourType['tour_type_name']?.toString() : null),
      durationDays: parseInt(json['duration_days']),
      price: json['price'] != null ? parseDouble(json['price']) : parseDouble(json['show_price']),
      currencySymbol: json['currency_symbol']?.toString() ?? 'Nu.',
      featuredImage: json['featured_image']?.toString() ?? '',
      locationNames: json['location_names']?.toString(),
      averageRating: parseDouble(json['average_rating']),
      reviewsCount: parseInt(json['reviews_count']),
    );
  }

  final int id;
  final String slug;
  final String name;
  final String? tourTypeName;
  final int durationDays;
  final double price;
  final String currencySymbol;
  final String featuredImage;
  final String? locationNames;
  final double averageRating;
  final int reviewsCount;
}
