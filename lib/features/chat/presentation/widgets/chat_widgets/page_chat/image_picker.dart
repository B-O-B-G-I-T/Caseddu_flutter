// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:typed_data';
import 'package:caseddu/features/parameter/presentation/providers/parameter_provider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class ImagePicker extends StatefulWidget {
  const ImagePicker(
      {super.key, required this.toggleSelection, this.sendMessage, this.icon = Icons.send, required this.images, required this.selectedImages});
  final Function toggleSelection;
  final Function? sendMessage;
  final List<AssetEntity> images;
  final List<AssetEntity> selectedImages;
  final IconData icon;
  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  @override
  void initState() {
    super.initState();
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
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return Selector<ParameterProvider, bool>(
                      selector: (context, provider) => provider.selectedImages.contains(widget.images[index]),
                      builder: (context, isSelected, child) {
                        return FutureBuilder<Uint8List?>(
                          future: widget.images[index].thumbnailDataWithSize(const ThumbnailSize(500, 700)), // Taille des miniatures
                          builder: (context, snapshot) {
                            final bytes = snapshot.data;
                            if (bytes == null) return const Center(child: FittedBox(fit: BoxFit.contain, child: CircularProgressIndicator()));
                            return ImageItem(
                              image: widget.images[index],
                              isSelected: widget.selectedImages.contains(widget.images[index]),
                              onSelect: () {
                                widget.toggleSelection(widget.images[index]);
                              },
                            );
                          },
                        );
                      });
                }),
          ),
          if (widget.selectedImages.isNotEmpty && widget.sendMessage != null)
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
                          widget.sendMessage!();
                        },
                        icon: Icon(widget.icon)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageItem extends StatefulWidget {
  final AssetEntity image;
  final bool isSelected;
  final VoidCallback onSelect;

  const ImageItem({
    super.key,
    required this.image,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: widget.image.thumbnailDataWithSize(const ThumbnailSize(500, 700)),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const Center(child: FittedBox(fit: BoxFit.contain, child: CircularProgressIndicator()));
        }

        return GestureDetector(
          onTap: () {
            widget.onSelect();
          },
          child: Stack(
            children: [
              SizedBox.expand(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                ),
              ),
              if (widget.isSelected)
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              if (widget.isSelected)
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
      },
    );
  }
}
