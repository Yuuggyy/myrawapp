import 'dart:async';
import 'dart:math';

/// Mock IllicoCash API Service
/// Simule l'API IllicoCash de RawBank pour le développement
/// Remplacer par l'API réelle quand elle sera disponible

class IllicoCashApi {
  static final IllicoCashApi _instance = IllicoCashApi._internal();
  factory IllicoCashApi() => _instance;
  IllicoCashApi._internal();

  // Simulated database
  final Map<String, _MockAccount> _accounts = {};
  final List<_MockTransaction> _transactions = [];

  // Initialize with demo data
  void init() {
    if (_accounts.isNotEmpty) return;
    _accounts['+243810000001'] = _MockAccount(
      phone: '+243810000001',
      name: 'Jean Mutombo',
      balanceUsd: 2450.75,
      balanceCdf: 7450250,
      pin: '1234',
      kycLevel: 'standard',
    );
    _accounts['+243810000002'] = _MockAccount(
      phone: '+243810000002',
      name: 'Sarah Kasa',
      balanceUsd: 820.00,
      balanceCdf: 2497000,
      pin: '5678',
      kycLevel: 'basic',
    );
    _accounts['+243810000003'] = _MockAccount(
      phone: '+243810000003',
      name: 'Joseph Tshisekedi',
      balanceUsd: 3500.50,
      balanceCdf: 10646000,
      pin: '4321',
      kycLevel: 'advanced',
    );

    // Seed some transactions
    _transactions.addAll([
      _MockTransaction(
        id: 'TRX-001', from: 'BANK', to: '+243810000001',
        amount: 500, currency: 'USD', type: 'deposit',
        description: 'Dépôt agence RawBank Gombe',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'completed',
      ),
      _MockTransaction(
        id: 'TRX-002', from: '+243810000001', to: 'MERCHANT',
        amount: 49.50, currency: 'USD', type: 'payment',
        description: 'Frais dossier PME',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: 'completed',
      ),
      _MockTransaction(
        id: 'TRX-003', from: '+243810000001', to: '+243810000002',
        amount: 200, currency: 'USD', type: 'transfer',
        description: 'Transfert IllicoCash → Sarah Kasa',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
      ),
    ]);
  }

  // ── Simulated API delay ──
  Future<T> _delay<T>(T value, {int ms = 800}) async {
    await Future.delayed(Duration(milliseconds: ms));
    return value;
  }

  // ── Account endpoints ──

  /// GET /api/illicocash/balance/{phone}
  Future<Map<String, dynamic>> getBalance(String phone) {
    init();
    final acc = _accounts[phone];
    if (acc == null) return _delay({'success': false, 'error': 'Compte introuvable'});
    return _delay({
      'success': true,
      'data': {
        'phone': acc.phone,
        'name': acc.name,
        'balance_usd': acc.balanceUsd,
        'balance_cdf': acc.balanceCdf,
        'kyc_level': acc.kycLevel,
        'currency': 'USD',
      }
    });
  }

  /// POST /api/illicocash/create
  Future<Map<String, dynamic>> createAccount({
    required String phone,
    required String name,
    required String pin,
    String kycLevel = 'basic',
  }) {
    init();
    if (_accounts.containsKey(phone)) {
      return _delay({'success': false, 'error': 'Ce numéro existe déjà'});
    }
    _accounts[phone] = _MockAccount(
      phone: phone, name: name, balanceUsd: 0, balanceCdf: 0,
      pin: pin, kycLevel: kycLevel,
    );
    return _delay({
      'success': true,
      'data': {'phone': phone, 'name': name, 'balance_usd': 0, 'balance_cdf': 0, 'kyc_level': kycLevel}
    });
  }

