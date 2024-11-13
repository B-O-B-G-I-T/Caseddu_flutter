import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/parametre_provider.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  final TextEditingController _txt = TextEditingController();
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
                  ParametreProvider provider = Provider.of<ParametreProvider>(context, listen: false);
                  provider.eitherFailureOrParametre();

                  if (provider.failure == null) {
                    GoRouter.of(context).push('/login');

                    context.push('/login');
                  } else {
                    fireBaseError(context, 'Error', provider.failure!.errorMessage);
                  }

                  //   // Navigator.of(context).push(
                  //   //   MaterialPageRoute(
                  //   //     builder: (context) => loginPage(),
                  //   //   ),
                  //   // );
                  //   // context.push('/login');
                  //   // print(context.mounted);
                },
                child:  Text(AppLocalizations.of(context)!.logout)),

// modifie le nom a supprime en prod
            TextField(
              controller: _txt,
            ),
            ElevatedButton(
                onPressed: () {
                  User? user = FirebaseAuth.instance.currentUser;
                  user?.updateDisplayName(_txt.text.trim());
                },
                child: Text(AppLocalizations.of(context)!.edit_name)),
          ]),
        ),
      ),
    );
  }
}
