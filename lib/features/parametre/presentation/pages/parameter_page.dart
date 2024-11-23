// ignore_for_file: use_build_context_synchronously

import 'package:caseddu/features/parametre/presentation/widgets/custom_circle_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/parameter_provider.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    // Préremplir les champs avec les informations actuelles
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    ParametreProvider provider = Provider.of<ParametreProvider>(context, listen: false);
    provider.eitherFailureOrParametre();

    if (provider.failure == null) {
      await FirebaseAuth.instance.signOut();
      GoRouter.of(context).go('/login');
    } else {
      fireBaseError(context, 'Error', provider.failure!.errorMessage);
    }
  }

  void _updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_nameController.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nameController.text.trim());
        }
        if (_emailController.text.trim().isNotEmpty && _emailController.text.trim() != user.email) {
          await user.updateEmail(_emailController.text.trim());
        }
        if (_passwordController.text.trim().isNotEmpty) {
          await user.updatePassword(_passwordController.text.trim());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profile_updated)),
        );
        setState(() {});
      }
    } catch (error) {
      fireBaseError(context, 'Error', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de profil ou texte
                const CustomCircleAvatar(),
                const SizedBox(height: 16.0),

                // Nom
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.edit_name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // E-mail
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.edit_email,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Mot de passe
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.edit_password,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Notifications
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.notifications),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                // Langue
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.language,
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value ?? 'en';
                    });
                  },
                ),
                const SizedBox(height: 24.0),

                // Sauvegarder les modifications
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text(AppLocalizations.of(context)!.save_changes),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Bouton de déconnexion
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _logout(context),
                    child: Text(AppLocalizations.of(context)!.logout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
