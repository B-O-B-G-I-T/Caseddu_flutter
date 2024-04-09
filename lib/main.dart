import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/data/datasources/authentification_remote_data_source.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/authentification_provider.dart';
import 'package:flutter_application_1/global/global.dart';
import 'package:flutter_application_1/config/routes/routes.dart';
import 'package:flutter_application_1/provider/event_provider.dart';
import 'package:json_theme/json_theme.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request().then((status) {
      // runApp(MyApp(theme: theme, cameras: cameras));
    });
  } else {} // else {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthentificationRemoteDataSourceImpl>(create: (_) => AuthentificationRemoteDataSourceImpl(firebaseAuth: firebaseAuth)),
        StreamProvider(
          create: (context) => context.read<AuthentificationRemoteDataSourceImpl>().authStateChange,
          initialData: firebaseAuth.currentUser,
        ),
        ChangeNotifierProvider(
          create: (context) => AuthentificationProvider(firebaseAuth: firebaseAuth),
        ),
        ChangeNotifierProvider(create: (_) => Global()),
        ChangeNotifierProvider(create: (context) => EventProvider())
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

  const MyApp({Key? key, required this.theme, required this.cameras}) : super(key: key);
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routes().router,
      debugShowCheckedModeBanner: false,
      title: 'Caseddu ',
      theme: theme,
    );
  }
}
