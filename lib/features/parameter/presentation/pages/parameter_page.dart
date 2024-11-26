// ignore_for_file: use_build_context_synchronously

import 'package:caseddu/features/parameter/presentation/widgets/custom_circle_avatar.dart';
import 'package:caseddu/features/parameter/presentation/widgets/image_picker_for_params.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../../../../core/params/params.dart';
import '../../../../core/utils/p2p/fonctions.dart';
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

  late PermissionState permissionStatus = PermissionState.notDetermined;
  bool _showGallery = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ParameterProvider>(context, listen: false);
    provider.init();
    // Préremplir les champs avec les informations actuelles
    debugPrint('ParameterPage: initState');
    _nameController.text = provider.parameter!.displayName;
    _emailController.text = provider.parameter!.email;
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImagePickerForParams(parameterProvider: provider);
      },
    );
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
    return Consumer<ParameterProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image de profil ou texte
                    CustomCircleAvatar(
                      ontap: () async {
                        //FocusScope.of(context).unfocus();

                        permissionStatus = await PhotoManager.requestPermissionExtend();
                        if (permissionStatus == PermissionState.authorized) {
                          await provider.loadImageParams(context);
                          setState(() {
                            _showBottomSheet();
                          });
                          // } else if (permissionStatus.hasAccess && !_showGallery) {
                          //   Utils.showLimitedAccessDialog(context: context);
                        } else {
                          Utils.showPermissionDeniedDialog(context: context);
                        }
                      },
                    ),

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
              _showGallery
                  ? ImagePickerForParams(
                      parameterProvider: provider,
                    )
                  : const Center(),
            ],
          ),
        ),
      );
    });
  }
}
