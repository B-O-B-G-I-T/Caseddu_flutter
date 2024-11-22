import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void attenteWidget(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.waiting),
        content: const SizedBox(
          height: 100, // Définissez la hauteur que vous voulez ici
          child: Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
          ),
        ),
      );
    },
  );
}
