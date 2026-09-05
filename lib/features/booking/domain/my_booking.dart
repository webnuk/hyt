import '../../../core/utils/json_parsing.dart';

/// One row from GET /bookings/list.
class BookingListItem {
  const BookingListItem({
    required this.id,
    required this.bookingReference,
    required this.type,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.canCancel,
  });

  factory BookingListItem.fromJson(Map<String, dynamic> json) => BookingListItem(
        id: parseInt(json['id']),
        bookingReference: json['booking_reference']?.toString() ?? '',
        type: json['type']?.toString() ?? 'tour',
        itemName: json['item_name']?.toString() ?? 'N/A',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        totalAmount: parseDouble(json['total_amount']),
        bookingStatus: json['booking_status']?.toString() ?? 'pending',
        paymentStatus: json['payment_status']?.toString(),
        canCancel: json['can_cancel'] == true,
      );

  final int id;
  final String bookingReference;
  final String type;
  final String itemName;
  final String startDate;
  final String endDate;
  final double totalAmount;
  final String bookingStatus;
  final String? paymentStatus;
  final bool canCancel;
}

class BookingListPage {
  const BookingListPage({required this.items, required this.currentPage, required this.lastPage});
  final List<BookingListItem> items;
  final int currentPage;
  final int lastPage;
  bool get hasMore => currentPage < lastPage;
}

/// GET /bookings/{id} — full detail for a single past/upcoming booking.
class BookingDetail {
  const BookingDetail({
    required this.id,
    required this.bookingReference,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.totalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.specialRequirements,
    required this.createdAt,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final guest = json['guest_details'] as Map<String, dynamic>? ?? const {};
    final amounts = json['amount_details'] as Map<String, dynamic>? ?? const {};
    return BookingDetail(
      id: parseInt(json['id']),
      bookingReference: json['booking_reference']?.toString() ?? '',
      type: json['type']?.toString() ?? 'tour',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      adults: parseInt(json['adults'], 1),
      children: parseInt(json['children']),
      guestName: guest['full_name']?.toString() ?? '',
      guestEmail: guest['email']?.toString() ?? '',
      guestPhone: guest['phone']?.toString() ?? '',
      totalAmount: parseDouble(amounts['total_amount']),
      bookingStatus: json['booking_status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString(),
      specialRequirements: json['special_requirements']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  final int id;
  final String bookingReference;
  final String type;
  final String startDate;
  final String endDate;
  final int adults;
  final int children;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final double totalAmount;
  final String bookingStatus;
  final String? paymentStatus;
  final String? specialRequirements;
  final String createdAt;
}
