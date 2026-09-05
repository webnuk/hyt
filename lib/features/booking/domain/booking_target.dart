/// Carries what the Booking Summary screen needs from a Tour or Hotel detail
/// screen — passed via go_router `extra` rather than re-fetched, since the
/// caller already has it loaded.
class BookingTarget {
  const BookingTarget.tour({
    required this.itemId,
    required this.slug,
    required this.name,
    required this.image,
    required this.currencySymbol,
    required this.durationDays,
  })  : type = 'tour',
        roomId = null,
        maxAdultsPerRoom = null;

  const BookingTarget.hotel({
    required this.itemId,
    required this.slug,
    required this.name,
    required this.image,
    required this.currencySymbol,
    required this.roomId,
    required this.maxAdultsPerRoom,
  })  : type = 'hotel',
        durationDays = null;

  final String type; // 'tour' | 'hotel'
  final int itemId;
  final String slug;
  final String name;
  final String image;
  final String currencySymbol;
  final int? durationDays; // tour only
  final int? roomId; // hotel only
  final int? maxAdultsPerRoom; // hotel only
}
