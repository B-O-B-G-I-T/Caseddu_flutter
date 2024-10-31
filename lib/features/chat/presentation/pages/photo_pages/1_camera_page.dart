// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as IMG;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/camera_widgets/background_buttons_widget.dart';
import '../../widgets/chat_widgets/page_chat/loader_for_chat.dart';

class CameraPage extends StatefulWidget {
  //pour la camera
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraController _cameraController = CameraController(
    const CameraDescription(
      // pour eviter l'erreur de null
      name: 'null',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 0,
    ),
    ResolutionPreset.medium,
    imageFormatGroup: ImageFormatGroup.yuv420,
    //fps: 30,
  );
  Future<void>? initialiseControllerFuture;
  int _selecteCameraIndex = -1;
  String _lastImage = '';
  // bool _loading = true;
  bool _flashFront = false;
  bool _isCameraPermissionGranted = false;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _startZoom = 0;

  bool _showExtraButtons = false; // Variable d'état pour afficher le conteneur supplémentaire
  final GlobalKey _addButtonKey = GlobalKey(); // Key pour obtenir la position du bouton "add"

  @override
  void initState() {
    // _cameraToggle();
    getAllPermission();
    // getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = _cameraController;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (!cameraController.value.isInitialized) {
        _cameraToggle(); // Réinitialiser seulement si la caméra n'est pas initialisée
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    if (_showExtraButtons == true) {
      hideAdditionnalButtons();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: null,
      ),
      body: FutureBuilder(
        future: initialiseControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loaderForCamera();
          } else {
            if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else {
              if (snapshot.connectionState == ConnectionState.done || widget.cameras.isEmpty) {
                if (_isCameraPermissionGranted) {
                  return cameraWithButtonsWidget();
                } else {
                  return permissionWidget();
                }
              } // Affiche le widget en fonction de la permission
              return loaderForCamera();
            }
          }
        },
      ),
      floatingActionButton: _isCameraPermissionGranted ? floatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

