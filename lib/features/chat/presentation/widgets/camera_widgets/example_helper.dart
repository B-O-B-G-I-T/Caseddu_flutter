// Dart imports:
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../../../../../core/utils/p2p/fonctions.dart';
import 'preview_img.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? editedBytes;
  double? _generationTime;
  DateTime? startEditingTime;

  Future<void> onImageEditingStarted() async {
    //startEditingTime = DateTime.now();
  }

  Future<void> onImageEditingComplete(bytes) async {
    editedBytes = bytes;
    setGenerationTime();
  }

  void setGenerationTime() {
    if (startEditingTime != null) {
      _generationTime = DateTime.now().difference(startEditingTime!).inMilliseconds.toDouble();
    }
  }

  void onCloseEditor({
    bool showThumbnail = false,
    ui.Image? rawOriginalImage,
    final ImageGenerationConfigs? generationConfigs,
  }) async {
    if (editedBytes != null) {
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;
      
      String stringEditedBytes = base64Encode(editedBytes!);
      context.push('/EnvoieDePhotoPage', extra: stringEditedBytes);

      // editorKey.currentState?.disablePopScope = true;
      //   await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) {
      //         return PreviewImgPage(
      //           imgBytes: editedBytes!,
      //           generationTime: _generationTime,
      //           showThumbnail: showThumbnail,
      //           rawOriginalImage: rawOriginalImage,
      //           generationConfigs: generationConfigs,
      //         );
      //       },
      //     ),
      //   ).whenComplete(() {
      //     editedBytes = null;
      //     _generationTime = null;
      //     startEditingTime = null;
      //   });
      // }
      // if (mounted) Navigator.pop(context);
    }
  }
}