  /// POST /api/illicocash/transfer
  Future<Map<String, dynamic>> transfer({
    required String fromPhone,
    required String toPhone,
    required double amount,
    required String currency,
    required String pin,
    String? note,
  }) {
    init();
    final from = _accounts[fromPhone];
    final to = _accounts[toPhone];

    if (from == null) return _delay({'success': false, 'error': 'Compte émetteur introuvable'});
    if (to == null) return _delay({'success': false, 'error': 'Destinataire introuvable'});
    if (from.pin != pin) return _delay({'success': false, 'error': 'PIN incorrect'});
    if (amount <= 0) return _delay({'success': false, 'error': 'Montant invalide'});

    // Check balance
    if (currency == 'USD' && from.balanceUsd < amount) {
      return _delay({'success': false, 'error': 'Solde insuffisant'});
    }
    if (currency == 'CDF' && from.balanceCdf < amount) {
      return _delay({'success': false, 'error': 'Solde insuffisant'});
    }

    // Calculate fee (0.5% for IllicoCash transfer)
    final fee = amount * 0.005;
    final totalDeduct = amount + fee;

    // Execute transfer
    if (currency == 'USD') {
      from.balanceUsd -= totalDeduct;
      to.balanceUsd += amount;
    } else {
      from.balanceCdf -= totalDeduct;
      to.balanceCdf += amount;
    }

    final trxId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    _transactions.add(_MockTransaction(
      id: trxId, from: fromPhone, to: toPhone,
      amount: amount, currency: currency, type: 'transfer',
      description: note ?? 'Transfert IllicoCash → ${to.name}',
      timestamp: DateTime.now(), status: 'completed',
    ));

    return _delay({
      'success': true,
      'data': {
        'transaction_id': trxId,
        'amount': amount,
        'fee': fee,
        'total_deducted': totalDeduct,
        'currency': currency,
        'recipient': to.name,
        'recipient_phone': toPhone,
        'new_balance': currency == 'USD' ? from.balanceUsd : from.balanceCdf,
        'timestamp': DateTime.now().toIso8601String(),
      }
    });
  }

  /// POST /api/illicocash/deposit
  Future<Map<String, dynamic>> deposit({
    required String phone,
    required double amount,
    required String currency,
    String? method, // 'bank' | 'cash' | 'mobile_money'
  }) {
    init();
    final acc = _accounts[phone];
    if (acc == null) return _delay({'success': false, 'error': 'Compte introuvable'});
    if (amount <= 0) return _delay({'success': false, 'error': 'Montant invalide'});

    if (currency == 'USD') {
      acc.balanceUsd += amount;
    } else {
      acc.balanceCdf += amount;
    }

    final trxId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    _transactions.add(_MockTransaction(
      id: trxId, from: 'BANK', to: phone,
      amount: amount, currency: currency, type: 'deposit',
      description: 'Dépôt ${method ?? 'bank'}',
      timestamp: DateTime.now(), status: 'completed',
    ));

    return _delay({
      'success': true,
      'data': {
        'transaction_id': trxId,
        'amount': amount,
        'currency': currency,
        'new_balance': currency == 'USD' ? acc.balanceUsd : acc.balanceCdf,
        'method': method ?? 'bank',
      }
    });
  }

  /// POST /api/illicocash/withdraw
  Future<Map<String, dynamic>> withdraw({
    required String phone,
    required double amount,
    required String currency,
    required String pin,
  }) {
    init();
    final acc = _accounts[phone];
    if (acc == null) return _delay({'success': false, 'error': 'Compte introuvable'});
    if (acc.pin != pin) return _delay({'success': false, 'error': 'PIN incorrect'});
    if (amount <= 0) return _delay({'success': false, 'error': 'Montant invalide'});

    final fee = amount * 0.01; // 1% withdrawal fee

    if (currency == 'USD' && acc.balanceUsd < amount + fee) {
      return _delay({'success': false, 'error': 'Solde insuffisant (incl. frais)'});
    }
    if (currency == 'CDF' && acc.balanceCdf < amount + fee) {
      return _delay({'success': false, 'error': 'Solde insuffisant (incl. frais)'});
    }

    if (currency == 'USD') {
      acc.balanceUsd -= amount + fee;
    } else {
      acc.balanceCdf -= amount + fee;
    }

    final trxId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    _transactions.add(_MockTransaction(
      id: trxId, from: phone, to: 'BANK',
      amount: amount, currency: currency, type: 'withdraw',
      description: 'Retrait IllicoCash',
      timestamp: DateTime.now(), status: 'completed',
    ));

    return _delay({
      'success': true,
      'data': {
        'transaction_id': trxId,
        'amount': amount,
        'fee': fee,
        'total_deducted': amount + fee,
        'currency': currency,
        'new_balance': currency == 'USD' ? acc.balanceUsd : acc.balanceCdf,
      }
    });
  }

