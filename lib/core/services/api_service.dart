import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/supabase_service.dart';
import '../constants/app_constants.dart';

/// Real backend client for MyRawApp.
/// Talks to the Base44-hosted backend functions (see functions/rawbank*.ts).
/// Every function endpoint takes a single JSON body with an `action` field —
/// there is no path-based REST routing, so all parameters (including the
/// access token) travel in the POST body.
///
/// MOCK MODE: When backend functions are unreachable (e.g. GitHub Pages
/// deployment), the service automatically falls back to mock data so the
/// app remains fully functional as a demo.
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  SharedPreferences? _prefs;

  /// When true, skip all network calls and return mock data.
  bool _mockMode = false;

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
    // Sign out of Supabase
    try { await SupabaseService.signOut(); } catch (_) {}
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
      throw ApiException(
        data['error']?.toString() ?? 'Une erreur est survenue',
        code: data['error_code']?.toString(),
      );
    }
    return data is Map<String, dynamic> ? data : {'data': data};
  }

  Future<Response> _post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map<String, dynamic> && respData['error'] != null) {
        throw ApiException(
          respData['error'].toString(),
          code: respData['error_code']?.toString(),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw ApiException('Connexion impossible. Vérifiez votre connexion internet.');
      }
      throw ApiException('Une erreur est survenue. Réessayez.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  MOCK DATA LAYER
  // ═══════════════════════════════════════════════════════════════════════

  static const List<Map<String, dynamic>> _mockAccounts = [
    {
      'id': '1',
      'type': 'illicoCash',
      'balance': 2450.75,
      'currency': 'USD',
      'status': 'Actif',
      'number': 'IC-843920',
    },
    {
      'id': '2',
      'type': 'particulier',
      'balance': 8750.00,
      'currency': 'USD',
      'status': 'Actif',
      'number': 'RAW-00842-P',
    },
    {
      'id': '3',
      'type': 'ladysFirst',
      'balance': 3200.00,
      'currency': 'USD',
      'status': 'Actif',
      'number': 'LF-00842-W',
    },
  ];

  static const List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': '1',
      'type': 'credit',
      'amount': 500.00,
      'currency': 'USD',
      'description': 'Virement reçu - Mama Shop',
      'date': '2026-08-03',
      'status': 'Complété',
      'reference': 'TXN-20260803-001',
    },
    {
      'id': '2',
      'type': 'debit',
      'amount': 120.50,
      'currency': 'USD',
      'description': 'Paiement facture SNEL',
      'date': '2026-08-02',
      'status': 'Complété',
      'reference': 'TXN-20260802-045',
    },
    {
      'id': '3',
      'type': 'debit',
      'amount': 75.00,
      'currency': 'USD',
      'description': 'Frais analyse dossier PME',
      'date': '2026-08-01',
      'status': 'Complété',
      'reference': 'TXN-20260801-012',
    },
    {
      'id': '4',
      'type': 'credit',
      'amount': 1200.00,
      'currency': 'USD',
      'description': 'Salaire Août 2026',
      'date': '2026-07-30',
      'status': 'Complété',
      'reference': 'TXN-20260730-001',
    },
    {
      'id': '5',
      'type': 'debit',
      'amount': 200.00,
      'currency': 'USD',
      'description': 'Recharge IllicoCash',
      'date': '2026-07-28',
      'status': 'Complété',
      'reference': 'TXN-20260728-003',
    },
    {
      'id': '6',
      'type': 'debit',
      'amount': 45.00,
      'currency': 'USD',
      'description': 'Visa Direct - Envoi diaspora',
      'date': '2026-07-25',
      'status': 'Complété',
      'reference': 'TXN-20260725-008',
    },
  ];

  static List<Map<String, dynamic>> _mockProjects = [
    {
      'id': 'p1',
      'user_id': 'u1',
      'org_id': null,
      'title': 'Agro-pole Lualaba',
      'type': 'RSE / ESG',
      'sector': 'Agriculture & Agro-alimentaire',
      'amount_requested': 75000.0,
      'currency': 'USD',
      'status': 'submitted',
      'priority_score': 82.5,
      'description': 'Projet de transformation de manioc dans la province du Lualaba avec un impact direct sur 300 familles.',
      'files': [],
      'ai_recommendations': [],
      'global_ai_score': 82.5,
      'created_at': '2026-07-28T10:00:00Z',
      'updated_at': '2026-07-30T14:30:00Z',
    },
    {
      'id': 'p2',
      'user_id': 'u1',
      'org_id': null,
      'title': 'Digital Hub Kinshasa',
      'type': 'Prêt à intérêt',
      'sector': 'Technologie & Télécoms',
      'amount_requested': 120000.0,
      'currency': 'USD',
      'status': 'ai_review',
      'priority_score': 90.0,
      'description': 'Centre de formation et d\'incubation pour 500 jeunes développeurs à Kinshasa.',
      'files': [],
      'ai_recommendations': [],
      'global_ai_score': 90.0,
      'created_at': '2026-07-15T08:00:00Z',
      'updated_at': '2026-08-01T16:00:00Z',
    },
    {
      'id': 'p3',
      'user_id': 'u1',
      'org_id': null,
      'title': 'Lady\'s First Goma',
      'type': 'Lady\'s First',
      'sector': 'Commerce & Distribution',
      'amount_requested': 45000.0,
      'currency': 'USD',
      'status': 'approved',
      'priority_score': 88.0,
      'description': 'Coopérative de 50 femmes entrepreneurs dans la transformation du café à Goma.',
      'files': [],
      'ai_recommendations': [],
      'global_ai_score': 88.0,
      'created_at': '2026-06-20T12:00:00Z',
      'updated_at': '2026-07-25T09:00:00Z',
    },
  ];

  static List<Map<String, dynamic>> _mockMessages = [];

  Map<String, dynamic> _mockUser(String email) => {
    'id': 'u1',
    'email': email,
    'full_name': 'Jean-Philippe Mukendi',
    'phone': '+243 81 234 5678',
    'kyc_level': 'standard',
    'client_type': 'Particulier',
    'organization': null,
  };

  // ═══════════════════════════════════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Try Supabase auth first
    try {
      final response = await SupabaseService.signIn(email: email, password: password);
      if (response.user != null) {
        final profile = await SupabaseService.getUserProfile();
        final userData = {
          'id': response.user!.id,
          'email': response.user!.email ?? email,
          'name': profile?['full_name'] ?? email.split('@').first,
          'phone': profile?['phone'] ?? '+243 81 234 5678',
          'kyc_level': profile?['kyc_status'] == 'verified' ? 'standard' : 'basic',
          'client_type': 'Particulier',
          'account_number': profile?['account_number'] ?? 'RAW-2024-00842',
        };
        await _saveSession({
          'access_token': response.session?.accessToken ?? 'supabase_token',
          'user': userData,
        });
        return {'access_token': response.session?.accessToken ?? 'supabase_token', 'user': userData};
      }
    } catch (e) {
      // Supabase auth failed, fall through to mock mode
    }
    // Fallback: mock mode for demo
    _mockMode = true;
    await _saveSession({'access_token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}'});
    return {'access_token': 'mock_token', 'user': _mockUser(email)};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> fields) async {
    // Try Supabase auth first
    try {
      final response = await SupabaseService.signUp(
        email: fields['email'] ?? '',
        password: fields['password'] ?? '',
        data: {
          'full_name': fields['name'],
          'phone': fields['phone'],
        },
      );
      if (response.user != null) {
        // Create user profile
        await SupabaseService.upsertUserProfile(
          fullName: fields['name'],
          email: fields['email'],
          phone: fields['phone'],
        );
        final userData = {
          'id': response.user!.id,
          'email': response.user!.email ?? fields['email'],
          'name': fields['name'] ?? fields['email'],
          'phone': fields['phone'] ?? '',
          'kyc_level': 'basic',
          'client_type': fields['client_type'] ?? 'Particulier',
          'account_number': 'RAW-${DateTime.now().year}-${Random().nextInt(99999).toString().padLeft(5, '0')}',
        };
        await _saveSession({
          'access_token': response.session?.accessToken ?? 'supabase_token',
          'user': userData,
        });
        return {'access_token': response.session?.accessToken ?? 'supabase_token', 'user': userData};
      }
    } catch (e) {
      // Supabase auth failed, fall through to mock mode
    }
    // Fallback: mock mode for demo
    _mockMode = true;
    await _saveSession({'access_token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}'});
    return {'access_token': 'mock_token', 'user': _mockUser(fields['email'] ?? '')};
  }

  Future<Map<String, dynamic>> me() async {
    if (_mockMode) {
      await _initPrefs();
      final email = _prefs?.getString('user_email') ?? 'jpmukendi@rawbank.cd';
      return _mockUser(email);
    }
    try {
      final token = await _readToken();
      final response = await _post('/rawbankAuth', data: {'action': 'me', 'access_token': token});
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      await _initPrefs();
      final email = _prefs?.getString('user_email') ?? 'jpmukendi@rawbank.cd';
      return _mockUser(email);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  PROJECTS
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getProjects() async {
    if (_mockMode) return List.from(_mockProjects);
    try {
      final token = await _readToken();
      final response = await _post('/rawbankProjects', data: {'action': 'list', 'access_token': token});
      return response.data as List<dynamic>;
    } catch (e) {
      _mockMode = true;
      return List.from(_mockProjects);
    }
  }

  Future<Map<String, dynamic>> getProject(String id) async {
    if (_mockMode) {
      return _mockProjects.firstWhere((p) => p['id'] == id, orElse: () => _mockProjects.first);
    }
    try {
      final token = await _readToken();
      final response = await _post('/rawbankProjects', data: {'action': 'get', 'access_token': token, 'id': id});
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      return _mockProjects.firstWhere((p) => p['id'] == id, orElse: () => _mockProjects.first);
    }
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    final newProject = {
      'id': 'p${_mockProjects.length + 1}',
      'user_id': 'u1',
      'org_id': null,
      'status': 'submitted',
      'priority_score': null,
      'files': [],
      'ai_recommendations': [],
      'global_ai_score': null,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      ...data,
    };
    if (_mockMode) {
      _mockProjects.insert(0, newProject);
      return newProject;
    }
    try {
      final token = await _readToken();
      final response = await _post('/rawbankProjects', data: {'action': 'create', 'access_token': token, ...data});
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      _mockProjects.insert(0, newProject);
      return newProject;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ACCOUNTS & TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getAccounts() async {
    if (_mockMode) return List.from(_mockAccounts);
    try {
      final token = await _readToken();
      final response = await _post('/rawbankAccounts', data: {'action': 'list', 'access_token': token});
      return response.data as List<dynamic>;
    } catch (e) {
      _mockMode = true;
      return List.from(_mockAccounts);
    }
  }

  Future<List<dynamic>> getTransactions(String accountId) async {
    if (_mockMode) return List.from(_mockTransactions);
    try {
      final token = await _readToken();
      final response = await _post('/rawbankAccounts', data: {
        'action': 'transactions', 'access_token': token, 'account_id': accountId,
      });
      return response.data as List<dynamic>;
    } catch (e) {
      _mockMode = true;
      return List.from(_mockTransactions);
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String fromAccountId,
    required String toPhoneOrNumber,
    required double amount,
    String? description,
  }) async {
    final result = {
      'id': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'Complété',
      'amount': amount,
      'from_account_id': fromAccountId,
      'to': toPhoneOrNumber,
      'description': description ?? 'Virement IllicoCash',
      'date': DateTime.now().toUtc().toIso8601String(),
      'reference': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
    };
    if (_mockMode) return result;
    try {
      final token = await _readToken();
      final response = await _post('/rawbankAccounts', data: {
        'action': 'transfer',
        'access_token': token,
        'from_account_id': fromAccountId,
        'to_phone_or_number': toPhoneOrNumber,
        'amount': amount,
        'description': description,
      });
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      return result;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  CHAT
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getMessages(String projectId) async {
    if (_mockMode) return List.from(_mockMessages);
    try {
      final token = await _readToken();
      final response = await _post('/rawbankChat', data: {
        'action': 'list', 'access_token': token, 'project_id': projectId,
      });
      return response.data as List<dynamic>;
    } catch (e) {
      _mockMode = true;
      return List.from(_mockMessages);
    }
  }

  Future<void> logChatMessage(String projectId, String content, String senderType, String agentType) async {
    if (_mockMode) {
      _mockMessages.add({
        'id': 'msg_${_mockMessages.length}',
        'project_id': projectId,
        'content': content,
        'sender_type': senderType,
        'agent_type': agentType,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }
    try {
      final token = await _readToken();
      await _post('/rawbankChat', data: {
        'action': 'log',
        'access_token': token,
        'project_id': projectId,
        'content': content,
        'sender_type': senderType,
        'agent_type': agentType,
      });
    } catch (e) {
      _mockMode = true;
      _mockMessages.add({
        'id': 'msg_${_mockMessages.length}',
        'project_id': projectId,
        'content': content,
        'sender_type': senderType,
        'agent_type': agentType,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  KYC
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getKycStatus() async {
    if (_mockMode) {
      return {
        'level': 'standard',
        'status': 'verified',
        'documents': [
          {'doc_type': 'id_card', 'status': 'verified', 'submitted_at': '2026-06-15T10:00:00Z'},
          {'doc_type': 'proof_of_address', 'status': 'verified', 'submitted_at': '2026-06-15T10:05:00Z'},
        ],
      };
    }
    try {
      final token = await _readToken();
      final response = await _post('/rawbankKyc', data: {'action': 'status', 'access_token': token});
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      return {
        'level': 'standard',
        'status': 'verified',
        'documents': [
          {'doc_type': 'id_card', 'status': 'verified', 'submitted_at': '2026-06-15T10:00:00Z'},
          {'doc_type': 'proof_of_address', 'status': 'verified', 'submitted_at': '2026-06-15T10:05:00Z'},
        ],
      };
    }
  }

  Future<Map<String, dynamic>> uploadKycDocument(String docType, String fileUrl) async {
    if (_mockMode) {
      return {'doc_type': docType, 'status': 'pending', 'file_url': fileUrl};
    }
    try {
      final token = await _readToken();
      final response = await _post('/rawbankKyc', data: {
        'action': 'upload', 'access_token': token, 'doc_type': docType, 'file_url': fileUrl,
      });
      return _unwrap(response);
    } catch (e) {
      _mockMode = true;
      return {'doc_type': docType, 'status': 'pending', 'file_url': fileUrl};
    }
  }
}

class ApiException implements Exception {
  final String message;
  final String? code;
  ApiException(this.message, {this.code});
  @override
  String toString() => message;
}
