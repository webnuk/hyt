import '../../../core/utils/json_parsing.dart';

class HotelRoom {
  const HotelRoom({
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.currencySymbol,
    required this.image,
    required this.maxAdults,
    required this.maxChildren,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) => HotelRoom(
        name: json['name']?.toString() ?? 'Room',
        description: json['description']?.toString() ?? '',
        pricePerNight: parseDouble(json['pricePerNight']),
        currencySymbol: json['currency_symbol']?.toString() ?? 'Nu.',
        image: json['image']?.toString() ?? '',
        maxAdults: parseInt(json['maxAdults']),
        maxChildren: parseInt(json['maxChildren']),
      );

  final String name;
  final String description;
  final double pricePerNight;
  final String currencySymbol;
  final String image;
  final int maxAdults;
  final int maxChildren;
}

/// Maps to the `data` object returned by GET /hotels/{slug}.
class HotelDetail {
  const HotelDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.starRating,
    required this.address,
    required this.location,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
    required this.minPrice,
    required this.currencySymbol,
    required this.images,
    required this.rooms,
    required this.cancellationPolicy,
  });

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    return HotelDetail(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      starRating: parseInt(json['starRating']),
      address: json['address']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      checkInTime: json['checkInTime']?.toString() ?? '',
      checkOutTime: json['checkOutTime']?.toString() ?? '',
      minPrice: parseDouble(json['minPrice']),
      currencySymbol: json['currency_symbol']?.toString() ?? 'Nu.',
      images: (json['images'] as List? ?? const []).map((e) => e.toString()).toList(),
      rooms: (json['rooms'] as List? ?? const [])
          .map((e) => HotelRoom.fromJson(e as Map<String, dynamic>))
          .toList(),
      cancellationPolicy: json['cancellationPolicy']?.toString(),
    );
  }

  final int id;
  final String name;
  final String slug;
  final int starRating;
  final String address;
  final String location;
  final String description;
  final String checkInTime;
  final String checkOutTime;
  final double minPrice;
  final String currencySymbol;
  final List<String> images;
  final List<HotelRoom> rooms;
  final String? cancellationPolicy;
}
