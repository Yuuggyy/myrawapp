import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Bonjour ! Je suis RawBot, votre assistant IA RawBank. Comment puis-je vous aider aujourd\'hui ?', 'isBot': true},
    {'text': 'Je voudrais déposer un dossier de financement pour mon projet agricole.', 'isBot': false},
    {'text': 'Parfait ! Pour un financement agricole, vous aurez besoin : \n1. Plan d\'affaires\n2. Justificatif de propriété\n3. Relevés bancaires (3 mois)\n\nVoulez-vous commencer le dépôt maintenant ?', 'isBot': true},
  ];

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _ctrl.text.trim(), 'isBot': false});
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() {
        _messages.add({'text': 'Je traite votre demande... Un conseiller RawBank vous contactera sous 24h.', 'isBot': true});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RawBot', style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
            Text('Assistant IA RawBank', style: GoogleFonts.poppins(
              fontSize: 11, color: AppColors.gold)),
          ]),
        ]),
      ),
      body: Column(children: [
        Divider(height: 1, color: divider),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final msg = _messages[i];
              final isBot = msg['isBot'] as bool;
              return Align(
                alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  decoration: BoxDecoration(
                    color: isBot ? card : AppColors.gold,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isBot ? 4 : 16),
                      bottomRight: Radius.circular(isBot ? 16 : 4),
                    ),
                    border: isBot ? Border.all(color: divider, width: 0.5) : null,
                  ),
                  child: Text(msg['text'] as String, style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isBot ? textPrimary : Colors.white,
                    height: 1.5)),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: divider, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Posez votre question...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    filled: true,
                    fillColor: surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
