import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController(text: AppLocalizations.of(context)!.qrCodeTitleDefault);
    final TextEditingController descriptionController =
        TextEditingController(text: AppLocalizations.of(context)!.qrCodeDescriptionDefault("Caseddu"));
    const String appLink = "https://yourdomain.com/download?user_id=12345";

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
