import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/common/raw_button.dart';
import '../../widgets/common/raw_text_field.dart';

/// Simple app account creation — this is NOT bank account opening.
/// Just enough to create a MyRawApp login: name, email, password, avatar.
/// Bank account type (Particulier / Entreprise) is chosen later, once
/// logged in, from the Comptes tab.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _avatarFile;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(sheetContext);
                _selectImage(ImageSource.gallery);
              },
            ),
            if (_avatarFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Retirer la photo', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => _avatarFile = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _avatarFile = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'accéder à la caméra/galerie sur cet appareil.")),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      await ApiService.instance.register({
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'full_name': fullName,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_first_name', _firstNameController.text.trim());
      await prefs.setString('user_last_name', _lastNameController.text.trim());
      await prefs.setString('user_name', fullName);
      await prefs.setString('user_email', _emailController.text.trim());
      if (_avatarFile != null) {
        await prefs.setString('user_avatar_path', _avatarFile!.path);
      }
      await prefs.setBool('account_created', true);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès. Connectez-vous pour continuer.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } on ApiException catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.message; });
    } catch (_) {
      setState(() { _isLoading = false; _errorMessage = 'Inscription impossible. Vérifiez votre connexion internet.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RawBank branding
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('RB',
                          style: TextStyle(color: AppColors.textOnPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('RawBank',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Créez votre compte MyRawApp en quelques secondes. '
                  "Vous pourrez ouvrir un compte bancaire une fois connecté.",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 28),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Profile photo picker
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey100,
                            border: Border.all(color: AppColors.grey300, width: 1.5),
                            image: _avatarFile != null
                                ? DecorationImage(image: FileImage(_avatarFile!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _avatarFile == null
                              ? const Icon(Icons.person_outline, size: 40, color: AppColors.grey400)
                              : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text('Photo de profil (optionnel)',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: RawTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        hint: 'Jean',
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Prénom requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RawTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        hint: 'Kabila',
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Nom requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                RawTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Email requis';
                    if (!v!.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                RawTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Min. 8 caractères',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.grey500,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Mot de passe requis';
                    if (v!.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                RawTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.grey500,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                RawButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Déjà un compte ? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
