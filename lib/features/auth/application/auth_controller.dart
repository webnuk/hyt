import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/customer.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ApiClient.instance));

/// Holds the signed-in customer (or null when signed out). `build()` runs
/// once at app start: if a token is already stored, it's validated against
/// GET /auth/profile so a stale/revoked token doesn't leave the app thinking
/// it's logged in.
class AuthController extends AsyncNotifier<Customer?> {
  @override
  Future<Customer?> build() async {
    // React to any 401 anywhere in the app by treating the session as ended.
    ApiClient.instance.unauthorizedController.stream.listen((_) async {
      await TokenStorage.instance.clear();
      state = const AsyncData(null);
    });

    final token = await TokenStorage.instance.read();
    if (token == null || token.isEmpty) return null;

    try {
      return await ref.read(authRepositoryProvider).fetchProfile();
    } catch (_) {
      await TokenStorage.instance.clear();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authRepositoryProvider).login(email: email, password: password);
      await TokenStorage.instance.save(result.token);
      return result.customer;
    });
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authRepositoryProvider)
          .register(fullName: fullName, email: email, password: password);
      await TokenStorage.instance.save(result.token);
      return result.customer;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await TokenStorage.instance.clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Customer?>(AuthController.new);

/// Convenience: true once we've resolved auth state and a customer is signed in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).valueOrNull != null;
});
