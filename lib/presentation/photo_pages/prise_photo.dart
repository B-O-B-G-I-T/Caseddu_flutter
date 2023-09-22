import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrisePhoto extends StatefulWidget {
  const PrisePhoto({super.key, required this.lastImage});
  final String lastImage;
  @override
  State<PrisePhoto> createState() => _PrisePhotoState();
}

class _PrisePhotoState extends State<PrisePhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close_rounded)),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image(
            image: FileImage(
              File(widget.lastImage),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/EnvoieDePhotoPage', extra: widget.lastImage);
        },
        label: Text(
          'Publier',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
