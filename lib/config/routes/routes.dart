import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_application_1/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter_application_1/features/authentification/presentation/pages/oubli_mot_de_passe.dart';
import 'package:flutter_application_1/presentation/chat/chat_page.dart';
import 'package:flutter_application_1/presentation/parameter_page/parameter_page.dart';
import 'package:flutter_application_1/presentation/photo_pages/envoie_de_photo.dart';
import 'package:flutter_application_1/presentation/photo_pages/prise_photo.dart';
import 'package:flutter_application_1/widget/bottombar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
      final user = Provider.of<User?>(context, listen: false);

      // ignore: unnecessary_null_comparison
      if (user == null && state.matchedLocation != '/enroler' && state.matchedLocation != '/oubliMotDePasse') {
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
          return const LoginPage2();
        },
      ),
      GoRoute(
        path: '/enroler',
        builder: (context, state) {
          return const RegisterPage2();
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
          final String deviceName = state.pathParameters['deviceName'].toString();
          return ChatPage(
            converser: deviceName,
          );
        },
      ),
      GoRoute(
        path: '/EnvoieDePhotoPage',
        name: 'EnvoieDePhotoPage',
        builder: (context, state) {
          final String filePath = state.extra.toString();
          return EnvoieDePhotoPage(
            cheminVersImagePrise: filePath,
          );
        },
      ),
      GoRoute(
        path: '/PrisePhoto',
        name: 'PrisePhoto',
        builder: (context, state) {
          String filePath = state.extra.toString(); // -> le casting est important
          return PrisePhoto(
            lastImage: filePath,
          );
        },
      )
    ],
  );

  // variable public
  GoRouter get router => _router;
}
