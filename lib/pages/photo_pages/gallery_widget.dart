import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//! fais avec le nico 
class GalerieWidget extends StatefulWidget {
  const GalerieWidget({super.key, });

  @override
  State<GalerieWidget> createState() => _GalerieWidgetState();
}

class _GalerieWidgetState extends State<GalerieWidget> {
  String imagePath = "";

  void getImage() async {
    ImagePicker picker = ImagePicker();
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    imagePath = pickedImage!.path;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
    );
  }
}
