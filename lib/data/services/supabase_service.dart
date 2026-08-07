import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralised Supabase client for the RawBank app.
/// Initialised once in main() before runApp().
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  static const String url = 'https://kblhgqvpoteyctszmkgd.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtibGhncXZwb3RleWN0c3pta2dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODkzNjgsImV4cCI6MjEwMDA2NTM2OH0.ruVozen0xcdQqSTVABDo-K-eE003te0aFrEkTJ4FCHo';

  static SupabaseClient get client => Supabase.instance.client;

  /// Call in main() before runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
  }

  // ── Auth shortcuts ──────────────────────────────
  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return client.auth.signUp(
      email: email,
      password: password,
      data: data ?? {},
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ── User Profile ───────────────────────────────
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final res = await client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return res;
  }

  static Future<Map<String, dynamic>?> upsertUserProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return client.from('user_profiles').upsert({
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'kyc_status': 'pending',
    }).select().maybeSingle();
  }

  // ── IllicoCash Transactions ────────────────────
  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('illicocash_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<Map<String, dynamic>?> createTransaction({
    required String type,
    required double amount,
    String currency = 'USD',
    String? recipientPhone,
    String? recipientName,
    String? description,
    double? exchangeRate,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return client.from('illicocash_transactions').insert({
      'user_id': userId,
      'transaction_type': type,
      'amount': amount,
      'currency': currency,
      'recipient_phone': recipientPhone,
      'recipient_name': recipientName,
      'description': description,
      'exchange_rate': exchangeRate,
      'status': 'completed',
    }).select().maybeSingle();
  }

  // ── Projects ───────────────────────────────────
  static Future<List<Map<String, dynamic>>> getProjects() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('projects')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<Map<String, dynamic>?> createProject({
    required String projectName,
    required String projectDescription,
    String? sector,
    String? rseEsgCategory,
    String? rseEsgDescription,
    required String fundingType,
    required double requestedAmount,
    double? interestRate,
    double? projectedRevenue,
    double? bankProfitShare,
    double? roiPercentage,
    String? businessPlanUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return client.from('projects').insert({
      'user_id': userId,
      'project_name': projectName,
      'project_description': projectDescription,
      'sector': sector,
      'rse_esg_category': rseEsgCategory,
      'rse_esg_description': rseEsgDescription,
      'funding_type': fundingType,
      'requested_amount': requestedAmount,
      'interest_rate': interestRate,
      'projected_revenue': projectedRevenue,
      'bank_profit_share': bankProfitShare,
      'roi_percentage': roiPercentage,
      'business_plan_url': businessPlanUrl,
      'status': 'submitted',
    }).select().maybeSingle();
  }

  // ── KYC Documents ───────────────────────────────
  static Future<List<Map<String, dynamic>>> getKycDocuments() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('kyc_documents')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<Map<String, dynamic>?> uploadKycDocument({
    required String documentType,
    required String documentUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return client.from('kyc_documents').insert({
      'user_id': userId,
      'document_type': documentType,
      'document_url': documentUrl,
      'status': 'pending',
    }).select().maybeSingle();
  }

  // ── Chat ───────────────────────────────────────
  static Future<Map<String, dynamic>?> createChatSession({
    String agentType = 'routeur',
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return client.from('chat_sessions').insert({
      'user_id': userId,
      'agent_type': agentType,
      'status': 'active',
    }).select().maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(String sessionId) async {
    final res = await client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> sendChatMessage({
    required String sessionId,
    required String sender,
    required String messageText,
    String? agentType,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await client.from('chat_messages').insert({
      'session_id': sessionId,
      'user_id': userId,
      'sender': sender,
      'agent_type': agentType,
      'message_text': messageText,
    });
  }

  // ── Notifications ───────────────────────────────
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final res = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // ── Exchange Rates ─────────────────────────────
  static Future<List<Map<String, dynamic>>> getExchangeRates() async {
    final res = await client
        .from('exchange_rates')
        .select()
        .eq('is_active', true)
        .order('updated_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ── Admin ──────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    final res = await client
        .from('projects')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
    final res = await client
        .from('user_profiles')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> updateProjectStatus({
    required String projectId,
    required String status,
    String? reviewNotes,
  }) async {
    await client.from('projects').update({
      'status': status,
      'review_notes': reviewNotes,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', projectId);
  }
}
