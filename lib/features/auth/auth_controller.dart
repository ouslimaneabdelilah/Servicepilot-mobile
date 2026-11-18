import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  final bool loggedIn;
  final bool loading;
  final String? error;
  final Map<String, String> fieldErrors;

  const AuthState({
    this.loggedIn = false,
    this.loading = false,
    this.error,
    this.fieldErrors = const {},
  });

  AuthState copy({
    bool? loggedIn,
    bool? loading,
    String? error,
    bool clearError = false,
    Map<String, String>? fieldErrors,
  }) {
    return AuthState(
      loggedIn: loggedIn ?? this.loggedIn,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: clearError ? const {} : (fieldErrors ?? this.fieldErrors),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void clearError() {
    if (state.error != null || state.fieldErrors.isNotEmpty) {
      state = state.copy(clearError: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copy(loading: true, clearError: true);
    try {
      final r = await ApiClient.instance.dio.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'device_name': 'servicepilot-mobile',
      });

      final token = _extractToken(r.data);
      if (token == null || token.isEmpty) {
        throw Exception('Server did not return an authentication token.');
      }

      await ApiClient.instance.saveToken(token);
      state = state.copy(loggedIn: true, loading: false, clearError: true);
    } catch (e) {
      final parsed = _parseError(e, 'Incorrect email or password. Please try again.');
      state = state.copy(
        loading: false,
        error: parsed.message,
        fieldErrors: parsed.fieldErrors,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String company,
    required String type,
    required String password,
    required String confirmation,
    String? phone,
  }) async {
    state = state.copy(loading: true, clearError: true);
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'company_name': company.trim(),
        'business_type': type,
        'password': password,
        'password_confirmation': confirmation,
      };

      if (phone != null && phone.trim().isNotEmpty) {
        payload['phone'] = phone.trim();
      }

      final r = await ApiClient.instance.dio.post('/auth/register', data: payload);

      final token = _extractToken(r.data);
      if (token == null || token.isEmpty) {
        throw Exception('Account created but no token was provided. Please log in.');
      }

      await ApiClient.instance.saveToken(token);
      state = state.copy(loggedIn: true, loading: false, clearError: true);
    } catch (e) {
      final parsed = _parseError(e, 'Registration failed. Please check the form fields.');
      state = state.copy(
        loading: false,
        error: parsed.message,
        fieldErrors: parsed.fieldErrors,
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

  String? _extractToken(dynamic data) {
    if (data is Map) {
      if (data['data'] is Map && data['data']['token'] != null) {
        return data['data']['token'].toString();
      }
      if (data['token'] != null) {
        return data['token'].toString();
      }
    }
    return null;
  }

  _ParsedError _parseError(dynamic error, String fallback) {
    final fields = <String, String>{};
    String? mainMessage;

    if (error is DioException) {
      final res = error.response;
      if (res?.data != null && res!.data is Map) {
        final data = res.data as Map;

        // 1. Check for detailed Laravel validation errors
        if (data['errors'] != null && data['errors'] is Map) {
          final errMap = data['errors'] as Map;
          final buffer = <String>[];
          for (final entry in errMap.entries) {
            final key = entry.key.toString();
            final val = entry.value;
            String msg = '';
            if (val is List && val.isNotEmpty) {
              msg = val.first.toString();
            } else if (val != null) {
              msg = val.toString();
            }
            if (msg.isNotEmpty) {
              fields[key] = msg;
              buffer.add(msg);
            }
          }
          if (buffer.isNotEmpty) {
            mainMessage = buffer.join('\n');
          }
        }

        // 2. Check for general message
        if (mainMessage == null && data['message'] != null) {
          final msg = data['message'].toString();
          if (msg.isNotEmpty && !msg.toLowerCase().contains('given data was invalid')) {
            mainMessage = msg;
          }
        }
      }

      // 3. Handle network status codes & exceptions
      if (mainMessage == null) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          mainMessage = 'Server unreachable. Verify your connection and that the backend server is running.';
        } else if (res?.statusCode == 401) {
          mainMessage = 'Invalid email or password.';
        } else if (res?.statusCode == 422) {
          mainMessage = 'Please correct the highlighted errors.';
        } else if (res?.statusCode != null && res!.statusCode! >= 500) {
          mainMessage = 'Server error (${res.statusCode}). Please try again later.';
        }
      }
    } else if (error is Exception) {
      mainMessage = error.toString().replaceFirst('Exception: ', '');
    }

    return _ParsedError(
      message: mainMessage ?? fallback,
      fieldErrors: fields,
    );
  }
}

class _ParsedError {
  final String message;
  final Map<String, String> fieldErrors;

  _ParsedError({required this.message, required this.fieldErrors});
}
