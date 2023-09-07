import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OubliMotDePasseScreen extends StatefulWidget {
  const OubliMotDePasseScreen({super.key});

  @override
  State<OubliMotDePasseScreen> createState() => _OubliMotDePasseScreenState();
}

class _OubliMotDePasseScreenState extends State<OubliMotDePasseScreen> {
  // tous les controllers
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future changeMotDePasse() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      //print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Entre ton email",
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
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value);
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
            onPressed: () {
              Future futur = changeMotDePasse();

              futur.then(
                (value) {
                  if (value == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Lien envoyé'),
                          content: const Text(
                              'Le mot de passe est rénitialisé, un lien est envoyé pour le changer regarde dans tes mails.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                context.push('/login');
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else
                    null;
                },
              );
            },
            child: const Text("Change le mot de passe"),
          ),
        ],
      ),
    );
  }
}
