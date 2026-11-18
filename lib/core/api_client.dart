import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  /// API Base URL:
  /// - Physical device (Wi-Fi): 'http://YOUR_PC_LAN_IP:8000/api/v1' (e.g. 'http://192.168.100.6:8000/api/v1')
  /// - Android Emulator: 'http://10.0.2.2:8000/api/v1'
  /// - If using Laragon Apache/Nginx on port 80: 'http://192.168.100.6/api/v1'
  static const baseUrl = 'http://192.168.100.6:8000/api/v1';

  final storage = const FlutterSecureStorage();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  Future<void> saveToken(String token) => storage.write(key: 'token', value: token);

  Future<String?> getToken() => storage.read(key: 'token');

  Future<void> clearToken() => storage.delete(key: 'token');
}
