import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// AI Service - calls the RawBank AI backend function powered by Groq (Llama 3.3 70B)
/// Falls back to keyword-based response if backend is unreachable
class AiService {
  static AiService? _instance;
  late final Dio _dio;

  AiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: '',
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

  /// Calls the RawBank AI chat backend function (Groq powered)
  /// Returns the AI response, or null if the backend is unreachable
  Future<AiChatResult?> chat({
    required String message,
    required String agentBackendName,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.aiChatUrl,
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
