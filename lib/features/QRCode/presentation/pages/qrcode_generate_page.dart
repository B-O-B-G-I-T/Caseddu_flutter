import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class QRCodeGeneratePage extends StatelessWidget {
  const QRCodeGeneratePage({super.key});

  final String userId = "12345"; // Exemple d'ID utilisateur

  // URL schéma personnalisé pour ouvrir l'application si elle est installée
  String _getAppUrl() {
    return "Caseddu://user?id=$userId"; // Schéma personnalisé de votre app
  }

  // URL TestFlight pour installer l'application
  String _getTestFlightUrl() {
    return "https://testflight.apple.com/join/9Gpy3Vmx"; // Remplacez <code> par votre code d'invitation TestFlight
  }

  // URL vers l'App Store ou Google Play si l'application n'est pas installée
  // ignore: unused_element
  String _getStoreUrl(BuildContext context) {
    // Pour Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      return "https://play.google.com/store/apps/details?id=com.votreapp";
    }
    // Pour iOS
    return "https://apps.apple.com/fr/app/votreapp/id123456789";
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController(text: AppLocalizations.of(context)!.qrCodeTitleDefault);
    final TextEditingController descriptionController =
        TextEditingController(text: AppLocalizations.of(context)!.qrCodeDescriptionDefault("Caseddu"));
    const String appLink = "https://testflight.apple.com/join/9Gpy3Vmx";

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextFormField(
                scrollPhysics: const NeverScrollableScrollPhysics(),
                controller: titleController,
                textAlign: TextAlign.center,
                maxLines: null,
                keyboardType: TextInputType.multiline, // Assurez-vous que le clavier permet de saisir plusieurs lignes
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.edit),
                  isDense: true, // Réduit la hauteur
                  contentPadding: EdgeInsets.zero, // Supprime les marges internes
                  border: InputBorder.none, // Supprime la bordure
                ),
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.black, // Texte en noir
                      fontWeight: FontWeight.bold, // Texte en gras
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextField(
                controller: descriptionController,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                textAlign: TextAlign.center,
                maxLines: null,
                keyboardType: TextInputType.multiline, // Assurez-vous que le clavier permet de saisir plusieurs lignes
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.edit),
                  isDense: true, // Minimise la hauteur
                  contentPadding: EdgeInsets.zero, // Supprime les marges internes
                  border: InputBorder.none, // Supprime la bordure
                ),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black, // Texte en noir
                      fontWeight: FontWeight.bold, // Texte en gras
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final appUrl = Uri.parse(_getAppUrl());
                final testFlightUrl = Uri.parse(_getTestFlightUrl());

                // Vérifier si l'application est installée en essayant d'ouvrir le schéma personnalisé
                if (await canLaunchUrl(appUrl)) {
                  // L'application est installée, ouvrir l'URL
                  await launchUrl(appUrl);
                } else {
                  // L'application n'est pas installée, rediriger vers TestFlight
                  if (await canLaunchUrl(testFlightUrl)) {
                    await launchUrl(testFlightUrl);
                  } else {
                    throw 'Impossible d\'ouvrir l\'URL $testFlightUrl';
                  }
                }
              },
              child: const Text("Ouvrir l'application ou télécharger"),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: QrImageView(
                data: appLink,
                embeddedImage: const AssetImage(
                  'assets/icons/qrCodeIcon.png',
                ),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(80, 80),
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                version: QrVersions.auto,
                //size: 400,
                gapless: false,
                errorStateBuilder: (cxt, err) {
                  // ignore: avoid_unnecessary_containers
                  return Container(
                    child: const Center(
                      child: Text(
                        'Uh oh! Something went wrong...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
