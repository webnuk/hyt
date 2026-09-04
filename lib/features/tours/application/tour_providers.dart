import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/currency/currency_provider.dart';
import '../data/tour_repository.dart';
import '../domain/tour_detail.dart';
import '../domain/tour_summary.dart';

final tourRepositoryProvider = Provider<TourRepository>((ref) => TourRepository(ApiClient.instance));

/// First page of featured tours, for the Home screen.
final featuredToursProvider = FutureProvider.autoDispose<List<TourSummary>>((ref) async {
  final currency = ref.watch(currencyProvider);
  final page = await ref.read(tourRepositoryProvider).list(currency: currency, featuredOnly: true);
  return page.items;
});

/// Paginated tour listing (Tours tab). Call `loadMore()` to fetch the next page.
class TourListController extends AsyncNotifier<List<TourSummary>> {
  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  Future<List<TourSummary>> build() async {
    _page = 1;
    _hasMore = true;
    final currency = ref.watch(currencyProvider);
    final result = await ref.read(tourRepositoryProvider).list(currency: currency);
    _hasMore = result.hasMore;
    return result.items;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final currency = ref.read(currencyProvider);
    final current = state.valueOrNull ?? [];
    _page += 1;
    try {
      final result = await ref.read(tourRepositoryProvider).list(currency: currency, page: _page);
      _hasMore = result.hasMore;
      state = AsyncData([...current, ...result.items]);
    } catch (_) {
      _page -= 1; // allow retry
    }
  }

  Future<void> refresh() => ref.refresh(tourListControllerProvider.future);
}

final tourListControllerProvider = AsyncNotifierProvider<TourListController, List<TourSummary>>(
  TourListController.new,
);

final tourDetailProvider = FutureProvider.autoDispose.family<TourDetail, String>((ref, slug) async {
  final currency = ref.watch(currencyProvider);
  return ref.read(tourRepositoryProvider).detail(slug, currency: currency);
});
