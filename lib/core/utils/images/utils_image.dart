import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../p2p/fonctions.dart';


  Future<List<AssetEntity>> loadImages(BuildContext context) async {
    // Demander la permission
    List<AssetEntity> images = [];
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
      images = recentImages;

      return images;
    } else if (result.hasAccess) {
      // Accès limité accordé
      Utils.showLimitedAccessDialog(context: context);
      return await _loadAndDisplayLimitedImages(images);

    } else {
      // Permission refusée ou non demandée
      Utils.showPermissionDeniedDialog(context: context);
      return [];
    }
  }

  Future<List<AssetEntity>> _loadAndDisplayLimitedImages(List<AssetEntity> images) async {
    // Récupérez la liste des albums avec accès limité
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    // Si aucun album n'est trouvé, gérer le cas ici
    if (albums.isEmpty) {
      images = []; // Aucun image disponible
      return images;
    }

    // Accédez à l'album le plus récent (ou au premier album disponible)
    AssetPathEntity limitedAlbum = albums[0];

    // Chargez les images accessibles dans cet album
    List<AssetEntity> limitedImages = await limitedAlbum.getAssetListPaged(
      page: 0,
      size: await limitedAlbum.assetCountAsync,
    );

    // Mettez à jour l'état avec les images limitées disponibles
    images = limitedImages;
    return images;
  }

