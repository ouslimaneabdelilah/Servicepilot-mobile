import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  const AuthState({this.loggedIn = false, this.loading = false, this.error});

  final bool loggedIn;
  final bool loading;
  final String? error;

  AuthState copy({bool? loggedIn, bool? loading, String? error}) => AuthState(
        loggedIn: loggedIn ?? this.loggedIn,
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copy(loading: true, error: null);
    try {
      final r = await ApiClient.instance.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
        'device_name': 'servicepilot-mobile',
      });
      await ApiClient.instance.saveToken(r.data['token']);
      state = state.copy(loggedIn: true, loading: false);
    } catch (e) {
      state = state.copy(
        loading: false,
        error: _extractErrorMessage(e, 'Login failed. Check your credentials.'),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmation,
    required String company,
    required String type,
  }) async {
    state = state.copy(loading: true, error: null);
    try {
      final r = await ApiClient.instance.dio.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': confirmation,
        'company_name': company.trim(),
        'business_type': type,
      });
      await ApiClient.instance.saveToken(r.data['token']);
      state = state.copy(loggedIn: true, loading: false);
    } catch (e) {
      state = state.copy(
        loading: false,
        error: _extractErrorMessage(e, 'Registration failed. Check the fields and server connection.'),
      );
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post('/auth/logout');
    } catch (_) {}
    await ApiClient.instance.clearToken();
    state = const AuthState();
  }

  String _extractErrorMessage(dynamic error, String fallback) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response!.data as Map;
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final first = errors.values.firstOrNull;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to backend server. Make sure "php artisan serve" is running and the IP/port in api_client.dart is correct.';
      }
    }
    return fallback;
  }
}
