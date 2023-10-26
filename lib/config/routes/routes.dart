import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/oubli_mot_de_passe.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/photo_pages/3_envoie_de_photo.dart';
import '../../features/chat/presentation/pages/photo_pages/2_prise_photo.dart';
import '../../features/parametre/presentation/pages/parameter_page.dart';
import '../../PremierePage.dart';

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
          return const OubliMotDePassePage();
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const PremierePage();
        },
      ),
      GoRoute(
        path: '/parameter',
        builder: (context, state) {
          return const ParametrePage();
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
          return 
          EnvoieDePhotoPage(
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
