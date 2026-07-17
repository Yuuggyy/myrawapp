import 'package:flutter/material.dart';
import 'models/account_opening_question.dart';
import 'models/business_sector.dart';

/// Real bank-style questionnaires, one set per account type. This is what
/// makes "Ouvrir un compte" in MyRawApp actually behave like a real RawBank
/// account opening instead of a generic sign-up form.
///
/// Every account type gets:
///  1. the shared KYC / compliance base (identity, income, PEP, objectif...)
///  2. questions specific to that product (illico, courant, épargne,
///     entreprise, investissement)
class AccountOpeningQuestions {
  AccountOpeningQuestions._();

  /// Asked for every individual account type (illico, current, savings,
  /// investment) — this is the base KYC every DRC bank requires before
  /// activating a product, on top of name / phone / PIN.
  static const List<AccountOpeningQuestion> baseIndividualKyc = [
    AccountOpeningQuestion(
      id: 'birth_date',
      label: 'Date de naissance',
      inputType: QuestionInputType.date,
      icon: Icons.cake_outlined,
    ),
    AccountOpeningQuestion(
      id: 'birth_place',
      label: 'Lieu de naissance',
      hint: 'Ville, Province',
      icon: Icons.place_outlined,
    ),
    AccountOpeningQuestion(
      id: 'nationality',
      label: 'Nationalité',
      hint: 'Congolaise (RDC)',
      icon: Icons.flag_outlined,
    ),
    AccountOpeningQuestion(
      id: 'address',
      label: 'Adresse de résidence',
      hint: 'Avenue, Commune, Ville',
      icon: Icons.home_outlined,
    ),
    AccountOpeningQuestion(
      id: 'id_document_type',
      label: "Type de pièce d'identité",
      inputType: QuestionInputType.dropdown,
      options: ["Carte d'électeur", 'Passeport', "Carte d'identité nationale", 'Permis de conduire'],
      icon: Icons.badge_outlined,
    ),
    AccountOpeningQuestion(
      id: 'id_document_number',
      label: 'Numéro de la pièce',
      icon: Icons.numbers_outlined,
    ),
    AccountOpeningQuestion(
      id: 'occupation',
      label: 'Profession / Employeur',
      hint: 'Ex: Enseignant — Lycée Boboto',
      icon: Icons.work_outline,
    ),
    AccountOpeningQuestion(
      id: 'income_source',
      label: 'Source principale des revenus',
      inputType: QuestionInputType.dropdown,
      options: ['Salaire', 'Activité commerciale', 'Revenus locatifs', 'Pension', 'Aide familiale', 'Autre'],
      icon: Icons.payments_outlined,
    ),
    AccountOpeningQuestion(
      id: 'monthly_income',
      label: 'Revenu mensuel estimé',
      inputType: QuestionInputType.dropdown,
      options: ['< 500 \$', '500 – 1 500 \$', '1 500 – 5 000 \$', '> 5 000 \$'],
      icon: Icons.trending_up,
    ),
    AccountOpeningQuestion(
      id: 'account_purpose',
      label: 'Objectif principal du compte',
      inputType: QuestionInputType.dropdown,
      options: [
        'Épargne',
        'Transactions quotidiennes',
        'Salaire / domiciliation',
        'Investissement',
        'Transferts internationaux',
      ],
      icon: Icons.flag_circle_outlined,
    ),
    AccountOpeningQuestion(
      id: 'monthly_volume',
      label: 'Volume de transactions mensuel estimé',
      inputType: QuestionInputType.dropdown,
      options: ['< 200 \$', '200 – 1 000 \$', '1 000 – 5 000 \$', '> 5 000 \$'],
      icon: Icons.swap_horiz,
    ),
    AccountOpeningQuestion(
      id: 'other_bank_account',
      label: 'Détenez-vous déjà un compte dans une autre banque ?',
      inputType: QuestionInputType.boolean,
      icon: Icons.account_balance_outlined,
    ),
    AccountOpeningQuestion(
      id: 'is_pep',
      label: 'Êtes-vous une Personne Politiquement Exposée (PPE) ou un proche ?',
      hint: 'Mandat public, haute fonction, famille proche d\'un dirigeant...',
      inputType: QuestionInputType.boolean,
      icon: Icons.gavel_outlined,
    ),
  ];

  static const List<AccountOpeningQuestion> illico = [
    AccountOpeningQuestion(
      id: 'illico_usage',
      label: 'Usage principal prévu',
      inputType: QuestionInputType.dropdown,
      options: ['Paiements marchands', 'Transferts familiaux', 'Réception de salaire', 'Épargne mobile'],
      icon: Icons.smartphone_outlined,
    ),
  ];

  static const List<AccountOpeningQuestion> current = [
    AccountOpeningQuestion(
      id: 'wants_checkbook',
      label: 'Souhaitez-vous un chéquier ?',
      inputType: QuestionInputType.boolean,
      icon: Icons.receipt_long_outlined,
    ),
    AccountOpeningQuestion(
      id: 'card_type',
      label: 'Type de carte de débit souhaitée',
      inputType: QuestionInputType.dropdown,
      options: ['Standard', 'Gold', 'Platinum'],
      icon: Icons.credit_card_outlined,
    ),
  ];

