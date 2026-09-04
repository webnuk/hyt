import '../../../core/utils/json_parsing.dart';
import 'tour_summary.dart';

class TourDay {
  const TourDay({required this.dayNumber, required this.title, required this.description});

  factory TourDay.fromJson(Map<String, dynamic> json) => TourDay(
        dayNumber: parseInt(json['day_number']),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );

  final int dayNumber;
  final String title;
  final String description;
}

class TourReview {
  const TourReview({required this.name, required this.rating, required this.comment, this.dateFormatted});

  factory TourReview.fromJson(Map<String, dynamic> json) => TourReview(
        name: json['name']?.toString().trim().isNotEmpty == true ? json['name'].toString() : 'Traveller',
        rating: parseInt(json['rating']),
        comment: json['comment']?.toString() ?? '',
        dateFormatted: json['created_at_formatted']?.toString(),
      );

  final String name;
  final int rating;
  final String comment;
  final String? dateFormatted;
}

/// Maps to the `data` object returned by GET /tours/{slug}.
class TourDetail {
  const TourDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.durationDays,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.currencySymbol,
    required this.featuredImage,
    required this.galleryImages,
    required this.includes,
    required this.averageRating,
    required this.reviewsCount,
    required this.tourTypeName,
    required this.locationNames,
    required this.days,
    required this.reviews,
    required this.relatedTours,
  });

  factory TourDetail.fromJson(Map<String, dynamic> data) {
    final tour = data['tour'] as Map<String, dynamic>? ?? const {};
    final images = (tour['tour_images'] as List? ?? const [])
        .map((e) => (e as Map)['image_path']?.toString())
        .whereType<String>()
        .toList();
    final locations = (tour['locations'] as List? ?? const [])
        .map((e) => (e as Map)['location_name']?.toString())
        .whereType<String>()
        .join(', ');
    final tourType = tour['tour_type'];

    return TourDetail(
      id: parseInt(tour['id']),
      name: tour['name']?.toString() ?? '',
      slug: tour['slug']?.toString() ?? '',
      durationDays: parseInt(tour['duration_days']),
      shortDescription: tour['short_description']?.toString() ?? '',
      description: tour['description']?.toString() ?? '',
      price: tour['price'] != null ? parseDouble(tour['price']) : parseDouble(tour['show_price']),
      currencySymbol: tour['currency_symbol']?.toString() ?? 'Nu.',
      featuredImage: tour['featured_image']?.toString() ?? (images.isNotEmpty ? images.first : ''),
      galleryImages: images,
      includes: (tour['includes'] as List? ?? const []).map((e) => e.toString()).toList(),
      averageRating: parseDouble(tour['average_rating']),
      reviewsCount: parseInt(tour['reviews_count']),
      tourTypeName: tourType is Map ? tourType['tour_type_name']?.toString() : null,
      locationNames: locations.isEmpty ? null : locations,
      days: (tour['tour_days'] as List? ?? const [])
          .map((e) => TourDay.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber)),
      reviews: (data['reviews'] as List? ?? const [])
          .map((e) => TourReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedTours: (data['related_tours'] as List? ?? const [])
          .map((e) => TourSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final String slug;
  final int durationDays;
  final String shortDescription;
  final String description;
  final double price;
  final String currencySymbol;
  final String featuredImage;
  final List<String> galleryImages;
  final List<String> includes;
  final double averageRating;
  final int reviewsCount;
  final String? tourTypeName;
  final String? locationNames;
  final List<TourDay> days;
  final List<TourReview> reviews;
  final List<TourSummary> relatedTours;
}
