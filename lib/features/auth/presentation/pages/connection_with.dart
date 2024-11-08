import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/errors/widgets/firebase_error.dart';
import '../providers/authentification_provider.dart';

class ConnectionWithPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final String typeOfConnection;
  ConnectionWithPage({super.key, required this.typeOfConnection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrez le pseudo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Entre un pseudo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text;
                if (username.isNotEmpty) {
                  AuthentificationProvider authentificationProvider = Provider.of<AuthentificationProvider>(context, listen: false);

                  //attenteWidget(context);
                  if (typeOfConnection == "google") {
                    await authentificationProvider.eitherFailureOrAuthentificationWithGoogle(username);
                  } else if (typeOfConnection == "apple") {
                    await authentificationProvider.eitherFailureOrAuthentificationWithApple(username);
                  }
                  if (!context.mounted) return;
                  context.pop(); // Ferme la boîte de dialogue

                  if (authentificationProvider.authentification != null) {
                    context.push('/firstPage/0');
                  } else if (authentificationProvider.failure?.errorMessage != null) {
                    fireBaseError(context, "Error", authentificationProvider.failure!.errorMessage);
                    _usernameController.clear();
                  }
                }
              },
              child: const Text('Création'),
            ),
          ],
        ),
      ),
    );
  }
}
