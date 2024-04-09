import 'package:flutter/material.dart';

void AttenteWidget(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Veuillez patienter...'),
        content: Container(
          height: 100, // Définissez la hauteur que vous voulez ici
          child: const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
          ),
        ),
      );
    },
  );
}
