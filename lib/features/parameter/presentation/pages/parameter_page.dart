// ignore_for_file: use_build_context_synchronously

import 'package:caseddu/features/parameter/presentation/widgets/custom_circle_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../../../../core/params/params.dart';
import '../providers/parameter_provider.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en'; // Default language
  late ParameterProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ParameterProvider>(context, listen: false);
    // Préremplir les champs avec les informations actuelles
    provider.init();
    debugPrint('ParameterPage: initState');
    _nameController.text = provider.parameter!.displayName;
    _emailController.text = provider.parameter!.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    onPressed: () {
                      try {
                        final parameter = ParameterParams(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          displayName: _nameController.text.trim(),
                        );
                        provider.eitherFailureOrUpdate(parameterParams: parameter);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.profile_updated)),
                        );
                      } on Exception catch (e) {
                        fireBaseError(context, 'Error', e.toString());
                      }
                    },
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
                    onPressed: () => provider.eitherFailureOrLogout(),
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
