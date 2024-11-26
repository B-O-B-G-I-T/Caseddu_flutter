// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:caseddu/features/chat/presentation/widgets/chat_widgets/page_chat/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:caseddu/core/params/params.dart';
import 'package:caseddu/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:photo_manager/photo_manager.dart';

class MyImagePickerForChat extends StatefulWidget {
  const MyImagePickerForChat({super.key, required this.chatProvider, required this.device, required this.converser});
  final ChatProvider chatProvider;
  final Device device;
  final String converser;
  @override
  State<MyImagePickerForChat> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<MyImagePickerForChat> {
  late List<AssetEntity> images;
  late List<AssetEntity> selectedImages;

  @override
  void initState() {
    super.initState();
    images = widget.chatProvider.images;
    selectedImages = widget.chatProvider.selectedImages;
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ImagePicker(
      images: images, 
      selectedImages: selectedImages,
      toggleSelection: toggleSelection,
      sendMessage: sendMessage,
    );
  }
  
  void toggleSelection(AssetEntity image) {
    setState(() {
      if (selectedImages.contains(image)) {
        selectedImages.remove(image);
      } else {
        selectedImages.add(image);
      }
    });
  }

  Future<void> sendMessage() async {
    if (widget.device.state == SessionState.notConnected) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.out_of_range,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.grey,
          fontSize: 16.0);
    } else {
      if (selectedImages.isNotEmpty) {
        var msgId = nanoid(21);
        var timestamp = DateTime.now();

        // Récupérer les paths des images sélectionnées
        List<String> imagePaths = [];
        for (var asset in selectedImages) {
          File? file = await asset.file; // Obtenir le fichier associé
          if (file != null) {
            imagePaths.add(file.path); // Ajouter le chemin du fichier à la liste
          }
        }

        var listImages = imagePaths.join(',');
        // print(listImages);

        ChatMessageParams chatMessageParams = ChatMessageParams(
          id: msgId,
          sender: 'bob',
          receiver: widget.converser,
          message: '',
          images: listImages,
          type: 'image',
          sendOrReceived: 'Send',
          timestamp: timestamp,
          ack: 0,
        );
        if (widget.device.state == SessionState.notConnected) {
          await widget.chatProvider.connectToDevice(widget.device);
        }
        widget.chatProvider.eitherFailureOrEnvoieDeMessage(chatMessageParams: chatMessageParams);
      }
    }
    selectedImages.clear();
  }
}
