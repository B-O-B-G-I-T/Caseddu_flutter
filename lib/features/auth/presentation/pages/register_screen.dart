//TODO: controler les mot de passe entré
// ignore_for_file: use_build_context_synchronously

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/widgets/attente_widget.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/authentification_provider.dart';

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
                  const Text(
                    "Salut toi",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Qui es-tu ?",
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
                              return 'Entre un pseudo';
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
                          decoration: const InputDecoration(
                            hintText: "Entre une pseudo valide",
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
                              return 'Entre un numero valide';
                            }

                            return null;
                          },
                          controller: _cellPhone,
                          autofocus: true,
                          enableIMEPersonalizedLearning: true,
                          decoration: const InputDecoration(
                            hintText: "Entre une numero",
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
                              return 'Entre une email';
                            }
                            bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                            if (!emailValid) {
                              return 'Entre une email valide';
                            }

                            return null;
                          },
                          controller: _emailController,
                          autofocus: true,
                          enableIMEPersonalizedLearning: true,
                          decoration: const InputDecoration(
                            hintText: "Entre une email valide",
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
                              return 'Écris ton mot de passe';
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
                              return 'Écris ton mot de passe';
                            } else {
                              return null;
                            }
                          },
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "J'espère que tu l'as pas oublié",
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
                      child: const SizedBox(
                        height: 50,
                        width: 150,
                        child: Center(
                          child: Text(
                            "Création",
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

                          await authentificationProvider.eitherFailureOrRegister(email, password, confirmPassword, "0",pseudo);

                          context.pop(); // Ferme la boîte de dialogue

                          if (authentificationProvider.failure == null) {
                            context.push('/');
                          } else {
                            fireBaseError(context, 'Erreur', authentificationProvider.failure!.errorMessage);
                          }
                          context.push('/');
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
                        "Je suis un membre ? ",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      GestureDetector(
                        child: const Text(
                          "Connecte toi",
                          style: TextStyle(color: Colors.blue),
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
