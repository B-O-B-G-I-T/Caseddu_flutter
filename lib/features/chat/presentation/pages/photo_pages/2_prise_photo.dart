import 'dart:async';
import 'package:caseddu/features/chat/presentation/widgets/widgets_for_chat/loader_for_chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrisePhoto extends StatefulWidget {
  const PrisePhoto({Key? key, required this.lastImage}) : super(key: key);
  final String lastImage;

  @override
  State<PrisePhoto> createState() => _PrisePhotoState();
}

class _PrisePhotoState extends State<PrisePhoto> {
  late Future<void> _viewFuture;

  @override
  void initState() {
    super.initState();
    _viewFuture = _delayView();
  }

  Future<void> _delayView() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _viewFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loaderForCamera();
        } else {
          return _buildView();
        }
      },
    );
  }

  Widget _buildView() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(fit: BoxFit.cover, child: Image.asset(widget.lastImage)
            // Image(
            //   image: FileImage(File(widget.lastImage),),
            // ),
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
