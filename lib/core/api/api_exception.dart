/// A user-presentable error surfaced from the API.
///
/// [fieldErrors] holds Laravel validation errors keyed by field name
/// (e.g. {"email": ["The email has already been taken."]}), when present.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  /// The first validation message, if any — handy for a single-line toast.
  String? get firstFieldError {
    final errors = fieldErrors;
    if (errors == null || errors.isEmpty) return null;
    return errors.values.first.first;
  }

  @override
  String toString() => message;
}
