import 'package:flutter/material.dart';

Widget loaderForCamera() {
  return Container(
    height: double.infinity,
    width: double.infinity,
    color: Colors.black,
    child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
  );
}
