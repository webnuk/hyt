import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';

/// Talks to POST /booking-enquiries — the "Book Now" lead form. No payment,
/// no login required; the backend routes the enquiry to the tour/hotel's
/// operator and cc's Host Your Tour (see BookingEnquiry::createAndNotify on
/// the server).
class BookingEnquiryRepository {
  BookingEnquiryRepository(this._api);
  final ApiClient _api;

  Future<String> submit({
    required String type,
    required String slug,
    required String name,
    required String email,
    required String phone,
    String? message,
    String? travelDate,
  }) async {
    final json = await _api.post('/booking-enquiries', data: {
      'type': type,
      'slug': slug,
      'name': name,
      'email': email,
      'phone': phone,
      if (message != null && message.isNotEmpty) 'message': message,
      if (travelDate != null) 'travel_date': travelDate,
    });
    final message2 = json['message']?.toString();
    if (message2 == null) {
      throw ApiException('Could not send your enquiry. Please try again.');
    }
    return message2;
  }
}
