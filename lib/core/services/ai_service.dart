import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class AiChatResult {
  final String response;
  final String agent;
  final String agentName;
  final String timestamp;
  final Map<String, dynamic>? scoring;
  final String? sessionId;

  AiChatResult({
    required this.response,
    required this.agent,
    required this.agentName,
    required this.timestamp,
    this.scoring,
    this.sessionId,
  });
}

class AiService {
  static AiService? _instance;
  late final Dio _dio;

  AiService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
  }

  static AiService get instance {
    _instance ??= AiService._internal();
    return _instance!;
  }

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

  Future<AiChatResult?> chat({
    required String message,
    required String agentBackendName,
    List<Map<String, String>> conversationHistory = const [],
    Map<String, dynamic>? projectContext,
    String? conversationType,
    String sender = 'client',
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
        'agent': agentBackendName,
        'conversationHistory': conversationHistory,
        'sender': sender,
      };
      if (projectContext != null) body['projectContext'] = projectContext;
      if (conversationType != null) body['conversationType'] = conversationType;

      final response = await _dio.post(AppConstants.aiChatUrl, data: body);

      if (response.statusCode == 200) {
        final data = response.data;
        return AiChatResult(
          response: data['response'] ?? 'Aucune reponse.',
          agent: data['agent'] ?? agentBackendName,
          agentName: data['agentName'] ?? 'Routeur IA',
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
          scoring: data['scoring'] as Map<String, dynamic>?,
          sessionId: data['sessionId'] as String?,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
