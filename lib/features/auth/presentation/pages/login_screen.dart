// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/errors/widgets/attente_widget.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../../../../core/errors/widgets/forgot_password_widget.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../parameter/presentation/providers/parameter_provider.dart';
import '../providers/authentification_provider.dart';
import '../widgets/sign_in_button_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // tous les controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Icons.admin_panel_settings_outlined,
                    size: 200,
                  ),
                  Text(
                    AppLocalizations.of(context)!.hey_you,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
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
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.enter_your_valid_email;
                          }
                          bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                          if (!emailValid) {
                            return AppLocalizations.of(context)!.enter_your_valid_email;
                          }

                          return null;
                        },
                        controller: _emailController,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        enableIMEPersonalizedLearning: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enter_email,
                          //border: InputBorder.none,
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
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.i_hope_you_haven_t_forgotten_it;
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
                  const SizedBox(
                    height: 10,
                  ),

                  // mot de passe oublié
                  const ForgotPasswordWidget(),

                  //BOUTTON CLICK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: ElevatedButton(
                      child: SizedBox(
                        height: 50,
                        width: 150,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            //style: TextStyle(
                            //color: Colors.white,
                            //fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final String email = _emailController.text.trim();
                          final String password = _passwordController.text.trim();

                          AuthentificationProvider authentificationProvider = Provider.of<AuthentificationProvider>(context, listen: false);

                          attenteWidget(context);

                          await authentificationProvider.eitherFailureOrAuthentification(email, password);

                          context.pop(); // Ferme la boîte de dialogue

                          if (authentificationProvider.authentification != null) {
                            final parameterProvider = Provider.of<ParameterProvider>(context, listen: false);
                            await parameterProvider.init();
                            await Provider.of<ChatProvider>(context, listen: false).eitherFailureOrInit(parameterProvider);
                            context.push('/firstPage/0');
                          } else if (authentificationProvider.failure?.errorMessage != null) {
                            fireBaseError(context, "Error", authentificationProvider.failure!.errorMessage);
                            _emailController.clear();
                            _passwordController.clear();
                          }
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: Platform.isIOS || Platform.isMacOS,
                    child: SignInButton(
                      imagePath: 'assets/icons/apple_icon.png',
                      onTap: () {
                        context.push('/connectionWith/', extra: 'apple');
                      },
                      text: AppLocalizations.of(context)!.connect_with_apple,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  SignInButton(
                    imagePath: 'assets/icons/google_icon.png',
                    onTap: () {
                      context.push('/connectionWith/', extra: 'google');
                    },
                    text: AppLocalizations.of(context)!.connect_with_google,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // création de compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.not_a_member,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      GestureDetector(
                        child: Text(
                          AppLocalizations.of(context)!.sign_up,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          context.push('/enroler');
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
