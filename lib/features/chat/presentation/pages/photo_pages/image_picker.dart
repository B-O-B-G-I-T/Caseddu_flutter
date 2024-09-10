import 'dart:io';
import 'dart:typed_data';

import 'package:caseddu/core/params/params.dart';
import 'package:caseddu/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:photo_manager/photo_manager.dart';

class MyImagePicker extends StatefulWidget {
  const MyImagePicker({super.key, required this.chatProvider, required this.device, required this.converser});
  final ChatProvider chatProvider;
  final Device device;
  final String converser;
  @override
  State<MyImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<MyImagePicker> {
  List<AssetEntity> images = [];
  List<AssetEntity> selectedImages = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    // Demander la permission
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      // Permission accordée, on charge les images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      List<AssetEntity> recentImages = await albums[0].getAssetListPaged(
        page: 0,
        size: await albums[0].assetCountAsync,
      );
      setState(() {
        images = recentImages;
      });
    } else if (result.hasAccess) {
      // Accès limité accordé
      await _loadAndDisplayLimitedImages();
      _showLimitedAccessDialog();
    } else {
      // Permission refusée ou non demandée
      _showPermissionDeniedDialog();
    }
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

  Future<void> _loadAndDisplayLimitedImages() async {
    // Récupérez la liste des albums avec accès limité
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    // Si aucun album n'est trouvé, gérer le cas ici
    if (albums.isEmpty) {
      setState(() {
        images = []; // Aucun image disponible
      });
      return;
    }

    // Accédez à l'album le plus récent (ou au premier album disponible)
    AssetPathEntity limitedAlbum = albums[0];

    // Chargez les images accessibles dans cet album
    List<AssetEntity> limitedImages = await limitedAlbum.getAssetListPaged(
      page: 0,
      size: await limitedAlbum.assetCountAsync,
    );

    // Mettez à jour l'état avec les images limitées disponibles
    setState(() {
      images = limitedImages;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'Cette application a besoin d\'accès à vos photos pour fonctionner correctement. Veuillez activer les autorisations dans les paramètres de l\'application.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ouvrir les paramètres'),
              onPressed: () {
                Navigator.of(context).pop();
                // Ouvrir les paramètres de l'application
                PhotoManager.openSetting();
              },
            ),
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLimitedAccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accès limité'),
          content: const Text(
            'Vous avez accordé un accès limité aux photos. Cela peut restreindre certaines fonctionnalités de l\'application. Pour une expérience complète, veuillez accorder un accès complet dans les paramètres de l\'application.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ouvrir les paramètres'),
              onPressed: () {
                Navigator.of(context).pop();
                PhotoManager.openSetting();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Uint8List?>(
                      future: images[index].thumbnailData,
                      builder: (context, snapshot) {
                        final bytes = snapshot.data;
                        if (bytes == null) return const CircularProgressIndicator();

                        final isSelected = selectedImages.contains(images[index]);

                        return GestureDetector(
                          onTap: () {
                            toggleSelection(images[index]);
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (isSelected)
                                const Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        );
                      });
                }),
          ),
          if (selectedImages.isNotEmpty)
            Positioned(
              height: 50,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: const Icon(Icons.send)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    
    if (widget.device.state == SessionState.notConnected) {

      Fluttertoast.showToast(
          msg: 'hors de portée',
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
          msgId,
          'bob',
          widget.converser,
          '',
          listImages,
          'Image',
          'Send',
          timestamp,
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
