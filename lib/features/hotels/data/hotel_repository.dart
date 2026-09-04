import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/hotel_detail.dart';
import '../domain/hotel_summary.dart';

class HotelListPage {
  const HotelListPage({required this.items, required this.currentPage, required this.lastPage});
  final List<HotelSummary> items;
  final int currentPage;
  final int lastPage;
  bool get hasMore => currentPage < lastPage;
}

class HotelRepository {
  HotelRepository(this._api);
  final ApiClient _api;

  Future<HotelListPage> list({required String currency, int page = 1, bool featuredOnly = false}) async {
    final json = await _api.get('/hotels', query: {
      'currency': currency,
      'page': page,
      if (featuredOnly) 'featured': true,
    });
    return _parsePage(json);
  }

  Future<HotelListPage> search({required String currency, String? location, int page = 1}) async {
    final json = await _api.get('/hotels/search', query: {
      'currency': currency,
      'page': page,
      if (location != null && location.isNotEmpty) 'search_location': location,
    });
    return _parsePage(json);
  }

  Future<HotelDetail> detail(String slug, {required String currency}) async {
    final json = await _api.get('/hotels/$slug', query: {'currency': currency});
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(json['message']?.toString() ?? 'Could not load this hotel.');
    }
    return HotelDetail.fromJson(data);
  }

  HotelListPage _parsePage(Map<String, dynamic> json) {
    final items = (json['data'] as List? ?? const [])
        .map((e) => HotelSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return HotelListPage(
      items: items,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}
