import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'project_model.dart';

/// Admin dashboard statistics model
class AdminStats extends Equatable {
  final int totalUsers;
  final int totalProjects;
  final int pendingProjects;
  final int approvedProjects;
  final int rejectedProjects;
  final int totalRequests;
  final double totalFundingRequested;
  final int activeAiAgents;

  const AdminStats({
    required this.totalUsers,
    required this.totalProjects,
    required this.pendingProjects,
    required this.approvedProjects,
    required this.rejectedProjects,
    required this.totalRequests,
    required this.totalFundingRequested,
    required this.activeAiAgents,
  });

  @override
  List<Object?> get props => [totalUsers, totalProjects, pendingProjects];
}

/// Admin user management model
class AdminUser extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final KycLevel kycLevel;
  final bool isActive;
  final DateTime? createdAt;
  final int projectCount;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.kycLevel,
    required this.isActive,
    this.createdAt,
    this.projectCount = 0,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.client: return 'Client';
      case UserRole.agent: return 'Agent';
      case UserRole.manager: return 'Manager';
      case UserRole.admin: return 'Admin';
      case UserRole.superAdmin: return 'Super Admin';
    }
  }

  @override
  List<Object?> get props => [id, email];
}

/// Request/submission types handled by the back-office
enum RequestType {
  projectSubmission,
  kycVerification,
  accountOpening,
  loanRequest,
  partnershipRequest,
  complaint,
}

extension RequestTypeExt on RequestType {
  String get label {
    switch (this) {
      case RequestType.projectSubmission: return 'Soumission projet';
      case RequestType.kycVerification: return 'Vérification KYC';
      case RequestType.accountOpening: return 'Ouverture compte';
      case RequestType.loanRequest: return 'Demande prêt';
      case RequestType.partnershipRequest: return 'Partenariat';
      case RequestType.complaint: return 'Réclamation';
    }
  }

  IconData get icon {
    switch (this) {
      case RequestType.projectSubmission: return Icons.folder_open;
      case RequestType.kycVerification: return Icons.verified_user;
      case RequestType.accountOpening: return Icons.account_balance;
      case RequestType.loanRequest: return Icons.attach_money;
      case RequestType.partnershipRequest: return Icons.handshake;
      case RequestType.complaint: return Icons.report_problem;
    }
  }

  Color get color {
    switch (this) {
      case RequestType.projectSubmission: return const Color(0xFFF0B000);
      case RequestType.kycVerification: return const Color(0xFF1565C0);
      case RequestType.accountOpening: return const Color(0xFF2E7D32);
      case RequestType.loanRequest: return const Color(0xFFE65100);
      case RequestType.partnershipRequest: return const Color(0xFF6A1B9A);
      case RequestType.complaint: return const Color(0xFFC62828);
    }
  }
}

/// Admin request model
class AdminRequest extends Equatable {
  final String id;
  final RequestType type;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String status; // pending, processing, resolved, rejected
  final DateTime? createdAt;
  final double? amount;

  const AdminRequest({
    required this.id,
    required this.type,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.amount,
  });

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'processing': return 'En traitement';
      case 'resolved': return 'Résolu';
      case 'rejected': return 'Rejeté';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return const Color(0xFFF57F17);
      case 'processing': return const Color(0xFF0277BD);
      case 'resolved': return const Color(0xFF2E7D32);
      case 'rejected': return const Color(0xFFC62828);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  List<Object?> get props => [id, type, status];
}

/// AI Agent status for admin hub
class AiAgentStatus extends Equatable {
  final String agentId;
  final String name;
  final String description;
  final bool isActive;
  final int queriesToday;
  final int totalQueries;
  final double avgScore;
  final Color color;
  final IconData icon;

  const AiAgentStatus({
    required this.agentId,
    required this.name,
    required this.description,
    required this.isActive,
    required this.queriesToday,
    required this.totalQueries,
    required this.avgScore,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [agentId];
}
