import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:json_theme/json_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'config/routes/routes.dart';
import 'features/auth/data/datasources/authentification_remote_data_source.dart';
import 'features/auth/presentation/providers/authentification_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/parametre/presentation/providers/parametre_provider.dart';
import 'firebase_options.dart';

late List<CameraDescription> cameras;

void main() async {
  //pour la camera
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // identification
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // ignore: avoid_print
    print('Error in fetching the cameras: $e');
  }

  final themeStr = await rootBundle.loadString('assets/theme/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final chatProvider = await ChatProvider(); // Initialisation manuelle

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthentificationRemoteDataSourceImpl>(
            create: (_) => AuthentificationRemoteDataSourceImpl(
                  firebaseAuth: firebaseAuth,
                )),
        StreamProvider(
          create: (context) => context.read<AuthentificationRemoteDataSourceImpl>().authStateChange,
          initialData: firebaseAuth.currentUser,
        ),

        ChangeNotifierProvider(
          create: (context) => AuthentificationProvider(firebaseAuth: firebaseAuth),
        ),

        ChangeNotifierProvider(
          create: (context) => ParametreProvider(),
        ),

        ChangeNotifierProvider.value(
          value: chatProvider,
        ),

        //ChangeNotifierProvider(create: (_) => Global()),
      ],
      child: MyApp(theme: theme, cameras: cameras),
    ),
  );
  // }
}

class MyApp extends StatelessWidget {
  final ThemeData theme;

  //pour la camera
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.theme, required this.cameras});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: Routes().router,
      debugShowCheckedModeBanner: false,
      title: 'Caseddu',
      theme: theme,
    );
  }
}
