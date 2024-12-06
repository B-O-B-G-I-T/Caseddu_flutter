import 'package:caseddu/features/chat/presentation/providers/chat_provider.dart';
import 'package:caseddu/features/parameter/presentation/providers/parameter_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../chat/presentation/widgets/chat_widgets/page_chat/image_picker.dart';

class ImagePickerForParams extends StatefulWidget {
  const ImagePickerForParams({super.key, required this.parameterProvider});
  final ParameterProvider parameterProvider;
  @override
  State<ImagePickerForParams> createState() => _ImagePickerForParamsState();
}

class _ImagePickerForParamsState extends State<ImagePickerForParams> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => closeGallery(context),
                ),
                const Spacer(),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    await widget.parameterProvider.eitherFailureOrSelectedImageProfile(widget.parameterProvider.selectedImages.first);
                    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
                    await chatProvider.sendImageProfileForAllConnected();
                    closeGallery(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ImagePicker(
                    images: widget.parameterProvider.images,
                    selectedImages: widget.parameterProvider.selectedImages,
                    toggleSelection: widget.parameterProvider.toggleSelection,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void closeGallery(BuildContext context) {
    Navigator.pop(context);
  }
}
