import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  //pour la camera
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> initialiseControllerFuture;
  int _selecteCameraIndex = -1;
  String _lastImage = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: _lastImage != ''
              ? IconButton(
                  onPressed: () {
                    setState(
                      () {
                        _lastImage = '';
                      },
                    );
                  },
                  icon: Icon(Icons.close_rounded))
              : null,
        ),
        body: FutureBuilder(
          future: initialiseControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.previewSize?.height,
                        height: _controller.value.previewSize?.width,
                        child: _lastImage != ''
                            ? Image(
                                image: FileImage(
                                  File(_lastImage),
                                ),
                              )
                            : CameraPreview(_controller),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _lastImage == '',
                    child: Positioned(
                      left: 20,
                      bottom: 120,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: CircleBorder(),
                            child: Icon(
                              Icons.photo_album_outlined,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            onTap: () => print("object"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _lastImage == '',
                    child: Positioned(
                      left: 90,
                      bottom: 120,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: CircleBorder(),
                            child: Icon(
                              Icons.loop_outlined,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            onTap: _cameraToggle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _loading == true,
                    child: Positioned(
                      bottom: 30,
                      left: 150,
                      child: Row(
                        children: [
                          Text(
                            "Publication",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SpinKitWave(
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return Center(
              child: Text("Chargement"),
            );
          },
        ),
        floatingActionButton: _lastImage == ''
            ? Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                child: FittedBox(
                  child: InkWell(
                    onLongPress: () => print('long'),
                    child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: _prendrePhoto),
                  ),
                ),
              )
            : FloatingActionButton.extended(
                onPressed: () async {
                  setState(() => _loading = !_loading);

                  await Future.delayed(Duration(seconds: 3));
                  setState(() => _lastImage = '');
                  setState(() => _loading = !_loading);
                },
                label: Text(
                  'Publish',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
      ),
    );
  }

  Future<void> initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    //initialiseControllerFuture = _controller.initialize();

    // Initialize controller
      try {
        initialiseControllerFuture =  _controller.initialize();
      } on CameraException catch (e) {
        print('Error initializing camera: $e');
      }
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_controller.value.hasError) {
        print("error controller camera ${_controller.value.errorDescription}");
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
      _selecteCameraIndex = _selecteCameraIndex > -1
          ? _selecteCameraIndex == 0
              ? 1
              : 0
          : 0;
    });

    await initCamera(widget.cameras[_selecteCameraIndex]);
  }

  Future<void> _prendrePhoto() async {
    try {
      await initialiseControllerFuture;

      String cheminVersImage = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile file = await _controller.takePicture();
      await file.saveTo(cheminVersImage);
      setState(() {
        _lastImage = cheminVersImage;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

      _cameraToggle();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
