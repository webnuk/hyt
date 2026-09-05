import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/booking_flow.dart';
import '../domain/booking_summary.dart';
import '../domain/my_booking.dart';

/// Talks to the /booking-summary, /bookings/*, and /payments/*/status
/// endpoints (routes/api.php) — all behind auth:sanctum, so every call here
/// assumes the customer is already signed in.
class BookingRepository {
  BookingRepository(this._api);
  final ApiClient _api;

  Future<BookingSummary> summary({
    required String type,
    required String slug,
    required int adults,
    required int children,
    String? travelDate,
    int? roomId,
    String? checkinCheckout,
    int? rooms,
  }) async {
    final json = await _api.post('/booking-summary', data: {
      'type': type,
      'slug': slug,
      'adults': adults,
      'children': children,
      if (travelDate != null) 'travel_date': travelDate,
      if (roomId != null) 'room_id': roomId,
      if (checkinCheckout != null) 'checkin_checkout': checkinCheckout,
      if (rooms != null) 'rooms': rooms,
    });
    final data = json['data'];
    if (data is! Map<String, dynamic> || data['summary'] is! Map<String, dynamic>) {
      throw ApiException(json['message']?.toString() ?? 'Could not calculate the price.');
    }
    return BookingSummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<BookingSession> create({
    required String type,
    required int itemId,
    required String startDate,
    String? endDate,
    required int adults,
    required int children,
    int? rooms,
    int? nights,
    String? specialRequirements,
  }) async {
    final json = await _api.post('/bookings/create', data: {
      'type': type,
      'item_id': itemId,
      'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'adults': adults,
      'children': children,
      if (rooms != null) 'rooms': rooms,
      if (nights != null) 'nights': nights,
      if (specialRequirements != null && specialRequirements.isNotEmpty)
        'special_requirements': specialRequirements,
    });
    return _parseData(json, BookingSession.fromJson, fallback: 'Could not start the booking.');
  }

  Future<BookingReview> reviewDraft(String bookingToken) async {
    final json = await _api.get('/bookings/$bookingToken/details');
    return _parseData(json, BookingReview.fromJson, fallback: 'Could not load the booking.');
  }

  Future<BookingConfirmation> confirm(
    String bookingToken, {
    required String guestFullName,
    required String guestEmail,
    required String guestPhone,
    required String guestCountry,
  }) async {
    final json = await _api.post('/bookings/$bookingToken/confirm', data: {
      'guest_full_name': guestFullName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'guest_country': guestCountry,
    });
    return _parseData(json, BookingConfirmation.fromJson, fallback: 'Could not confirm the booking.');
  }

  Future<PaymentGatewayInfo> paymentUrl(int paymentId) async {
    final json = await _api.get('/bookings/$paymentId/payment-url');
    return _parseData(json, PaymentGatewayInfo.fromJson, fallback: 'Could not start payment.');
  }

  Future<PaymentStatus> paymentStatus(int paymentId) async {
    final json = await _api.get('/payments/$paymentId/status');
    return _parseData(json, PaymentStatus.fromJson, fallback: 'Could not check payment status.');
  }

  Future<BookingListPage> list({int page = 1}) async {
    final json = await _api.get('/bookings/list', query: {'page': page});
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['bookings'] as List? ?? const [])
        .map((e) => BookingListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] as Map<String, dynamic>? ?? const {};
    return BookingListPage(
      items: items,
      currentPage: pagination['current_page'] is num ? (pagination['current_page'] as num).toInt() : 1,
      lastPage: pagination['last_page'] is num ? (pagination['last_page'] as num).toInt() : 1,
    );
  }

  Future<BookingDetail> byId(int id) async {
    final json = await _api.get('/bookings/$id');
    return _parseData(json, BookingDetail.fromJson, fallback: 'Could not load this booking.');
  }

  Future<void> cancel(int id, {String? reason}) async {
    await _api.post('/bookings/$id/cancel', data: {if (reason != null) 'reason': reason});
  }

  T _parseData<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson, {
    required String fallback,
  }) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(json['message']?.toString() ?? fallback);
    }
    return fromJson(data);
  }
}
