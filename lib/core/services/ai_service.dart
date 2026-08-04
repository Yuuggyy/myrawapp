import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// AI Service - calls the RawBank AI backend function
/// Falls back to mock response if backend is unreachable
class AiService {
  static AiService? _instance;
  late final Dio _dio;

  AiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
  }

  static AiService get instance {
    _instance ??= AiService._internal();
    return _instance!;
  }

  /// Maps Flutter AgentType to backend agent name
  static String agentToBackend(String agentName) {
    switch (agentName) {
      case 'router': return 'routeur';
      case 'rse': return 'rse';
      case 'compliance': return 'conformite';
      case 'commercial': return 'commercial';
      case 'accounting': return 'comptabilite';
      default: return 'routeur';
    }
  }

  /// Calls the RawBank AI chat backend function
  /// Returns the AI response, or null if the backend is unreachable
  Future<AiChatResult?> chat({
    required String message,
    required String agentBackendName,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/rawbankaichat',
        data: {
          'message': message,
          'agent': agentBackendName,
          'conversationHistory': conversationHistory,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AiChatResult(
          response: data['response'] ?? 'Aucune réponse.',
          agent: data['agent'] ?? agentBackendName,
          agentName: data['agentName'] ?? 'Routeur IA',
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches the latest RawBank news feed
  Future<NewsFeedResult?> getNewsFeed({String? query, int limit = 10}) async {
    try {
      final response = await _dio.post(
        '/rawbanknewsfeed',
        data: {'query': query, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return NewsFeedResult(
          news: (data['news'] as List?)?.map((n) => NewsItem.fromJson(n)).toList() ?? [],
          rawbankUpdates: (data['rawbankUpdates'] as List?)?.map((u) => RawbankUpdate.fromJson(u)).toList() ?? [],
          source: data['source'] ?? 'unknown',
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class AiChatResult {
  final String response;
  final String agent;
  final String agentName;
  final String timestamp;

  AiChatResult({
    required this.response,
    required this.agent,
    required this.agentName,
    required this.timestamp,
  });
}

class NewsFeedResult {
  final List<NewsItem> news;
  final List<RawbankUpdate> rawbankUpdates;
  final String source;
  final String timestamp;

  NewsFeedResult({
    required this.news,
    required this.rawbankUpdates,
    required this.source,
    required this.timestamp,
  });
}

class NewsItem {
  final String title;
  final String link;
  final String date;
  final String description;
  final String source;

  NewsItem({
    required this.title,
    required this.link,
    required this.date,
    required this.description,
    required this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class RawbankUpdate {
  final String category;
  final String title;
  final String impact;
  final String detail;

  RawbankUpdate({
    required this.category,
    required this.title,
    required this.impact,
    required this.detail,
  });

  factory RawbankUpdate.fromJson(Map<String, dynamic> json) {
    return RawbankUpdate(
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      impact: json['impact'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}
