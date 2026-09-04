import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../domain/customer.dart';

class AuthResult {
  AuthResult({required this.customer, required this.token});
  final Customer customer;
  final String token;
}

/// Talks to POST /auth/register, /auth/login, /auth/logout, GET /auth/profile.
class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final json = await _api.post('/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return _parseAuthResult(json);
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _parseAuthResult(json);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } on ApiException {
      // Even if the server call fails (e.g. token already invalid), the
      // caller still clears the local token — logging out should never get
      // the user stuck.
    }
  }

  Future<Customer> fetchProfile() async {
    final json = await _api.get('/auth/profile');
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Could not load profile.');
    }
    return Customer.fromJson(data);
  }

  AuthResult _parseAuthResult(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException(json['message']?.toString() ?? 'Unexpected response from server.');
    }
    final token = data['token']?.toString();
    final userJson = data['user'];
    if (token == null || userJson is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from server.');
    }
    return AuthResult(customer: Customer.fromJson(userJson), token: token);
  }
}
