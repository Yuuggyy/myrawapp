import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Real backend client for MyRawApp.
/// Talks to the Base44-hosted backend functions (see functions/rawbank*.ts).
/// Every function endpoint takes a single JSON body with an `action` field —
/// there is no path-based REST routing, so all parameters (including the
/// access token) travel in the POST body.
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  SharedPreferences? _prefs;

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
    _initPrefs();
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> _readToken() async {
    await _initPrefs();
    return _prefs!.getString(AppConstants.tokenKey);
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await _initPrefs();
    if (data['access_token'] != null) {
      await _prefs!.setString(AppConstants.tokenKey, data['access_token']);
    }
    if (data['refresh_token'] != null) {
      await _prefs!.setString(AppConstants.refreshTokenKey, data['refresh_token']);
    }
  }

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove(AppConstants.tokenKey);
    await _prefs!.remove(AppConstants.refreshTokenKey);
    await _prefs!.remove(AppConstants.userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _readToken();
    return token != null && token.isNotEmpty;
  }

  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == false) {
      throw ApiException(data['error']?.toString() ?? 'Une erreur est survenue');
    }
    return data is Map<String, dynamic> ? data : {'data': data};
  }

  // ── Auth ──

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/rawbankAuth', data: {
      'action': 'login',
      'email': email,
      'password': password,
    });
    final data = _unwrap(response);
    await _saveSession(data);
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> fields) async {
    final response = await _dio.post('/rawbankAuth', data: {
      'action': 'register',
      ...fields,
    });
    final data = _unwrap(response);
    await _saveSession(data);
    return data;
  }

  // ── Projects ──

  Future<List<dynamic>> getProjects() async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankProjects', data: {'action': 'list', 'access_token': token});
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getProject(String id) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankProjects', data: {'action': 'get', 'access_token': token, 'id': id});
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankProjects', data: {'action': 'create', 'access_token': token, ...data});
    return _unwrap(response);
  }

  // ── Accounts ──

  Future<List<dynamic>> getAccounts() async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankAccounts', data: {'action': 'list', 'access_token': token});
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getTransactions(String accountId) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankAccounts', data: {
      'action': 'transactions', 'access_token': token, 'account_id': accountId,
    });
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> transfer({
    required String fromAccountId,
    required String toPhoneOrNumber,
    required double amount,
    String? description,
  }) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankAccounts', data: {
      'action': 'transfer',
      'access_token': token,
      'from_account_id': fromAccountId,
      'to_phone_or_number': toPhoneOrNumber,
      'amount': amount,
      'description': description,
    });
    return _unwrap(response);
  }

  // ── Chat ──

  Future<List<dynamic>> getMessages(String projectId) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankChat', data: {
      'action': 'list', 'access_token': token, 'project_id': projectId,
    });
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(String projectId, String content, {String agentType = 'router'}) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankChat', data: {
      'action': 'send',
      'access_token': token,
      'project_id': projectId,
      'content': content,
      'agent_type': agentType,
    });
    return _unwrap(response);
  }

  /// Persists a single message as-is (no auto AI-reply generation).
  /// Used by screens that generate their own reply text locally and just
  /// need it saved for the record (e.g. the scripted multi-agent chat UI).
  Future<void> logChatMessage(String projectId, String content, String senderType, String agentType) async {
    final token = await _readToken();
    await _dio.post('/rawbankChat', data: {
      'action': 'log',
      'access_token': token,
      'project_id': projectId,
      'content': content,
      'sender_type': senderType,
      'agent_type': agentType,
    });
  }

  // ── KYC ──

  Future<Map<String, dynamic>> getKycStatus() async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankKyc', data: {'action': 'status', 'access_token': token});
    return _unwrap(response);
  }

  Future<Map<String, dynamic>> uploadKycDocument(String docType, String fileUrl) async {
    final token = await _readToken();
    final response = await _dio.post('/rawbankKyc', data: {
      'action': 'upload', 'access_token': token, 'doc_type': docType, 'file_url': fileUrl,
    });
    return _unwrap(response);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
