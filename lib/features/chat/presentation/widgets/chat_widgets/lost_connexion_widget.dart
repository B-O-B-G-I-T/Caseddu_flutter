
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LostConnectionWidget extends StatelessWidget {
  const LostConnectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Le device n\'est plus disponible à proximité.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to a new page or show a dialog
                  context.pop();
                },
                child: const Text('Rechercher à nouveau'),
              ),
            ],
          ),
        ),
      );
  }
}
