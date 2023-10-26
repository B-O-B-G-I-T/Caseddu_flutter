import 'package:flutter_application_1/features/authentification/data/data_source/auth_data_remote.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/nouveau_identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/repository/auth_domain_repository.dart';

class AuthDataRepository implements AuthDomainRepository {
  final AuthDataRemote authDataRemote;

  AuthDataRepository({required this.authDataRemote});

  @override
  Future signIn({required IdentifiantEntity identifiant}) async {
    return await authDataRemote.signIn(identifiant: identifiant);
  }

  @override
  Future signup({required NouveauIdentifiantEntity nouveauIdentifiant}) async {
    return await authDataRemote.signup(nouveauIdentifiant: nouveauIdentifiant);
  }
}
