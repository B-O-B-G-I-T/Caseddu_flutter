import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/camera_widgets/modifier_picture_widget.dart';

class PrisePhoto extends StatefulWidget {
  const PrisePhoto({Key? key, required this.lastImage}) : super(key: key);
  final String lastImage;

  @override
  State<PrisePhoto> createState() => _PrisePhotoState();
}

class _PrisePhotoState extends State<PrisePhoto> {
  double _dragExtent = 0.0; // Variable pour suivre l'étendue du glissement
  double _dragText = 0.0; // Variable pour suivre l'étendue du glissement
  int _animationValue = 300;

  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                // Limiter l'étendue du glissement à 120 pixels
                _dragExtent = (_dragExtent + details.delta.dy).clamp(0.0, 120.0);
                print('_dragExtent ${_dragExtent}');
                print('_dragText ${_dragText}');

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
                _dragExtent = MediaQuery.of(context).size.height;
                _animationValue = 300;
              } else {
                // Réinitialise l'étendue avec une animation fluide
                setState(() {
                  _dragExtent = 0.0;
                  _dragText = 0.0;
                  _isDragging = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: _animationValue), // Animation fluide
              transform: Matrix4.translationValues(0, _dragExtent, 0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: ModifierPictureWidget(
                  pathImage: widget.lastImage,
                ),
              ),
            ),
          ),
          // Afficher "Annuler" seulement pendant le glissement
          if (_isDragging)
            Positioned(
              top: 0, // Positionnement animé du texte
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
                    child: const Text(
                      'Annuler',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/EnvoieDePhotoPage', extra: widget.lastImage);
        },
        label: const Text('Publier', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.send, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
