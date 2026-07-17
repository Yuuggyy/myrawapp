import 'package:equatable/equatable.dart';

enum AccountType { illicoCash, personal, enterprise, savings }
enum AccountStatus { active, frozen, closed, pending }
enum TransactionType { credit, debit, transfer, fee, refund }

class AccountModel extends Equatable {
  final String id;
  final String userId;
  final AccountType type;
  final double balance;
  final String currency;
  final AccountStatus status;
  final String? accountNumber;
  final DateTime? createdAt;

  const AccountModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.balance,
    required this.currency,
    required this.status,
    this.accountNumber,
    this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case AccountType.illicoCash: return 'IllicoCash';
      case AccountType.personal: return 'Compte Personnel';
      case AccountType.enterprise: return 'Compte Entreprise';
      case AccountType.savings: return 'Compte Épargne';
    }
  }

  String get formattedBalance {
    final formatted = balance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted $currency';
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      userId: json['user_id'],
      type: _parseType(json['type']),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: _parseStatus(json['status']),
      accountNumber: json['account_number'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  static AccountType _parseType(String? t) {
    switch (t) {
      case 'illicoCash': return AccountType.illicoCash;
      case 'enterprise': return AccountType.enterprise;
      case 'savings': return AccountType.savings;
      default: return AccountType.personal;
    }
  }

  static AccountStatus _parseStatus(String? s) {
    switch (s) {
      case 'frozen': return AccountStatus.frozen;
      case 'closed': return AccountStatus.closed;
      case 'pending': return AccountStatus.pending;
      default: return AccountStatus.active;
    }
  }

  @override
  List<Object?> get props => [id, type, balance, currency];
}

class TransactionModel extends Equatable {
  final String id;
  final String accountId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String description;
  final String reference;
  final String status;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.credit || type == TransactionType.refund;

  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      accountId: json['account_id'],
      type: _parseType(json['type']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      status: json['status'] ?? 'completed',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static TransactionType _parseType(String? t) {
    switch (t) {
      case 'debit': return TransactionType.debit;
      case 'transfer': return TransactionType.transfer;
      case 'fee': return TransactionType.fee;
      case 'refund': return TransactionType.refund;
      default: return TransactionType.credit;
    }
  }

  @override
  List<Object?> get props => [id, amount, type, createdAt];
}