  /// POST /api/illicocash/pay-merchant
  Future<Map<String, dynamic>> payMerchant({
    required String fromPhone,
    required String merchantId,
    required double amount,
    required String currency,
    required String pin,
    String? note,
  }) {
    init();
    final from = _accounts[fromPhone];
    if (from == null) return _delay({'success': false, 'error': 'Compte introuvable'});
    if (from.pin != pin) return _delay({'success': false, 'error': 'PIN incorrect'});
    if (amount <= 0) return _delay({'success': false, 'error': 'Montant invalide'});

    final fee = amount * 0.005; // 0.5% merchant fee

    if (currency == 'USD' && from.balanceUsd < amount + fee) {
      return _delay({'success': false, 'error': 'Solde insuffisant'});
    }
    if (currency == 'CDF' && from.balanceCdf < amount + fee) {
      return _delay({'success': false, 'error': 'Solde insuffisant'});
    }

    if (currency == 'USD') {
      from.balanceUsd -= amount + fee;
    } else {
      from.balanceCdf -= amount + fee;
    }

    final trxId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    _transactions.add(_MockTransaction(
      id: trxId, from: fromPhone, to: merchantId,
      amount: amount, currency: currency, type: 'payment',
      description: note ?? 'Paiement marchand $merchantId',
      timestamp: DateTime.now(), status: 'completed',
    ));

    return _delay({
      'success': true,
      'data': {
        'transaction_id': trxId,
        'amount': amount,
        'fee': fee,
        'merchant_id': merchantId,
        'currency': currency,
        'new_balance': currency == 'USD' ? from.balanceUsd : from.balanceCdf,
      }
    });
  }

  /// GET /api/illicocash/transactions/{phone}
  Future<Map<String, dynamic>> getTransactions(String phone, {int limit = 20}) {
    init();
    final txs = _transactions
        .where((t) => t.from == phone || t.to == phone)
        .toList()
        .reversed
        .take(limit)
        .toList();

    return _delay({
      'success': true,
      'data': txs.map((t) => {
        'id': t.id,
        'from': t.from,
        'to': t.to,
        'amount': t.amount,
        'currency': t.currency,
        'type': t.type,
        'description': t.description,
        'status': t.status,
        'timestamp': t.timestamp.toIso8601String(),
      }).toList()
    });
  }

  /// GET /api/illicocash/verify/{phone}
  Future<Map<String, dynamic>> verifyRecipient(String phone) {
    init();
    final acc = _accounts[phone];
    if (acc == null) return _delay({'success': false, 'error': 'Numéro non enregistré'});
    return _delay({
      'success': true,
      'data': {'phone': acc.phone, 'name': acc.name, 'kyc_level': acc.kycLevel}
    });
  }

  /// POST /api/illicocash/pin/verify
  Future<Map<String, dynamic>> verifyPin(String phone, String pin) {
    init();
    final acc = _accounts[phone];
    if (acc == null) return _delay({'success': false, 'error': 'Compte introuvable'});
    return _delay({'success': acc.pin == pin});
  }

  /// GET /api/illicocash/exchange-rate
  Future<Map<String, dynamic>> getExchangeRate() {
    // Simulate a rate around 2950 CDF/USD with small variance
    final rate = 2950 + Random().nextInt(50);
    return _delay({
      'success': true,
      'data': {'usd_to_cdf': rate, 'cdf_to_usd': 1 / rate, 'last_updated': DateTime.now().toIso8601String()}
    });
  }
}

class _MockAccount {
  final String phone;
  final String name;
  double balanceUsd;
  double balanceCdf;
  final String pin;
  final String kycLevel;

  _MockAccount({
    required this.phone,
    required this.name,
    required this.balanceUsd,
    required this.balanceCdf,
    required this.pin,
    required this.kycLevel,
  });
}

class _MockTransaction {
  final String id;
  final String from;
  final String to;
  final double amount;
  final String currency;
  final String type;
  final String description;
  final DateTime timestamp;
  final String status;

  _MockTransaction({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}
