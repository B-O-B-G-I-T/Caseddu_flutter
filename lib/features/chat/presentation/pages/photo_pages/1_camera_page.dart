// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../widgets/widgets_for_chat/loader_for_chat.dart';

// TODO peut etre une bonne idée faire deux pages au lieu d'utilisé le wg visible
class CameraPage extends StatefulWidget {
  //pour la camera
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Future<void>? initialiseControllerFuture;
  int _selecteCameraIndex = -1;
  String _lastImage = '';
  // bool _loading = true;
  bool _flashFront = false;
  bool _isCameraPermissionGranted = false;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _startZoom = 0;

  @override
  void initState() {
    //_cameraToggle();

    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties

      _cameraToggle();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: initialiseControllerFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loaderForCamera();
          } else {
            if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else {
              return _isCameraPermissionGranted ? cameraWithButtonsWidget() : permissionWidget(); // Affiche le widget en fonction de la permission
            }
          }
        },
      ),
      //if( _isCameraPermissionGranted == "true") { cameraWithButtonsWidget()} elseif ( _isCameraPermissionGranted == "false"){ permissionWidget()},
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 0, 30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 3,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        child: FittedBox(
          child: InkWell(
            onLongPress: () => print('long'),
            child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  await _prendrePhoto();

                  // ignore: use_build_context_synchronously
                  context.push('/PrisePhoto', extra: _lastImage);
                  _lastImage = '';
                }),
          ),
        ),
      ),
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
      print(e);
    }
  }

  void getPermissionStatus() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      _cameraToggle();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  Future<void> initCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.bgra8888,
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
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "On n'a pas la persion de l'appareil photo",
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
                  onTapDown: (details) => onViewFinderTap(details, constraints),
                  onDoubleTap: () {
                    _cameraToggle();
                  },
                  onVerticalDragStart: (details) {
                    _startZoom = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) async {
                    double zoooooooom;
                    zoooooooom = (_startZoom - details.globalPosition.dy) / 20; // adjust zoom level based on vertical drag
                    if (zoooooooom < _minAvailableZoom) {
                      zoooooooom = _minAvailableZoom; // prevent zoom level from going below 0
                    }
                    if (zoooooooom > _maxAvailableZoom) {
                      zoooooooom = _maxAvailableZoom; // prevent zoom level from going above 10
                    }
                    _cameraController.setZoomLevel(zoooooooom); // set camera zoom level
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget extraButton({required Function() onTap, required IconData icon, Color color = const Color.fromARGB(180, 255, 255, 255)}) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 3,
          color: color,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
          ),
        ),
      ),
    );
  }

  // TODO: à ameliorer gerer l'opaticiter ou laisser une sphère au millieu
  Widget flashFrontWidget({required bool on}) {
    return Visibility(
      visible: on,
      child: Container(
        color: const Color.fromARGB(150, 255, 255, 255),
      ),
    );
  }

  Widget cameraWithButtonsWidget() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          widget.cameras.isEmpty
              ? const Center(
                  child: Text("pas de cameras"),
                )
              : FutureBuilder(
                  future: initialiseControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return cameraWidget();
                    }
                    return const Center();
                  },
                ),

          // fand blanc pour le flash Front
          flashFrontWidget(on: _flashFront),

          // galerie
          Positioned(
            left: 20,
            bottom: 120,
            child: extraButton(
              onTap: () {},
              icon: Icons.photo_album_outlined,
            ),
          ),

          // toggle
          Positioned(
            left: 120,
            bottom: 90,
            child: extraButton(
              icon: Icons.loop_outlined,
              onTap: _cameraToggle,
            ),
          ),

          // FLash
          Positioned(
            left: 120,
            bottom: 30,
            child: extraButton(
              icon: Icons.light_mode_outlined,
              onTap: () async {
                activationDuFlash(idCamera: _selecteCameraIndex, camController: _cameraController);
              },
              color: _cameraController.value.flashMode != FlashMode.torch
                  ? const Color.fromARGB(180, 255, 255, 255)
                  : const Color.fromARGB(180, 255, 235, 59),
            ),
          ),

          // FLASH AUTO
          Positioned(
            left: 60,
            bottom: 30,
            child: extraButton(
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
          ),
        ],
      ),
    );
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
