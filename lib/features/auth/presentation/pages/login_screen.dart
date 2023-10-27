// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/errors/widgets/attente_widget.dart';
import 'package:flutter_application_1/core/errors/widgets/firebase_error.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/authentification_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                  const Text(
                    "Salut toi",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Tu change encore le menu",
                    style: TextStyle(
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
                          keyboardType: TextInputType.emailAddress,
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
                              return "J'espère que tu l'as pas oublié";
                            } else {
                              return null;
                            }
                          },
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Écris ton mot de passe",
                            //border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // mot de passe oublié
                  GestureDetector(
                    onTap: () {
                      context.push('/oubliMotDePasse');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Mot de passe oublié",
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                      ),
                    ),
                  ),

                  //BOUTTON CLICK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: ElevatedButton(
                      child: const SizedBox(
                        height: 50,
                        width: 150,
                        child: Center(
                          child: Text(
                            "Connexion",
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

                          AttenteWidget(context);

                          await authentificationProvider.eitherFailureOrAuthentification(email, password);

                          context.pop(); // Ferme la boîte de dialogue

                          if (authentificationProvider.authentification != null) {
                            context.push('/');
                          } else if (authentificationProvider.failure?.errorMessage != null) {
                            fireBaseError(context, "Error", authentificationProvider.failure!.errorMessage);
                            _emailController.clear();
                            _passwordController.clear();
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // création de compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tu n'est pas membre ? ",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      GestureDetector(
                        child: const Text(
                          "Enrole toi",
                          style: TextStyle(color: Colors.blue),
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
