import 'package:flutter/material.dart';

Color generateColorFromName(String name) {
    final int hashCode = name.hashCode & 0xFFFFFF;
    final double hue = (hashCode / 360) % 360; // Utilisation du hachage pour générer un hue
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.5).toColor(); // Convertir HSL en couleur
  }