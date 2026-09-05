import '../../../core/utils/json_parsing.dart';

/// Maps to the `data.summary` object returned by POST /booking-summary.
/// Dates come back pre-formatted by the server (dd-MM-yyyy for tours, or
/// whatever format was sent in for hotels) — kept as display strings rather
/// than re-parsed, to avoid a lossy format round-trip.
class BookingSummary {
  const BookingSummary({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.adults,
    required this.children,
    required this.rooms,
    required this.netTotal,
    required this.discountRate,
    required this.discountAmount,
    required this.subTotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      type: json['type']?.toString() ?? 'tour',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      nights: parseInt(json['nights'], 1),
      adults: parseInt(json['adults'], 1),
      children: parseInt(json['children']),
      rooms: json['rooms'] == null ? null : parseInt(json['rooms']),
      netTotal: parseDouble(json['net_total']),
      discountRate: parseDouble(json['discount_rate']),
      discountAmount: parseDouble(json['discount_amount']),
      subTotal: parseDouble(json['sub_total']),
      taxRate: parseDouble(json['tax_rate']),
      taxAmount: parseDouble(json['tax_amount']),
      total: parseDouble(json['price']),
    );
  }

  final String type;
  final String startDate;
  final String endDate;
  final int nights;
  final int adults;
  final int children;
  final int? rooms;
  final double netTotal;
  final double discountRate;
  final double discountAmount;
  final double subTotal;
  final double taxRate;
  final double taxAmount;
  final double total;
}
