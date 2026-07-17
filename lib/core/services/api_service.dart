import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _setupInterceptors();
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _storage.read(key: AppConstants.tokenKey);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      await _storage.write(key: AppConstants.tokenKey, value: response.data['access_token']);
      await _storage.write(key: AppConstants.refreshTokenKey, value: response.data['refresh_token']);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // AUTH
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.write(key: AppConstants.tokenKey, value: response.data['access_token']);
    await _storage.write(key: AppConstants.refreshTokenKey, value: response.data['refresh_token']);
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    return response.data;
  }

  // PROJECTS
  Future<List<dynamic>> getProjects() async {
    final response = await _dio.get('/projects');
    return response.data;
  }

  Future<Map<String, dynamic>> getProject(String id) async {
    final response = await _dio.get('/projects/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final response = await _dio.post('/projects', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> uploadProjectFile(String projectId, String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.post('/projects/$projectId/files', data: formData);
    return response.data;
  }

  // AI
  Future<Map<String, dynamic>> getAiReport(String projectId) async {
    final response = await _dio.get('/ai/report/$projectId');
    return response.data;
  }

  Future<Map<String, dynamic>> triggerAiAnalysis(String projectId) async {
    final response = await _dio.post('/ai/route', data: {'project_id': projectId});
    return response.data;
  }

  // ACCOUNTS
  Future<List<dynamic>> getAccounts() async {
    final response = await _dio.get('/accounts');
    return response.data;
  }

  Future<List<dynamic>> getTransactions(String accountId) async {
    final response = await _dio.get('/accounts/$accountId/transactions');
    return response.data;
  }

  // CHAT
  Future<List<dynamic>> getMessages(String projectId) async {
    final response = await _dio.get('/chats/$projectId');
    return response.data;
  }

  Future<Map<String, dynamic>> sendMessage(String projectId, String content) async {
    final response = await _dio.post('/chats/$projectId/messages', data: {
      'content': content,
      'sender_type': 'human',
    });
    return response.data;
  }

  // KYC
  Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _dio.get('/kyc/status');
    return response.data;
  }

  Future<Map<String, dynamic>> uploadKycDocument(String filePath, String docType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'doc_type': docType,
    });
    final response = await _dio.post('/kyc/upload', data: formData);
    return response.data;
  }

  // ADMIN
  Future<List<dynamic>> getAdminProjects({String? status, String? sector}) async {
    final response = await _dio.get('/admin/projects', queryParameters: {
      if (status != null) 'status': status,
      if (sector != null) 'sector': sector,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> makeDecision(String projectId, String decision, String notes) async {
    final response = await _dio.post('/admin/projects/$projectId/decision', data: {
      'decision': decision,
      'notes': notes,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _dio.get('/admin/analytics');
    return response.data;
  }
}
