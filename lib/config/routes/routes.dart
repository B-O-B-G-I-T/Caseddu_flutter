import 'dart:async';

import 'package:caseddu/features/chat/presentation/pages/chat_user_page.dart';
import 'package:caseddu/features/chat/presentation/widgets/chat_widgets/preview_picture/full_screen_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/QRCode/presentation/pages/qrcode_camera_page.dart';
import '../../features/auth/presentation/pages/connection_with.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/oubli_mot_de_passe.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/photo_pages/2_prise_de_photo copy.dart';
import '../../features/chat/presentation/pages/photo_pages/2_prise_de_photo.dart';
import '../../features/chat/presentation/pages/photo_pages/3_envoie_de_photo.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/parameter/presentation/pages/parameter_page.dart';
import '../../premiere_page.dart';

// doc officiel : https://docs.flutter.dev/ui/navigation
// doc du package : https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
// code d'exemple : https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart

List<String> routesName = <String>[
  "/enroler",
  "/connectionWith",
  "/oubliMotDePasse",
];

class Routes {
  // GoRouter configuration
  final _router = GoRouter(
    observers: [],
    // l'écarn de login
    initialLocation: '/firstPage/0',
    navigatorKey: GlobalKey<NavigatorState>(), // Définir la clé globale
    //redige la ou l'on veut
    redirect: (context, state) {
      final user = Provider.of<User?>(context, listen: false);

      // ignore: unnecessary_null_comparison
      if (user == null && !routesName.contains(state.matchedLocation)) {
        Provider.of<ChatProvider>(context, listen: false).disabledNearbyService();
        return '/login';
      } else {
        return null;
      }
    },
    // créé les routes
    routes: [
      GoRoute(
        path: '/firstPage/:index',
        builder: (context, state) {
          final index = int.parse(state.pathParameters['index']!);
          return PremierePage(selectedIndex: index);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/enroler',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
          path: '/connectionWith',
          builder: (context, state) {
            final String typeOfConnection = state.extra.toString();
            return ConnectionWithPage(typeOfConnection: typeOfConnection);
          }),
      GoRoute(
        path: '/oubliMotDePasse',
        builder: (context, state) {
          return const OubliMotDePassePage();
        },
      ),
      GoRoute(
        path: '/parameter',
        builder: (context, state) {
          return const ParameterPage();
        },
      ),
      GoRoute(
        path: '/ChatPage/:deviceName',
        builder: (context, state) {
          final String deviceName = state.pathParameters['deviceName'].toString();
          return ChatPage(
            converser: deviceName,
          );
        },
      ),
      GoRoute(
          path: '/ProfilePage/:userName',
          name: 'ProfilePage',
          builder: (context, state) {
            final String userName = state.pathParameters['userName'].toString();
            return ChatUserPage(
              userName: userName,
            );
          }),
      GoRoute(
        path: '/fullScreenImage/:filePath',
        name: 'fullScreenImage',
        builder: (context, state) {
          String filePath = state.extra.toString(); // -> le casting est important
          return FullScreenImagePage(
            imageUrl: filePath,
          );
        },
      ),
      GoRoute(
        path: '/EnvoieDePhotoPage',
        name: 'EnvoieDePhotoPage',
        builder: (context, state) {
          final String filePath = state.extra.toString();
          return EnvoieDePhotoPage(
            pictureTaken: filePath,
          );
        },
      ),
      GoRoute(
        path: '/PrisePhoto/:filePath',
        name: 'PrisePhoto',
        pageBuilder: (context, state) {
          final Completer<String?> filePath = state.extra as Completer<String?>; // -> le casting est important

          return CustomTransitionPage(
            child: PrisePhoto(lastImageCompleter: filePath),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Aucune transition, on retourne directement l'enfant
              return child;
            },
            transitionDuration: Duration.zero, // Pas de délai de transition
          );
        },
      ),
      GoRoute(
        path: '/PrisePhotoString/:filePath',
        name: 'PrisePhotoString',
        pageBuilder: (context, state) {
          final String filePath = state.extra as String; // -> le casting est important

          return CustomTransitionPage(
            child: PrisePhotoString(lastImageCompleter: filePath),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Aucune transition, on retourne directement l'enfant
              return child;
            },
            transitionDuration: Duration.zero, // Pas de délai de transition
          );
        },
      ),
    
    ],
  );

  // variable public
  GoRouter get router => _router;
}
