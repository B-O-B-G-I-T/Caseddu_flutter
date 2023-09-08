import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _MyAppBarState extends State<MyAppBar> {
  final _utilisateur = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: GestureDetector(
        child: Row(
          children: [
            const Icon(
              Icons.account_circle_outlined,
            ),
            Text(_utilisateur.displayName!)
          ],
        ),
        onTap: () {
          // Obtenir une référence à l'instance de GoRouter
          final router = GoRouter.of(context);
          // Naviguer vers la page des paramètres
          router.push('/parameter');
        },
      ),

      title: const Text(
        "Flute",
        //style:
        //TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),
      ),

      actions: const [
        IconButton(
          icon: Icon(
            Icons.zoom_in_map_rounded,
          ),
          onPressed: null,
        ),
      ],
      //c'est cool si pas centrer
      centerTitle: true,
    );
  }
}
