// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/chat_widgets/loader_for_chat.dart';

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
    ResolutionPreset.max,
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
      await file.saveTo(cheminVersImage);
      setState(() {
        _lastImage = cheminVersImage;
      });
    } catch (e) {
      print('Erreur lors de la capture de la photo : $e');
    }
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

  Widget extraButton({Key? key, required Function() onTap, required IconData icon, Color color = const Color.fromARGB(180, 255, 255, 255)}) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
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
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54, // Fond plus sombre
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ADDITIONAL BUTTONS
                  Stack(
                    alignment: Alignment.center,
                    children: [
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
                        color: const Color.fromARGB(180, 255, 255, 255),
                      ),
                    ],
                  ),

                  // Animation des boutons supplémentaires
                  additionnalButtons(),
                  const SizedBox(height: 10),

                  // fash
                  extraButton(
                    icon: Icons.light_mode_outlined,
                    onTap: () async {
                      activationDuFlash(idCamera: _selecteCameraIndex, camController: _cameraController);
                    },
                    color: _cameraController.value.flashMode != FlashMode.torch
                        ? const Color.fromARGB(180, 255, 255, 255)
                        : const Color.fromARGB(180, 255, 235, 59),
                  ),
                  const SizedBox(height: 10),

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
                    color: _cameraController.value.flashMode != FlashMode.auto
                        ? const Color.fromARGB(180, 255, 255, 255)
                        : const Color.fromARGB(180, 255, 235, 59),
                  ),
                  const SizedBox(height: 10),

                  // album photo
                  extraButton(
                    onTap: () {},
                    icon: Icons.photo_album_outlined,
                  ),
                ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showExtraButtons ? 162 : 0, // Contrôle la hauteur de l'espace animé
      child: _showExtraButtons
          ? Column(
              children: [
                const SizedBox(height: 10),
                extraButton(
                  icon: Icons.camera,
                  onTap: () async {
                    // Action pour Option 1
                    print(await compute(testFunction, ""));
                  },
                ),
                const SizedBox(height: 10),
                extraButton(
                  icon: Icons.photo,
                  onTap: () {
                    // Action pour Option 2
                    setState(() {
                      _showExtraButtons = false; // Fermer les boutons supplémentaires
                    });
                  },
                ),
                const SizedBox(height: 10),
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
            )
          : const SizedBox(),
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
          color: Colors.white.withOpacity(0.5),
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
                await _prendrePhoto();

                if (widget.cameras.isEmpty) {
                  // ignore: use_build_context_synchronously
                  context.push('/PrisePhoto/:filePath', extra: "/Users/bobsmac/Desktop/Caseddu_flutter/assets/images/femmephoto.jpg");
                  _lastImage = '';
                } else {
                  // ignore: use_build_context_synchronously
                  context.push('/PrisePhoto/:filePath', extra: _lastImage);
                  _lastImage = '';
                }
              }),
        ),
      ),
    );
  }

  Future<String> testFunction(String s) async {
    Timer timer = Timer(const Duration(seconds: 15), () {
      print("Finished");
    }); // Timer
    await Future.delayed(const Duration(seconds: 15));
    return "Anything";
  }

// pourrais etre intéressant pour traité les images
  // Future<void> _prendrePhoto2() async {
  //   try {
  //     await initialiseControllerFuture;

  //     final XFile file = await _cameraController.takePicture();

  //     img.Image? image = img.decodeImage(File(file.path).readAsBytesSync());

  //     // Appliquer la rotation à l'image
  //     img.Image invertedImage = img.copyRotate(image!, angle: 180);

  //     // Sauvegarder l'image transformée
  //     String cheminVersImage = join(
  //       (await getTemporaryDirectory()).path,
  //       '${DateTime.now().millisecondsSinceEpoch}.jpg',
  //     );

  //     File(cheminVersImage).writeAsBytesSync(img.encodeJpg(invertedImage));

  //     setState(() {
  //       _lastImage = cheminVersImage;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
