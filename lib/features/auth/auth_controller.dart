import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  final bool isInitialized;
  final bool loggedIn;
  final bool loading;
  final String? error;
  final Map<String, String> fieldErrors;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? currentCompany;
  final List<Map<String, dynamic>> companies;
  final String role;

  const AuthState({
    this.isInitialized = false,
    this.loggedIn = false,
    this.loading = false,
    this.error,
    this.fieldErrors = const {},
    this.user,
    this.currentCompany,
    this.companies = const [],
    this.role = 'owner',
  });

  bool get isOwner => role == 'owner';
  bool get isDispatcher => role == 'dispatcher' || role == 'owner';
  bool get isTechnician => role == 'technician';

  AuthState copy({
    bool? isInitialized,
    bool? loggedIn,
    bool? loading,
    String? error,
    bool clearError = false,
    Map<String, String>? fieldErrors,
    Map<String, dynamic>? user,
    Map<String, dynamic>? currentCompany,
    List<Map<String, dynamic>>? companies,
    String? role,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      loggedIn: loggedIn ?? this.loggedIn,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: clearError ? const {} : (fieldErrors ?? this.fieldErrors),
      user: user ?? this.user,
      currentCompany: currentCompany ?? this.currentCompany,
      companies: companies ?? this.companies,
      role: role ?? this.role,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await loadCurrentUser();
      } else {
        state = state.copy(isInitialized: true, loggedIn: false);
      }
    } catch (_) {
      state = state.copy(isInitialized: true, loggedIn: false);
    } finally {
      if (!state.isInitialized) {
        state = state.copy(isInitialized: true);
      }
    }
  }

  void clearError() {
    if (state.error != null || state.fieldErrors.isNotEmpty) {
      state = state.copy(clearError: true);
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final r = await ApiClient.instance.dio.get('/auth/me');
      final userData = _extractUserData(r.data);
      if (userData != null) {
        _applyUserData(userData);
      } else {
        state = state.copy(isInitialized: true, loggedIn: false);
      }
    } catch (_) {
      state = state.copy(isInitialized: true, loggedIn: false);
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

      final userData = _extractUserData(r.data);
      if (userData != null) {
        _applyUserData(userData);
      } else {
        state = state.copy(loggedIn: true, loading: false, clearError: true);
      }
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

      final userData = _extractUserData(r.data);
      if (userData != null) {
        _applyUserData(userData);
      } else {
        state = state.copy(loggedIn: true, loading: false, clearError: true);
      }
    } catch (e) {
      final parsed = _parseError(e, 'Registration failed. Please check the form fields.');
      state = state.copy(
        loading: false,
        error: parsed.message,
        fieldErrors: parsed.fieldErrors,
      );
    }
  }

  Future<bool> switchCompany(int companyId) async {
    state = state.copy(loading: true);
    try {
      final r = await ApiClient.instance.dio.post('/auth/switch-company', data: {
        'company_id': companyId,
      });

      if (r.data != null && r.data is Map) {
        await loadCurrentUser();
      }
      state = state.copy(loading: false);
      return true;
    } catch (e) {
      state = state.copy(
        loading: false,
        error: 'Failed to switch company context.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post('/auth/logout');
    } catch (_) {}
    await ApiClient.instance.clearToken();
    state = const AuthState(isInitialized: true, loggedIn: false);
  }

  void _applyUserData(Map<String, dynamic> u) {
    Map<String, dynamic>? currComp;
    if (u['current_company'] is Map) {
      currComp = Map<String, dynamic>.from(u['current_company']);
    }

    final compList = <Map<String, dynamic>>[];
    String userRole = 'owner';

    if (u['companies'] is List) {
      for (final c in u['companies']) {
        if (c is Map) {
          final cMap = Map<String, dynamic>.from(c);
          compList.add(cMap);

          if (currComp != null && cMap['id'] == currComp['id']) {
            if (cMap['pivot'] is Map && cMap['pivot']['role'] != null) {
              userRole = cMap['pivot']['role'].toString().toLowerCase();
            }
          }
        }
      }
    }

    state = state.copy(
      isInitialized: true,
      loggedIn: true,
      loading: false,
      clearError: true,
      user: u,
      currentCompany: currComp,
      companies: compList,
      role: userRole,
    );
  }

  Map<String, dynamic>? _extractUserData(dynamic data) {
    if (data is Map) {
      if (data['data'] is Map && data['data']['user'] is Map) {
        return Map<String, dynamic>.from(data['data']['user']);
      }
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user']);
      }
    }
    return null;
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

        if (mainMessage == null && data['message'] != null) {
          final msg = data['message'].toString();
          if (msg.isNotEmpty && !msg.toLowerCase().contains('given data was invalid')) {
            mainMessage = msg;
          }
        }
      }

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
