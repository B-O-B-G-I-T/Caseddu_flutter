
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

//! possible supprésion devait servir a faire la selection des photos
class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<AssetEntity> assets = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchAssets();
  }

  void _requestPermissionAndFetchAssets() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) {
      final albums = await PhotoManager.getAssetPathList(onlyAll: true);
      final recentAlbum = albums.first;
      final recentAssets =
          await recentAlbum.getAssetListPaged(page: 0, size: 100);

      setState(() {
        assets = recentAssets;
      });
    } else {
      print('Permission to access photos was denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return AssetThumbnail(asset: assets[index]);
      },
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  const AssetThumbnail({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: asset.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
