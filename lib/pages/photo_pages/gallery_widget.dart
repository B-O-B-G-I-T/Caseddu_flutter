import 'package:flutter/material.dart';

class GalerieWidget extends StatefulWidget {
  const GalerieWidget({super.key, required this.textEditingController});
  final TextEditingController textEditingController;

  @override
  State<GalerieWidget> createState() => _GalerieWidgetState();
}

class _GalerieWidgetState extends State<GalerieWidget> {
  final String imagePath = "";

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

@override
Widget GalerieWidget2() {
  return Center(
    child: Container(
      color: Colors.amber,
      height: 50,
      width: 50,
    ),
  );
}
