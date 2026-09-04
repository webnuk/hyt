import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/currency/currency_provider.dart';
import '../data/hotel_repository.dart';
import '../domain/hotel_detail.dart';
import '../domain/hotel_summary.dart';

final hotelRepositoryProvider = Provider<HotelRepository>((ref) => HotelRepository(ApiClient.instance));

final featuredHotelsProvider = FutureProvider.autoDispose<List<HotelSummary>>((ref) async {
  final currency = ref.watch(currencyProvider);
  final page = await ref.read(hotelRepositoryProvider).list(currency: currency, featuredOnly: true);
  return page.items;
});

class HotelListController extends AsyncNotifier<List<HotelSummary>> {
  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  Future<List<HotelSummary>> build() async {
    _page = 1;
    _hasMore = true;
    final currency = ref.watch(currencyProvider);
    final result = await ref.read(hotelRepositoryProvider).list(currency: currency);
    _hasMore = result.hasMore;
    return result.items;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final currency = ref.read(currencyProvider);
    final current = state.valueOrNull ?? [];
    _page += 1;
    try {
      final result = await ref.read(hotelRepositoryProvider).list(currency: currency, page: _page);
      _hasMore = result.hasMore;
      state = AsyncData([...current, ...result.items]);
    } catch (_) {
      _page -= 1;
    }
  }
}

final hotelListControllerProvider = AsyncNotifierProvider<HotelListController, List<HotelSummary>>(
  HotelListController.new,
);

final hotelDetailProvider = FutureProvider.autoDispose.family<HotelDetail, String>((ref, slug) async {
  final currency = ref.watch(currencyProvider);
  return ref.read(hotelRepositoryProvider).detail(slug, currency: currency);
});
