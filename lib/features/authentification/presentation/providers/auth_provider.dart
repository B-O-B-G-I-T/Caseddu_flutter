import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/nouveau_identifiant_entity.dart';

class AuthProvider extends ChangeNotifier {
  IdentifiantEntity? identifiantEntity;
  NouveauIdentifiantEntity? nouveauIdentifiant;

  AuthProvider({required IdentifiantEntity identifiantEntity, required NouveauIdentifiantEntity nouveauIdentifiant});


}
