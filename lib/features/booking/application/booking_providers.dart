import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/booking_enquiry_repository.dart';
import '../data/booking_repository.dart';
import '../domain/booking_flow.dart';
import '../domain/booking_summary.dart';
import '../domain/my_booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository(ApiClient.instance));

final bookingEnquiryRepositoryProvider =
    Provider<BookingEnquiryRepository>((ref) => BookingEnquiryRepository(ApiClient.instance));

/// Recalculated whenever the traveller adjusts guests/dates/room count on the
/// Booking Summary screen — Riverpod dedupes/caches by the record's value
/// equality, so flipping back to a previously-seen combination is free.
typedef BookingSummaryRequest = ({
  String type,
  String slug,
  int adults,
  int children,
  String? travelDate,
  int? roomId,
  String? checkinCheckout,
  int? rooms,
});

final bookingSummaryProvider = FutureProvider.autoDispose.family<BookingSummary, BookingSummaryRequest>(
  (ref, request) {
    return ref.read(bookingRepositoryProvider).summary(
          type: request.type,
          slug: request.slug,
          adults: request.adults,
          children: request.children,
          travelDate: request.travelDate,
          roomId: request.roomId,
          checkinCheckout: request.checkinCheckout,
          rooms: request.rooms,
        );
  },
);

final bookingReviewProvider = FutureProvider.autoDispose.family<BookingReview, String>(
  (ref, bookingToken) => ref.read(bookingRepositoryProvider).reviewDraft(bookingToken),
);

/// Paginated "My Bookings" list (Account tab).
class MyBookingsController extends AsyncNotifier<List<BookingListItem>> {
  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  Future<List<BookingListItem>> build() async {
    _page = 1;
    _hasMore = true;
    final result = await ref.read(bookingRepositoryProvider).list(page: _page);
    _hasMore = result.hasMore;
    return result.items;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final current = state.valueOrNull ?? [];
    _page += 1;
    try {
      final result = await ref.read(bookingRepositoryProvider).list(page: _page);
      _hasMore = result.hasMore;
      state = AsyncData([...current, ...result.items]);
    } catch (_) {
      _page -= 1;
    }
  }

  Future<void> refresh() => ref.refresh(myBookingsControllerProvider.future);
}

final myBookingsControllerProvider = AsyncNotifierProvider<MyBookingsController, List<BookingListItem>>(
  MyBookingsController.new,
);

final bookingDetailProvider = FutureProvider.autoDispose.family<BookingDetail, int>(
  (ref, id) => ref.read(bookingRepositoryProvider).byId(id),
);
