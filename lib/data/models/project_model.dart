import 'package:equatable/equatable.dart';

enum ProjectStatus {
  draft,
  submitted,
  analyzing,
  aiReview,
  humanReview,
  approved,
  rejected,
  pendingInfo,
}

class AiRecommendation extends Equatable {
  final String agentType;
  final double score;
  final String summary;
  final List<String> flags;
  final String recommendation;
  final DateTime createdAt;

  const AiRecommendation({
    required this.agentType,
    required this.score,
    required this.summary,
    required this.flags,
    required this.recommendation,
    required this.createdAt,
  });

  String get agentLabel {
    switch (agentType) {
      case 'rse': return 'RSE & Impact';
      case 'compliance': return 'Conformité';
      case 'commercial': return 'Commercial';
      case 'accounting': return 'Comptabilité';
      case 'router': return 'Synthèse IA';
      default: return agentType;
    }
  }

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      agentType: json['agent_type'],
      score: (json['score'] as num).toDouble(),
      summary: json['summary'],
      flags: List<String>.from(json['flags'] ?? []),
      recommendation: json['recommendation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [agentType, score];
}

class ProjectFile extends Equatable {
  final String id;
  final String filename;
  final String fileUrl;
  final String fileType;
  final int size;
  final String virusScanStatus;

  const ProjectFile({
    required this.id,
    required this.filename,
    required this.fileUrl,
    required this.fileType,
    required this.size,
    required this.virusScanStatus,
  });

  bool get isClean => virusScanStatus == 'clean';

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      id: json['id'],
      filename: json['filename'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      size: json['size'],
      virusScanStatus: json['virus_scan_status'] ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [id, filename];
}

class ProjectModel extends Equatable {
  final String id;
  final String userId;
  final String? orgId;
  final String title;
  final String type;
  final String sector;
  final double amountRequested;
  final String currency;
  final ProjectStatus status;
  final double? priorityScore;
  final String? description;
  final List<ProjectFile> files;
  final List<AiRecommendation> aiRecommendations;
  final double? globalAiScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    this.orgId,
    required this.title,
    required this.type,
    required this.sector,
    required this.amountRequested,
    this.currency = 'USD',
    required this.status,
    this.priorityScore,
    this.description,
    this.files = const [],
    this.aiRecommendations = const [],
    this.globalAiScore,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case ProjectStatus.draft: return 'Brouillon';
      case ProjectStatus.submitted: return 'Soumis';
      case ProjectStatus.analyzing: return 'En analyse';
      case ProjectStatus.aiReview: return 'Analyse IA en cours';
      case ProjectStatus.humanReview: return 'En validation humaine';
      case ProjectStatus.approved: return 'Approuvé';
      case ProjectStatus.rejected: return 'Rejeté';
      case ProjectStatus.pendingInfo: return 'Complément requis';
    }
  }

  int get statusStep {
    switch (status) {
      case ProjectStatus.draft: return 0;
      case ProjectStatus.submitted: return 1;
      case ProjectStatus.analyzing: return 2;
      case ProjectStatus.aiReview: return 2;
      case ProjectStatus.humanReview: return 3;
      case ProjectStatus.approved: return 4;
      case ProjectStatus.rejected: return 4;
      case ProjectStatus.pendingInfo: return 3;
    }
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      userId: json['user_id'],
      orgId: json['org_id'],
      title: json['title'],
      type: json['type'],
      sector: json['sector'],
      amountRequested: (json['amount_requested'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: _parseStatus(json['status']),
      priorityScore: json['priority_score'] != null
          ? (json['priority_score'] as num).toDouble()
          : null,
      description: json['description'],
      files: (json['files'] as List<dynamic>?)
          ?.map((f) => ProjectFile.fromJson(f))
          .toList() ?? [],
      aiRecommendations: (json['ai_recommendations'] as List<dynamic>?)
          ?.map((r) => AiRecommendation.fromJson(r))
          .toList() ?? [],
      globalAiScore: json['global_ai_score'] != null
          ? (json['global_ai_score'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static ProjectStatus _parseStatus(String? s) {
    switch (s) {
      case 'submitted': return ProjectStatus.submitted;
      case 'analyzing': return ProjectStatus.analyzing;
      case 'ai_review': return ProjectStatus.aiReview;
      case 'human_review': return ProjectStatus.humanReview;
      case 'approved': return ProjectStatus.approved;
      case 'rejected': return ProjectStatus.rejected;
      case 'pending_info': return ProjectStatus.pendingInfo;
      default: return ProjectStatus.draft;
    }
  }

  @override
  List<Object?> get props => [id, title, status, updatedAt];
}