// FONCTIONS

  Future<void> _prendrePhoto() async {
    // pour le faire en background
    //initialiseControllerFuture.then((value) => null);
    try {
      await initialiseControllerFuture;

      String cheminVersImage = join(
        (await getApplicationDocumentsDirectory()).path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile file = await _cameraController.takePicture();
      //await file.saveTo(cheminVersImage);
      // print(_cameraController.value.previewSize);

      final croppedFile = cropImageToScreenSizeInIsolate(file, context);

      //final croppedFile = await _cropImageToScreenSizeWithImage(file, context);
      //String? croppedImagePath = await cropImageToScreenSize(file, context);
      //print(croppedFile!.path);
      // setState(() {
      //   _lastImage = croppedFile!.path;
      //   //_lastImage = croppedImagePath!;
      // });
    } catch (e) {
      print('Erreur lors de la capture de la photo : $e');
    }
  }

//! ISOLATE
  Future<void> cropImageToScreenSizeInIsolate(XFile file, BuildContext context) async {
    final completer = Completer<String?>();
    // Port pour recevoir le résultat
    final receivePort = ReceivePort();
    // récupère la taille de l'écran
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width + 45;
    final double screenHeight = screenSize.height;
    // file
    final String path = file.path;

    // Lance l'Isolate
    await Isolate.spawn<Map<String, dynamic>>(
      _cropImageToScreenSizeInIsolateWithPort,
      {
        'sendPort': receivePort.sendPort,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'path': path,
      },
    );

    // Écoute les messages de l’isolate
    receivePort.listen((message) {
      if (message is String) {
        // Vérifie si l'isolate a envoyé un message d’erreur
        completer.completeError("Erreur lors du recadrage de l'image.");
      } else if (message is File) {
        completer.complete(message.path); // Passe le chemin du fichier recadré
      }
      receivePort.close(); // Ferme le port une fois terminé
    });
    // Passe le `Completer` à la page suivante
    context.push('/PrisePhoto2/:filePath', extra: completer);
  }

// Fonction pour recadrer l'image selon la taille de l'écran DONN2 PAR LE TYPE DE GIT
  Future<File?> _cropImageToScreenSizeWithImage(XFile imageFile, BuildContext context) async {
    // Lire l'image en bytes
    final capturedImgBytes = await imageFile.readAsBytes();
    IMG.Image? img = IMG.decodeImage(capturedImgBytes);

    if (img != null) {
      // Obtenir les dimensions de l'écran
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width + 45;
      final screenHeight = screenSize.height;

      // Calculer le ratio d'aspect de l'écran (width/height)
      double aspectRatio = screenWidth / screenHeight;

      // Ratio d'aspect de l'image capturée (width/height)
      double cameraRatio = aspectRatio; // Remplacer selon tes besoins réels si nécessaire

      int oldWidth = img.width;
      int oldHeight = img.height;

      /// Bug-Fix: Camera has a wrong orientation when the flash is activated
      if (oldHeight / oldWidth == cameraRatio) {
        img = IMG.copyRotate(img, angle: 90);
        oldWidth = img.width;
        oldHeight = img.height;
      }

      double newWidth = oldWidth.toDouble();
      double newHeight = oldHeight.toDouble();

      double x = 0;
      double y = 0;

      if (aspectRatio <= cameraRatio) {
        newWidth = oldHeight * aspectRatio;
        x = (oldWidth - newWidth) / 2;
      } else {
        newHeight = oldWidth / aspectRatio;
        y = (oldHeight - newHeight) / 2;
      }

      // Recadrer l'image selon le ratio d'aspect
      IMG.Image croppedImage = IMG.copyCrop(
        img,
        x: x.toInt(),
        y: y.toInt(),
        width: newWidth.toInt(),
        height: newHeight.toInt(),
      );

      // Appliquer l'orientation de l'image après recadrage
      croppedImage = IMG.bakeOrientation(croppedImage);

      // Enregistrer l'image recadrée
      final croppedImageFile = await File(imageFile.path).writeAsBytes(IMG.encodeJpg(croppedImage));
      return croppedImageFile;
    }
    return null;
  }

  Future<void> getAllPermission() async {
    if (Platform.isAndroid) {
      await [
        Permission.camera,
        Permission.microphone,
        Permission.storage,
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.nearbyWifiDevices,
      ].request().then((status) {
        // runApp(MyApp(theme: theme, cameras: cameras));
      });
    } else {
      // [
      //   Permission.camera,
      //   Permission.microphone,
      //   Permission.storage,
      //   Permission.location,
      //   Permission.bluetooth,
      //   Permission.bluetoothConnect,
      //   Permission.bluetoothScan,
      // ].request().then((status) {
      //   // runApp(MyApp(theme: theme, cameras: cameras));
      // });
    }
    await getPermissionStatus();
  }

  Future<void> getPermissionStatus() async {
    var status = await Permission.camera.request();
    //log('Camera Permission: $status');
    if (status.isGranted) {
      //log('Camera Permission: GRANTED');
      _isCameraPermissionGranted = true;
      // Set and initialize the new camera
      _cameraToggle();
    } else {
      await Permission.camera.request();
      //log('Camera Permission: DENIED');
    }
  }

  Future<void> _cameraToggle() async {
    setState(() {
      if (_lastImage != '') {
        _lastImage = '';
      }
      if (_selecteCameraIndex > -1) {
        if (_selecteCameraIndex == 0) {
          _selecteCameraIndex = 1;
        } else {
          _selecteCameraIndex = 0;
        }
      } else {
        _selecteCameraIndex = 0;
      }
    });

    await initCamera(widget.cameras[_selecteCameraIndex]);
  }

  Future<void> initCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.bgra8888, //ImageFormatGroup.bgra8888
    );

    // Initialize controller
    try {
      initialiseControllerFuture = _cameraController.initialize().then((value) {
        _cameraController.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
        _cameraController.getMinZoomLevel().then((value) => _minAvailableZoom = value);
        _cameraController.setFlashMode(FlashMode.off);
        _cameraController.lockCaptureOrientation();
      });
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    _cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_cameraController.value.hasError) {
        print("error controller camera ${_cameraController.value.errorDescription}");
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController.setExposurePoint(offset);
    _cameraController.setFocusPoint(offset);
  }

  void activationDuFlash({required int idCamera, required CameraController camController}) {
    if (idCamera == 1) {
      setState(() {
        _flashFront = !_flashFront;
      });
    } else {
      if (camController.value.flashMode == FlashMode.off || camController.value.flashMode == FlashMode.auto) {
        camController.setFlashMode(FlashMode.torch);
      } else {
        camController.setFlashMode(FlashMode.off);
      }
    }
  }

