// ignore_for_file: file_names
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/camera_widgets/modifier_picture_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrisePhoto extends StatefulWidget {
  const PrisePhoto({super.key, required this.lastImageCompleter});
  final Completer<String?> lastImageCompleter;

  @override
  State<PrisePhoto> createState() => _PrisePhotoState();
}

class _PrisePhotoState extends State<PrisePhoto> {
  double _dragExtent = 0.0;
  // Variable pour suivre l'étendue du glissement
  double _dragText = 0.0;
  // Variable pour suivre l'étendue du glissement
  final int _animationValue = 300;

  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<String?>(
        future: widget.lastImageCompleter.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Affiche le chargement
          } else if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.error_message(snapshot.error.toString()))); // Gestion d'erreur
          } else if (!snapshot.hasData) {
            return Center(child: Text(AppLocalizations.of(context)!.no_image_available)); // Gestion d'erreur
          }

          final croppedImagePath = snapshot.data!;

          return Stack(
            children: [
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _dragExtent = (_dragExtent + details.delta.dy).clamp(0.0, 120.0);
                    if (_dragExtent < 105) {
                      _dragText = _dragExtent - 50;
                    } else if (_dragExtent >= 105) {
                      _dragText = 55;
                    }
                    _isDragging = _dragExtent > 0;
                  });
                },
                onVerticalDragEnd: (details) {
                  if (_dragExtent >= 110.0) {
                    context.pop();
                  } else {
                    setState(() {
                      _dragExtent = 0.0;
                      _dragText = 0.0;
                      _isDragging = false;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: _animationValue),
                  transform: Matrix4.translationValues(0, _dragExtent, 0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    // ici on affiche l'image
                    child: ModifierPictureWidget(
                      pathImage: croppedImagePath,
                    ),
                  ),
                ),
              ),
              if (_isDragging)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: _animationValue),
                      transform: Matrix4.translationValues(0, _dragText, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 39, 39, 39),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:  Text(AppLocalizations.of(context)!.cancel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
