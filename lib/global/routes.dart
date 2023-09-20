import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';
import 'package:flutter_application_1/pages/login/login_screen.dart';
import 'package:flutter_application_1/pages/parameter_page/parameter_page.dart';
import 'package:flutter_application_1/pages/photo_pages/envoie_de_photo.dart';
import 'package:flutter_application_1/widget/bottombar.dart';
import 'package:go_router/go_router.dart';

import '../pages/login/oubli_mot_de_passe.dart';
import '../pages/login/register_screen.dart';

// doc officiel : https://docs.flutter.dev/ui/navigation
// doc du package : https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
// code d'exemple : https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/main.dart

class Routes {
  // GoRouter configuration
  final _router = GoRouter(
    // l'écarn de login
    initialLocation: '/',
    //redige la ou l'on veut
    redirect: (context, state) {
      if (FirebaseAuth.instance.currentUser == null &&
          state.matchedLocation != '/enroler' &&
          state.matchedLocation != '/oubliMotDePasse') {
        return '/login';
      } else {
        return null;
      }

      // && state.matchedLocation == '/login'
    },
    // créé les routes
    routes: [
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
        path: '/oubliMotDePasse',
        builder: (context, state) {
          return const OubliMotDePasseScreen();
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const BottomBar();
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
          final String deviceName =
              state.pathParameters['deviceName'].toString();
          return ChatPage(
            converser: deviceName,
          );
        },
      ),
      GoRoute(
        path: '/EnvoieDePhotoPage/:cheminImage',
        builder: (context, state) {
          final String cheminImage =
              state.pathParameters['cheminImage'].toString();
          return EnvoieDePhotoPage(
            cheminVersImagePrise: cheminImage,
          );
        },
      ),
    ],
  );

  // variable public
  GoRouter get router => _router;
}
