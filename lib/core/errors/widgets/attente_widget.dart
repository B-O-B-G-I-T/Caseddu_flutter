import 'package:flutter/material.dart';

void attenteWidget(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text('Veuillez patienter...'),
        content: SizedBox(
          height: 100, // Définissez la hauteur que vous voulez ici
          child: Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
          ),
        ),
      );
    },
  );
}
