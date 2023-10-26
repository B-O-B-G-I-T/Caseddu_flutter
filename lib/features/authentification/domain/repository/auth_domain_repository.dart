import 'package:flutter_application_1/features/authentification/domain/entities/identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/nouveau_identifiant_entity.dart';

abstract class AuthDomainRepository {
  Future signIn({required IdentifiantEntity identifiant});

  Future signup({required NouveauIdentifiantEntity nouveauIdentifiant});
}
