import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/tour_detail.dart';
import '../domain/tour_summary.dart';

class TourListPage {
  const TourListPage({required this.items, required this.currentPage, required this.lastPage});
  final List<TourSummary> items;
  final int currentPage;
  final int lastPage;
  bool get hasMore => currentPage < lastPage;
}

class TourRepository {
  TourRepository(this._api);
  final ApiClient _api;

  Future<TourListPage> list({required String currency, int page = 1, bool featuredOnly = false}) async {
    final json = await _api.get('/tours', query: {
      'currency': currency,
      'page': page,
      if (featuredOnly) 'featured': true,
    });
    return _parsePage(json);
  }

  Future<TourListPage> search({
    required String currency,
    String? location,
    List<int>? categoryIds,
    int page = 1,
  }) async {
    final json = await _api.get('/tours/search', query: {
      'currency': currency,
      'page': page,
      if (location != null && location.isNotEmpty) 'search_location': location,
      if (categoryIds != null && categoryIds.isNotEmpty) 'categories': categoryIds,
    });
    return _parsePage(json);
  }

  Future<TourDetail> detail(String slug, {required String currency}) async {
    final json = await _api.get('/tours/$slug', query: {'currency': currency});
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(json['message']?.toString() ?? 'Could not load this tour.');
    }
    return TourDetail.fromJson(data);
  }

  TourListPage _parsePage(Map<String, dynamic> json) {
    final items = (json['data'] as List? ?? const [])
        .map((e) => TourSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return TourListPage(
      items: items,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}
