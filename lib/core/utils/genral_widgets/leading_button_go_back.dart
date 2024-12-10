import 'package:flutter/material.dart';

class LeadingButtonGoBack extends StatelessWidget {
  const LeadingButtonGoBack({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          );
  }
}