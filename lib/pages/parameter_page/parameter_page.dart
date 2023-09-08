import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  TextEditingController _txt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(children: [
            // Bouton de deconnexion
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  //GoRouter.of(context).push('/login');

                  context.push('/login');
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => loginPage(),
                  //   ),
                  // );
                  // context.push('/login');
                  // print(context.mounted);
                },
                child: const Text("Déconnexion")),

// modifie le nom a supprime en prod
            TextField(
              controller: _txt,
            ),
            ElevatedButton(
                onPressed: () {
                  User? user = FirebaseAuth.instance.currentUser;
                  user?.updateDisplayName(_txt.text.trim());
                },
                child: const Text("Modifie le nom"))
          ]),
        ),
      ),
    );
  }
}
