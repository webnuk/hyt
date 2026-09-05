import '../../../core/utils/json_parsing.dart';

/// Result of POST /bookings/create — a short-lived (2h) draft the customer
/// still needs to confirm with guest details before a real Booking exists.
class BookingSession {
  const BookingSession({required this.bookingToken, required this.expiresAt});

  factory BookingSession.fromJson(Map<String, dynamic> json) => BookingSession(
        bookingToken: json['booking_token']?.toString() ?? '',
        expiresAt: json['expires_at']?.toString() ?? '',
      );

  final String bookingToken;
  final String expiresAt;
}

/// Result of GET /bookings/{token}/details — used to review the draft and
/// prefill the guest-details form before confirming.
class BookingReview {
  const BookingReview({
    required this.itemName,
    required this.image,
    required this.startDate,
    required this.endDate,
    required this.estimatedTotal,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerCountry,
  });

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    final details = json['booking_details'] as Map<String, dynamic>? ?? const {};
    final amounts = json['amount_summary'] as Map<String, dynamic>? ?? const {};
    final customer = json['customer'] as Map<String, dynamic>? ?? const {};
    final isHotel = details['type'] == 'hotel';

    return BookingReview(
      itemName: (isHotel ? details['hotel_name'] : details['tour_name'])?.toString() ?? '',
      image: details['image']?.toString() ?? '',
      startDate: (isHotel ? details['check_in'] : details['start_date'])?.toString() ?? '',
      endDate: details['check_out']?.toString() ?? '',
      estimatedTotal: parseDouble(amounts['estimated_total']),
      customerName: customer['name']?.toString() ?? '',
      customerEmail: customer['email']?.toString() ?? '',
      customerPhone: customer['phone']?.toString() ?? '',
      customerCountry: customer['country']?.toString() ?? '',
    );
  }

  final String itemName;
  final String image;
  final String startDate;
  final String endDate;
  final double estimatedTotal;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerCountry;
}

/// Result of POST /bookings/{token}/confirm — the real Booking + Payment now
/// exist; this is what's needed to request the payment gateway URL next.
class BookingConfirmation {
  const BookingConfirmation({
    required this.bookingId,
    required this.bookingReference,
    required this.paymentId,
    required this.transactionId,
    required this.amount,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) => BookingConfirmation(
        bookingId: parseInt(json['booking_id']),
        bookingReference: json['booking_reference']?.toString() ?? '',
        paymentId: parseInt(json['payment_id']),
        transactionId: json['transaction_id']?.toString() ?? '',
        amount: parseDouble(json['amount']),
      );

  final int bookingId;
  final String bookingReference;
  final int paymentId;
  final String transactionId;
  final double amount;
}

/// Result of GET /bookings/{payment_id}/payment-url — the RMA BFS Secure
/// gateway expects these fields POSTed as a plain HTML form, not JSON, so the
/// webview loads [paymentUrl] with [gatewayData] as its form body.
class PaymentGatewayInfo {
  const PaymentGatewayInfo({
    required this.paymentUrl,
    required this.gatewayData,
    required this.paymentId,
    required this.pollStatusUrl,
  });

  factory PaymentGatewayInfo.fromJson(Map<String, dynamic> json) {
    final rawData = json['gateway_data'] as Map? ?? const {};
    return PaymentGatewayInfo(
      paymentUrl: json['payment_url']?.toString() ?? '',
      gatewayData: rawData.map((key, value) => MapEntry(key.toString(), value.toString())),
      paymentId: parseInt(json['payment_id']),
      pollStatusUrl: json['poll_status_url']?.toString() ?? '',
    );
  }

  final String paymentUrl;
  final Map<String, String> gatewayData;
  final int paymentId;
  final String pollStatusUrl;
}

/// Result of GET /payments/{id}/status — polled after the webview returns
/// from the gateway's fixed (bank-registered, non-deep-linkable) return URL.
class PaymentStatus {
  const PaymentStatus({
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.bookingStatus,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        status: json['status']?.toString() ?? 'pending',
        transactionId: json['transaction_id']?.toString() ?? '',
        amount: parseDouble(json['amount']),
        bookingStatus: json['booking_status']?.toString(),
      );

  final String status; // 'pending' | 'success' | 'failed'
  final String transactionId;
  final double amount;
  final String? bookingStatus;

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
}
