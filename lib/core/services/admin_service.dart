import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Admin Service — connects to the RawBank admin backend
/// Loads real stats, projects, users, and manages RAG document uploads
class AdminService {
  static AdminService? _instance;
  late final Dio _dio;

  AdminService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
  }

  static AdminService get instance {
    _instance ??= AdminService._internal();
    return _instance!;
  }

  /// Fetch dashboard stats from Supabase via backend
  Future<AdminStats> getStats() async {
    try {
      final response = await _dio.get(
        AppConstants.adminUrl,
        queryParameters: {'action': 'stats'},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final stats = data['stats'] as Map<String, dynamic>;
        return AdminStats.fromJson(stats);
      }
    } catch (e) {
      // ignore
    }
    return AdminStats.empty();
  }

  /// Fetch all projects from Supabase
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _dio.get(
        AppConstants.adminUrl,
        queryParameters: {'action': 'projects'},
      );
      if (response.statusCode == 200) {
        final projects = response.data['projects'] as List;
        return projects.map((p) => Map<String, dynamic>.from(p)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  /// Fetch all users from Supabase
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _dio.get(
        AppConstants.adminUrl,
        queryParameters: {'action': 'users'},
      );
      if (response.statusCode == 200) {
        final users = response.data['users'] as List;
        return users.map((u) => Map<String, dynamic>.from(u)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  /// Fetch chat sessions and messages
  Future<Map<String, dynamic>> getChatData() async {
    try {
      final response = await _dio.get(
        AppConstants.adminUrl,
        queryParameters: {'action': 'chat'},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // ignore
    }
    return {'sessions': [], 'messages': []};
  }

  /// Approve or reject a project
  Future<bool> updateProjectStatus({
    required String projectId,
    required String status,
    String? reviewNotes,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.adminUrl,
        data: {
          'projectId': projectId,
          'status': status,
          'reviewNotes': reviewNotes,
        },
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch knowledge base documents
  Future<List<Map<String, dynamic>>> getKnowledgeBase() async {
    try {
      final response = await _dio.get(AppConstants.ragUploadUrl);
      if (response.statusCode == 200) {
        final docs = response.data['documents'] as List;
        return docs.map((d) => Map<String, dynamic>.from(d)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  /// Upload a document to the knowledge base (RAG)
  Future<Map<String, dynamic>?> uploadDocument({
    required String title,
    required String content,
    String category = 'general',
    String documentType = 'text',
    String? description,
    String uploadedBy = 'admin',
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.ragUploadUrl,
        data: {
          'title': title,
          'content': content,
          'category': category,
          'documentType': documentType,
          'description': description ?? title,
          'uploadedBy': uploadedBy,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}

/// Admin dashboard statistics
class AdminStats {
  final int totalUsers;
  final int totalProjects;
  final int pendingProjects;
  final int approvedProjects;
  final int rejectedProjects;
  final int totalRequests;
  final double totalFundingRequested;
  final int totalTransactions;
  final int totalChatSessions;
  final int totalChatMessages;
  final int activeAiAgents;
  final int knowledgeBaseDocs;

  const AdminStats({
    required this.totalUsers,
    required this.totalProjects,
    required this.pendingProjects,
    required this.approvedProjects,
    required this.rejectedProjects,
    required this.totalRequests,
    required this.totalFundingRequested,
    required this.totalTransactions,
    required this.totalChatSessions,
    required this.totalChatMessages,
    required this.activeAiAgents,
    required this.knowledgeBaseDocs,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: (json['totalUsers'] ?? 0) as int,
      totalProjects: (json['totalProjects'] ?? 0) as int,
      pendingProjects: (json['pendingProjects'] ?? 0) as int,
      approvedProjects: (json['approvedProjects'] ?? 0) as int,
      rejectedProjects: (json['rejectedProjects'] ?? 0) as int,
      totalRequests: (json['totalRequests'] ?? 0) as int,
      totalFundingRequested: (json['totalFundingRequested'] ?? 0).toDouble(),
      totalTransactions: (json['totalTransactions'] ?? 0) as int,
      totalChatSessions: (json['totalChatSessions'] ?? 0) as int,
      totalChatMessages: (json['totalChatMessages'] ?? 0) as int,
      activeAiAgents: (json['activeAiAgents'] ?? 0) as int,
      knowledgeBaseDocs: (json['knowledgeBaseDocs'] ?? 0) as int,
    );
  }

  factory AdminStats.empty() {
    return const AdminStats(
      totalUsers: 0, totalProjects: 0, pendingProjects: 0,
      approvedProjects: 0, rejectedProjects: 0, totalRequests: 0,
      totalFundingRequested: 0, totalTransactions: 0, totalChatSessions: 0,
      totalChatMessages: 0, activeAiAgents: 0, knowledgeBaseDocs: 0,
    );
  }
}
