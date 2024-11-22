// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/attente_widget.dart';
import '../../../../core/errors/widgets/firebase_succes.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/authentification_provider.dart';

class OubliMotDePassePage extends StatefulWidget {
  const OubliMotDePassePage({super.key});

  @override
  State<OubliMotDePassePage> createState() => _OubliMotDePasseScreenState();
}

class _OubliMotDePasseScreenState extends State<OubliMotDePassePage> {
  // tous les controllers
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.enter_email,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(
                  height: 10,
                ),
                // PSEUDO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    decoration: BoxDecoration(
                        // color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entre ton email';
                          }
                          bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                          if (!emailValid) {
                            return 'Entre ton email valide';
                          }

                          return null;
                        },
                        controller: _emailController,
                        autofocus: true,
                        enableIMEPersonalizedLearning: true,
                        decoration: const InputDecoration(
                          hintText: "Entre ton email",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                // CLICK
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String email = _emailController.text.trim();

                      AuthentificationProvider authentificationProvider = Provider.of<AuthentificationProvider>(context, listen: false);

                      attenteWidget(context);

                      await authentificationProvider.eitherFailureOrPasswordChange(email);

                      context.pop(); // Ferme la boîte de dialogue

                      if (authentificationProvider.failure == null) {
                        fireBaseSucces(
                            context, "Succès", 'Le mot de passe est rénitialisé, un lien est envoyé pour le changer regarde dans tes mails.');
                        context.push('/login');
                      } else {
                        fireBaseError(context, 'Erreur', authentificationProvider.failure!.errorMessage);
                      }
                    }
                  },
                  child:  Text(AppLocalizations.of(context)!.change_password),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