  static const List<AccountOpeningQuestion> savings = [
    AccountOpeningQuestion(
      id: 'savings_goal',
      label: "Objectif d'épargne",
      inputType: QuestionInputType.dropdown,
      options: ['Achat immobilier', 'Études', 'Retraite', "Fonds d'urgence", 'Projet personnel'],
      icon: Icons.savings_outlined,
    ),
    AccountOpeningQuestion(
      id: 'initial_deposit',
      label: 'Montant du dépôt initial (\$)',
      inputType: QuestionInputType.number,
      icon: Icons.attach_money,
    ),
    AccountOpeningQuestion(
      id: 'deposit_frequency',
      label: 'Fréquence de versement prévue',
      inputType: QuestionInputType.dropdown,
      options: ['Mensuelle', 'Trimestrielle', 'Ponctuelle'],
      icon: Icons.event_repeat_outlined,
    ),
  ];

  static const List<AccountOpeningQuestion> investment = [
    AccountOpeningQuestion(
      id: 'risk_profile',
      label: 'Profil de risque',
      inputType: QuestionInputType.dropdown,
      options: ['Prudent', 'Équilibré', 'Dynamique'],
      icon: Icons.speed_outlined,
    ),
    AccountOpeningQuestion(
      id: 'investment_horizon',
      label: "Horizon d'investissement",
      inputType: QuestionInputType.dropdown,
      options: ['< 1 an', '1 – 3 ans', '3 – 5 ans', '> 5 ans'],
      icon: Icons.schedule_outlined,
    ),
    AccountOpeningQuestion(
      id: 'investment_experience',
      label: "Expérience en investissement",
      inputType: QuestionInputType.dropdown,
      options: ['Aucune', 'Débutant', 'Expérimenté'],
      icon: Icons.school_outlined,
    ),
    AccountOpeningQuestion(
      id: 'investment_objective',
      label: "Objectif principal",
      inputType: QuestionInputType.dropdown,
      options: ['Croissance du capital', 'Revenu régulier', 'Retraite', 'Transmission patrimoniale'],
      icon: Icons.insights_outlined,
    ),
    AccountOpeningQuestion(
      id: 'initial_investment',
      label: 'Montant à investir initialement (\$)',
      inputType: QuestionInputType.number,
      icon: Icons.attach_money,
    ),
  ];

  /// Enterprise accounts don't use the individual KYC base — they need a
  /// company-level questionnaire instead, plus the sector is pulled from
  /// [BusinessSectors] so the required regulatory documents already match.
  static const List<AccountOpeningQuestion> enterpriseBase = [
    AccountOpeningQuestion(
      id: 'company_name',
      label: 'Raison sociale',
      icon: Icons.apartment_outlined,
    ),
    AccountOpeningQuestion(
      id: 'legal_form',
      label: 'Forme juridique',
      inputType: QuestionInputType.dropdown,
      options: ['SARL', 'SA', 'SPRL', 'Entreprise individuelle', 'Coopérative'],
      icon: Icons.gavel_outlined,
    ),
    AccountOpeningQuestion(
      id: 'legal_representative',
      label: 'Représentant légal',
      icon: Icons.person_pin_outlined,
    ),
    AccountOpeningQuestion(
      id: 'share_capital',
      label: 'Capital social (\$)',
      inputType: QuestionInputType.number,
      icon: Icons.account_balance_outlined,
    ),
    AccountOpeningQuestion(
      id: 'annual_revenue',
      label: "Chiffre d'affaires annuel estimé",
      inputType: QuestionInputType.dropdown,
      options: ['< 10 000 \$', '10 000 – 100 000 \$', '100 000 – 1M \$', '> 1M \$'],
      icon: Icons.stacked_line_chart_outlined,
    ),
    AccountOpeningQuestion(
      id: 'employee_count',
      label: "Nombre d'employés",
      inputType: QuestionInputType.number,
      icon: Icons.groups_outlined,
    ),
    AccountOpeningQuestion(
      id: 'shareholding_structure',
      label: 'Structure actionnariale (principal actionnaire + %)',
      hint: 'Ex: Jean Kabila — 60%',
      icon: Icons.pie_chart_outline,
    ),
    AccountOpeningQuestion(
      id: 'wants_credit_line',
      label: 'Souhaitez-vous une ligne de crédit ?',
      inputType: QuestionInputType.boolean,
      icon: Icons.credit_score_outlined,
    ),
  ];

  /// Sector names sourced from BusinessSectors so the dropdown always stays
  /// in sync with the regulatory-document list used elsewhere in the app.
  static List<String> get sectorOptions => BusinessSectors.sectorNames;

  /// Returns the full ordered question list for a given account type id
  /// ('illico' | 'current' | 'savings' | 'enterprise' | 'investment').
  static List<AccountOpeningQuestion> forType(String accountType) {
    switch (accountType) {
      case 'illico':
        return [...baseIndividualKyc, ...illico];
      case 'current':
        return [...baseIndividualKyc, ...current];
      case 'savings':
        return [...baseIndividualKyc, ...savings];
      case 'investment':
        return [...baseIndividualKyc, ...investment];
      case 'enterprise':
        return [
          ...enterpriseBase,
          AccountOpeningQuestion(
            id: 'business_sector',
            label: "Secteur d'activité",
            inputType: QuestionInputType.dropdown,
            options: sectorOptions,
            icon: Icons.category_outlined,
          ),
        ];
      default:
        return baseIndividualKyc;
    }
  }
}
