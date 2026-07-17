import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _transferType = 'illico'; // illico | bank
  String _currency = 'USD';
  bool _saveBeneficiary = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _TransferSuccess(
          amount: _amountCtrl.text,
          recipient: _recipientCtrl.text,
          currency: _currency,
          onClose: () => context.pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Virement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transfer type selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TypeChip(
                      label: 'IllicoCash',
                      icon: Icons.flash_on,
                      selected: _transferType == 'illico',
                      onTap: () => setState(() => _transferType = 'illico'),
                    ),
                    _TypeChip(
                      label: 'Compte bancaire',
                      icon: Icons.account_balance,
                      selected: _transferType == 'bank',
                      onTap: () => setState(() => _transferType = 'bank'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // From
              _AccountChip(
                label: _transferType == 'illico' ? 'IllicoCash' : 'Compte Épargne',
                balance: '\$2,450.75',
                isFrom: true,
              ),
              const SizedBox(height: 12),

              // Arrow
              const Center(child: Icon(Icons.south, color: AppColors.grey500)),
              const SizedBox(height: 12),

              // Recipient
              TextFormField(
                controller: _recipientCtrl,
                decoration: InputDecoration(
                  labelText: _transferType == 'illico'
                      ? 'Numéro IllicoCash du destinataire *'
                      : 'Numéro de compte *',
                  hintText: _transferType == 'illico'
                      ? 'Ex: +243 810 000 002'
                      : 'Ex: 001-0456789-01',
                  prefixIcon: Icon(_transferType == 'illico'
                      ? Icons.phone_android
                      : Icons.account_balance_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Destinataire requis';
                  if (v.length < 6) return 'Numéro invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffix: _CurrencyToggle(
                    value: _currency,
                    onChanged: (v) => setState(() => _currency = v),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Montant requis';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Montant invalide';
                  if (n > 2450.75) return 'Solde insuffisant';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quick amounts
              Row(
                children: [10, 50, 100, 500].map((amt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text('\$$amt'),
                      onPressed: () => _amountCtrl.text = amt.toString(),
                      backgroundColor: AppColors.grey100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                  hintText: 'Motif du transfert...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Save beneficiary
              CheckboxListTile(
                value: _saveBeneficiary,
                onChanged: (v) => setState(() => _saveBeneficiary = v ?? false),
                title: const Text('Sauvegarder comme bénéficiaire',
                    style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 8),

              // Fee info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Frais: ${_transferType == 'illico' ? '0.5%' : '1.5%'} • Plafond: \$10,000/jour',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Envoyer le virement'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primary : AppColors.grey500),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.grey700,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final String label;
  final String balance;
  final bool isFrom;
  const _AccountChip({required this.label, required this.balance, this.isFrom = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isFrom ? Icons.account_balance_wallet : Icons.account_balance,
              color: AppColors.primary, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isFrom ? 'De' : 'Vers',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
          Text(balance,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isFrom ? AppColors.textPrimary : AppColors.success)),
        ],
      ),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CurrencyToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: ['USD', 'CDF'].map((c) => c == value).toList(),
      onPressed: (i) => onChanged(['USD', 'CDF'][i]),
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      borderColor: AppColors.grey300,
      selectedBorderColor: AppColors.primary,
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('USD', style: TextStyle(fontSize: 12))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('CDF', style: TextStyle(fontSize: 12))),
      ],
    );
  }
}

class _TransferSuccess extends StatelessWidget {
  final String amount;
  final String recipient;
  final String currency;
  final VoidCallback onClose;
  const _TransferSuccess({
    required this.amount,
    required this.recipient,
    required this.currency,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Virement envoyé !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              '\$$amount $currency',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text('vers $recipient',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            const Text('REF: TRX-${DateTime.now().millisecondsSinceEpoch}',
                style: TextStyle(color: AppColors.grey500, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                child: const Text('Terminé'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
