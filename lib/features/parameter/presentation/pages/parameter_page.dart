// ignore_for_file: use_build_context_synchronously
import 'package:caseddu/features/parameter/presentation/widgets/custom_circle_avatar.dart';
import 'package:caseddu/features/parameter/presentation/widgets/image_picker_for_params.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../../../../core/params/params.dart';
import '../../../../core/utils/genral_widgets/leading_button_go_back.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/parameter_provider.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en'; // Default language
  late ParameterProvider provider;

  late PermissionState permissionStatus = PermissionState.notDetermined;
  final bool _showGallery = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ParameterProvider>(context, listen: false);

    // Préremplir les champs avec les informations actuelles
    //debugPrint('ParameterPage: initState');
    _nameController.text = provider.parameter.displayName;
    _emailController.text = provider.parameter.email;
    _descriptionController.text = provider.parameter.description ?? '';
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
          leading: const LeadingButtonGoBack(),
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image de profil ou texte
                          CustomCircleAvatar(
                            image: provider.parameter.pathImageProfile,
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
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.edit_name,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.enter_pseudo;
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // E-mail
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.edit_email,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.enter_email;
                              }
                              bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value);
                              if (!emailValid) {
                                return AppLocalizations.of(context)!.enter_a_valid_email;
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Mot de passe
                          // TODO: je  suis mignon modifie et fais un truc plus costaud
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.edit_password,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.length > 6) {
                                  return AppLocalizations.of(context)!.i_hope_you_haven_t_forgotten_it;
                                } else {
                                  return null;
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            maxLength: 255,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.write_description,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty || value.length > 255) {
                                return AppLocalizations.of(context)!.too_long;
                              }

                              return null;
                            },
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final parameter = ParameterParams(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      displayName: _nameController.text.trim(),
                                      description: _descriptionController.text.trim(),
                                      pathImageProfile: provider.parameter.pathImageProfile,
                                    );

                                    if (provider.parameter.isEqualToParams(parameter)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.no_changes)),
                                      );
                                    } else {
                                      await provider.eitherFailureOrUpdate(parameterParams: parameter);
                                      await Provider.of<ChatProvider>(context, listen: false).eitherFailureOrInit(provider);

                                      //TODO : peut être à supprimer, avec la methode implémenter la paire disparait puis réapparait  moi j'aime bien mais pour un utilisateur pas mieux sans

                                      // final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
                                      // chatProvider.controlerDevice!.setDescription(_descriptionController.text.trim());

                                      FocusScope.of(context).unfocus();

                                      _passwordController.text = ""; // Clear password field

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.profile_updated)),
                                      );
                                    }
                                    if (provider.failure != null && mounted) {
                                      fireBaseError(context, 'Error', provider.failure!.errorMessage);
                                    }
                                  } catch (e) {
                                    fireBaseError(context, 'Error', e.toString());
                                  }
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
                              onPressed: () {
                                Provider.of<ChatProvider>(context, listen: false).logout();
                                context.push('/login');
                              },
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
            ),
            if (provider.isloading)
              Container(
                color: Colors.black.withOpacity(0.5), // Fond noir semi-transparent
                child: const Center(
                  child: CircularProgressIndicator(), // Indicateur de chargement au centre
                ),
              ),
          ],
        ),
      );
    });
  }
}
