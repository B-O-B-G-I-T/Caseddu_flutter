// ignore_for_file: file_names

import 'package:flutter/material.dart';

@override
Future fireBaseSucces(BuildContext context, String title, String text) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.green),
          ),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
