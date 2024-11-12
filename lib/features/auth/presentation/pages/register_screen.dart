//TODO: controler les mot de passe entré

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/errors/widgets/attente_widget.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/authentification_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // tous les controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pseudoController = TextEditingController();
  final _cellPhone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ON S'EN FOU
                  const Icon(
                    Icons.handshake,
                    size: 200,
                  ),
                  Text(
                    AppLocalizations.of(context)!.hey_you,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.who_are_you,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
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
                              return AppLocalizations.of(context)!.enter_pseudo;
                            }
                            // bool emailValid = RegExp(
                            //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            //     .hasMatch(value);
                            // if (!emailValid) {
                            //   return 'Entre un pseudo valide';
                            // }

                            return null;
                          },
                          controller: _pseudoController,
                          autofocus: true,
                          enableIMEPersonalizedLearning: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enter_a_valid_username,
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

// numero
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      decoration: BoxDecoration(
                          // color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.enter_a_valid_number;
                            }

                            return null;
                          },
                          controller: _cellPhone,
                          autofocus: true,
                          enableIMEPersonalizedLearning: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enter_a_number,
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

// Email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      decoration: BoxDecoration(
                          // color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.enter_email;
                            }
                            bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                            if (!emailValid) {
                              return AppLocalizations.of(context)!.enter_a_valid_email;
                            }

                            return null;
                          },
                          controller: _emailController,
                          autofocus: true,
                          enableIMEPersonalizedLearning: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enter_a_valid_email,
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

// PASSWORD
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
                              return AppLocalizations.of(context)!.enter_your_password;
                            } else {
                              return null;
                            }
                          },
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enter_your_password,  
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

// confirm PASSWORD
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
                              return AppLocalizations.of(context)!.enter_your_password;
                            } else {
                              return null;
                            }
                          },
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.i_hope_you_haven_t_forgotten_it,
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //BOUTTON CLICK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: ElevatedButton(
                      child: SizedBox(
                        height: 50,
                        width: 150,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.creation,
                            //style: TextStyle(
                            //color: Colors.white,
                            //fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();
                          String confirmPassword = _confirmPasswordController.text.trim();
                          String pseudo = _pseudoController.text.trim();

                          AuthentificationProvider authentificationProvider = Provider.of<AuthentificationProvider>(context, listen: false);

                          attenteWidget(context);

                          await authentificationProvider.eitherFailureOrRegister(email, password, confirmPassword, "0", pseudo);
                          if (!context.mounted) return;
                          context.pop(); // Ferme la boîte de dialogue

                          if (authentificationProvider.failure == null) {
                            context.push('/');
                          } else {
                            fireBaseError(context, 'Erreur', authentificationProvider.failure!.errorMessage);
                          }
                          context.push('/firstPage/0');
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // enfaite il a deja un compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.am_i_member,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      GestureDetector(
                        child: Text(
                          AppLocalizations.of(context)!.connect,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          context.push('/login');
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
