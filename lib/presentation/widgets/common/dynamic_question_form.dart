import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/account_opening_question.dart';

/// Renders a list of [AccountOpeningQuestion] and collects the answers into
/// a Map<String, dynamic> (question id -> answer), reused across every
/// account-opening flow in the app so each product asks its own real
/// questions instead of a single generic form.
class DynamicQuestionForm extends StatefulWidget {
  final List<AccountOpeningQuestion> questions;
  final Map<String, dynamic> initialAnswers;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DynamicQuestionForm({
    super.key,
    required this.questions,
    required this.onChanged,
    this.initialAnswers = const {},
  });

  @override
  State<DynamicQuestionForm> createState() => DynamicQuestionFormState();
}

class DynamicQuestionFormState extends State<DynamicQuestionForm> {
  late Map<String, dynamic> _answers;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _answers = Map<String, dynamic>.from(widget.initialAnswers);
    for (final q in widget.questions) {
      if (q.inputType == QuestionInputType.text ||
          q.inputType == QuestionInputType.number ||
          q.inputType == QuestionInputType.multiline) {
        _controllers[q.id] = TextEditingController(text: _answers[q.id]?.toString() ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(String id, dynamic value) {
    setState(() => _answers[id] = value);
    widget.onChanged(_answers);
  }

  /// Returns the ids of required questions still unanswered — used by the
  /// parent screen to block "Continuer" until the questionnaire is complete.
  List<String> missingRequired() {
    final missing = <String>[];
    for (final q in widget.questions) {
      if (!q.required) continue;
      final v = _answers[q.id];
      if (v == null || (v is String && v.trim().isEmpty)) missing.add(q.label);
    }
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final q in widget.questions) ...[
          _buildQuestion(q),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildQuestion(AccountOpeningQuestion q) {
    switch (q.inputType) {
      case QuestionInputType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: _answers[q.id] as String?,
          decoration: _decoration(q),
          items: q.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => _update(q.id, v),
        );
      case QuestionInputType.boolean:
        final value = _answers[q.id] as bool?;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  children: [
                    Icon(q.icon, size: 18, color: AppColors.grey500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(q.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      dense: true,
                      title: const Text('Oui', style: TextStyle(fontSize: 13)),
                      value: true,
                      groupValue: value,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _update(q.id, v),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      dense: true,
                      title: const Text('Non', style: TextStyle(fontSize: 13)),
                      value: false,
                      groupValue: value,
                      activeColor: AppColors.primary,
                      onChanged: (v) => _update(q.id, v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case QuestionInputType.date:
        final selected = _answers[q.id] as DateTime?;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
            );
            if (picked != null) _update(q.id, picked);
          },
          child: InputDecorator(
            decoration: _decoration(q),
            child: Text(
              selected != null
                  ? '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}'
                  : 'Sélectionner une date',
              style: TextStyle(fontSize: 14, color: selected != null ? AppColors.textPrimary : AppColors.grey500),
            ),
          ),
        );
      case QuestionInputType.number:
        return TextFormField(
          controller: _controllers[q.id],
          keyboardType: TextInputType.number,
          decoration: _decoration(q),
          onChanged: (v) => _update(q.id, v),
        );
      case QuestionInputType.multiline:
        return TextFormField(
          controller: _controllers[q.id],
          maxLines: 3,
          decoration: _decoration(q),
          onChanged: (v) => _update(q.id, v),
        );
      case QuestionInputType.text:
        return TextFormField(
          controller: _controllers[q.id],
          decoration: _decoration(q),
          onChanged: (v) => _update(q.id, v),
        );
    }
  }

  InputDecoration _decoration(AccountOpeningQuestion q) {
    return InputDecoration(
      labelText: q.required ? '${q.label} *' : q.label,
      hintText: q.hint,
      prefixIcon: Icon(q.icon, size: 20, color: AppColors.grey500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.grey300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.grey300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}
