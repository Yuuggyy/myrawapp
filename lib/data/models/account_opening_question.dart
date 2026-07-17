import 'package:flutter/material.dart';

/// How a single opening question should be rendered / answered.
enum QuestionInputType { text, number, dropdown, boolean, date, multiline }

/// One real-world question a bank agent would actually ask a client while
/// opening a specific type of account. These map 1:1 to compliance / KYC
/// fields RawBank (and any bank in the DRC) needs before activating a
/// product — not just generic "name / phone / PIN".
class AccountOpeningQuestion {
  final String id;
  final String label;
  final String? hint;
  final QuestionInputType inputType;
  final List<String> options; // used when inputType == dropdown
  final bool required;
  final IconData icon;

  const AccountOpeningQuestion({
    required this.id,
    required this.label,
    this.hint,
    this.inputType = QuestionInputType.text,
    this.options = const [],
    this.required = true,
    this.icon = Icons.help_outline,
  });
}
