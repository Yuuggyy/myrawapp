import 'package:equatable/equatable.dart';

enum ClientType { individual, enterprise }
enum KycLevel { none, basic, standard, advanced }
enum UserRole { client, agent, manager, admin, superAdmin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final ClientType clientType;
  final KycLevel kycLevel;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    this.clientType = ClientType.individual,
    this.kycLevel = KycLevel.none,
    this.role = UserRole.client,
    this.isActive = true,
    this.createdAt,
    this.lastLoginAt,
  });

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get kycLevelLabel {
    switch (kycLevel) {
      case KycLevel.none: return 'Non vérifié';
      case KycLevel.basic: return 'Basique';
      case KycLevel.standard: return 'Standard';
      case KycLevel.advanced: return 'Avancé';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      clientType: json['client_type'] == 'enterprise'
          ? ClientType.enterprise
          : ClientType.individual,
      kycLevel: _parseKycLevel(json['kyc_level']),
      role: _parseRole(json['role']),
      isActive: json['status'] == 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'client_type': clientType.name,
    'kyc_level': kycLevel.name,
    'role': role.name,
    'status': isActive ? 'active' : 'inactive',
    'created_at': createdAt?.toIso8601String(),
  };

  static KycLevel _parseKycLevel(String? level) {
    switch (level) {
      case 'basic': return KycLevel.basic;
      case 'standard': return KycLevel.standard;
      case 'advanced': return KycLevel.advanced;
      default: return KycLevel.none;
    }
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'agent': return UserRole.agent;
      case 'manager': return UserRole.manager;
      case 'admin': return UserRole.admin;
      case 'super_admin': return UserRole.superAdmin;
      default: return UserRole.client;
    }
  }

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    KycLevel? kycLevel,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      clientType: clientType,
      kycLevel: kycLevel ?? this.kycLevel,
      role: role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [id, email, phone, fullName, kycLevel, role];
}