// WIDGETS
  Widget permissionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "On n'a pas la permission de l'appareil photo",
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              getPermissionStatus();
            },
            child: const Text("Peux tu nous l'accorder"),
          ),
        ],
      ),
    );
  }

  Widget cameraWidget() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController.value.previewSize?.height,
          height: _cameraController.value.previewSize?.width,
          child: CameraPreview(
            _cameraController,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  onTap: () => hideAdditionnalButtons(),
                  onTapDown: (details) => onViewFinderTap(details, constraints),
                  onDoubleTap: () {
                    _cameraToggle();
                  },
                  onVerticalDragStart: (details) {
                    _startZoom = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) async {
                    double zoomLevel = (_startZoom - details.globalPosition.dy) / 20;
                    zoomLevel = zoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom); // Limiter le zoom dans les bornes
                    await _cameraController.setZoomLevel(zoomLevel); // Mettre à jour le niveau de zoom
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget extraButton({Key? key, required Function() onTap, required IconData icon, Color color = Colors.white}) {
    return IconButton(
      key: key,
      onPressed: onTap,
      icon: Icon(icon, color: color),
      color: color,
    );
  }

  // TODO: à ameliorer gerer l'opaticiter ou laisser une sphère au millieu
  Widget flashFrontWidget({required bool on}) {
    return Visibility(
      visible: on,
      child: Container(color: const Color.fromARGB(150, 255, 255, 255)),
    );
  }

  Widget cameraWithButtonsWidget() {
    return Container(
      color: Colors.grey,
      child: Stack(
        children: [
          widget.cameras.isEmpty
              ? SizedBox.expand(
                  child: Image.file(
                    File('/Users/bobsmac/Desktop/Caseddu_flutter/assets/images/femmephoto.jpg'),
                    fit: BoxFit.cover, // L'image couvrira tout l'écran
                  ),
                )
              : cameraWidget(),
          flashFrontWidget(on: _flashFront),
          // parametre

          // le fond pas opaque
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: BackgroundButtonWidget(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 3,
                ),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.vertical,
                  children: [
                    // ADDITIONAL BUTTONS

                    extraButton(
                      key: _addButtonKey,
                      icon: Icons.add,
                      onTap: () {
                        // if (_showExtraButtons) {
                        //   hideAdditionnalButtons();
                        // } else {
                        //   showOverlay(context);
                        // }
                        setState(() {
                          _showExtraButtons = !_showExtraButtons; // Toggle l'affichage des boutons supplémentaires
                        });
                      },
                      color: Colors.white,
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) {
                        // Utilisation d'une courbe d'animation plus douce
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut, // Courbe d'animation plus naturelle
                        );
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(curvedAnimation),
                          //scale: animation,
                          child: FadeTransition(
                            opacity: curvedAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: _showExtraButtons
                          ? // Animation des boutons supplémentaires
                          additionnalButtons()
                          : const SizedBox.shrink(),
                    ),
                    // fash
                    extraButton(
                      icon: Icons.light_mode_outlined,
                      onTap: () async {
                        activationDuFlash(idCamera: _selecteCameraIndex, camController: _cameraController);
                      },
                      color: _cameraController.value.flashMode != FlashMode.torch ? Colors.white : const Color.fromARGB(255, 255, 235, 59),
                    ),

                    // flash auto
                    extraButton(
                      icon: Icons.flash_auto_sharp,
                      onTap: () async {
                        if (_cameraController.value.flashMode != FlashMode.auto) {
                          await _cameraController.setFlashMode(FlashMode.auto);
                        } else {
                          await _cameraController.setFlashMode(FlashMode.off);
                        }
                      },
                      color: _cameraController.value.flashMode != FlashMode.auto ? Colors.white : const Color.fromARGB(255, 255, 235, 59),
                    ),

                    // album photo
                    extraButton(
                      onTap: () {},
                      icon: Icons.photo_album_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void hideAdditionnalButtons() {
    setState(() {
      _showExtraButtons = false;
    });
  }

  Widget additionnalButtons() {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.vertical,
      spacing: 12,
      children: [
        extraButton(
          icon: Icons.camera,
          onTap: () async {
            // Action pour Option 1
          },
        ),
        extraButton(
          icon: Icons.photo,
          onTap: () {
            // Action pour Option 2
            setState(() {
              _showExtraButtons = false; // Fermer les boutons supplémentaires
            });
          },
        ),
        extraButton(
          icon: Icons.settings,
          onTap: () {
            // Action pour Option 3
            setState(() {
              _showExtraButtons = false; // Fermer les boutons supplémentaires
            });
          },
        ),
      ],
    );
  }

  Widget floatingActionButton() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.fromLTRB(10, 0, 0, 30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      child: FittedBox(
        child: InkWell(
          onLongPress: () {
            hideAdditionnalButtons();
            print('long');
          },
          child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () async {
                hideAdditionnalButtons();

                if (widget.cameras.isEmpty) {
                  // ignore: use_build_context_synchronously
                  XFile file = XFile('/Users/bobsmac/Desktop/Caseddu_flutter/assets/images/femmephoto.jpg');

                  // final croppedFile = await _cropImageToScreenSizeWithImage(file, context);
                  // setState(() {
                  //   _lastImage = croppedFile!.path;
                  // });
                  // context.push('/PrisePhoto2/:filePath', extra: _lastImage);
                  final croppedFile = cropImageToScreenSizeInIsolate(file, context);

                  _lastImage = '';
                } else {
                  await _prendrePhoto();
                  //context.push('/PrisePhoto/:filePath', extra: _lastImage);
                  //_lastImage = '';
                }
              }),
        ),
      ),
    );
  }
}

// Fonction pour recadrer l'image selon la taille de l'écran DONN2 PAR LE TYPE DE GIT
Future<void> _cropImageToScreenSizeInIsolateWithPort(Map<String, dynamic> arguments) async {
  // print("L'Isolate de recadrage d'image a commencé à tourner.");
  final SendPort sendPort = arguments['sendPort'];
  final double screenWidth = arguments['screenWidth'];
  final double screenHeight = arguments['screenHeight'];

  final String path = arguments['path'];

  // file
  final Uint8List capturedImgBytes = await File(path).readAsBytes();

  IMG.Image? img = IMG.decodeImage(capturedImgBytes);

  if (img != null) {
    // Calculer le ratio d'aspect de l'écran (width/height)
    double aspectRatio = screenWidth / screenHeight;

    // Ratio d'aspect de l'image capturée (width/height)
    double cameraRatio = aspectRatio; // Remplacer selon tes besoins réels si nécessaire

    int oldWidth = img.width;
    int oldHeight = img.height;

    /// Bug-Fix: Camera has a wrong orientation when the flash is activated
    if (oldHeight / oldWidth == cameraRatio) {
      img = IMG.copyRotate(img, angle: 90);
      oldWidth = img.width;
      oldHeight = img.height;
    }

    double newWidth = oldWidth.toDouble();
    double newHeight = oldHeight.toDouble();

    double x = 0;
    double y = 0;

    if (aspectRatio <= cameraRatio) {
      newWidth = oldHeight * aspectRatio;
      x = (oldWidth - newWidth) / 2;
    } else {
      newHeight = oldWidth / aspectRatio;
      y = (oldHeight - newHeight) / 2;
    }

    // Recadrer l'image selon le ratio d'aspect
    IMG.Image croppedImage = IMG.copyCrop(
      img,
      x: x.toInt(),
      y: y.toInt(),
      width: newWidth.toInt(),
      height: newHeight.toInt(),
    );

    // Appliquer l'orientation de l'image après recadrage
    croppedImage = IMG.bakeOrientation(croppedImage);

    // Enregistrer l'image recadrée
    final croppedImageFile = await File(path).writeAsBytes(IMG.encodeJpg(croppedImage));
    print(croppedImageFile.path);
    // Envoie le résultat à l'Isolate parent
    sendPort.send(croppedImageFile);
    //sendPort.send(null);
  }
  sendPort.send('lose');
}
