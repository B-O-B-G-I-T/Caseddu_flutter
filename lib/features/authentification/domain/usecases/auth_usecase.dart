import 'package:flutter_application_1/features/authentification/domain/repository/auth_domain_repository.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/nouveau_identifiant_entity.dart';

class AuthUseCase {
  final AuthDomainRepository authDomainRepository;

  AuthUseCase({required this.authDomainRepository});

  Future signIn({required IdentifiantEntity identifiant}) async {
    return authDomainRepository.signIn(identifiant: identifiant);
  }

  Future signup({required NouveauIdentifiantEntity nouveauIdentifiant}) async {
    return await authDomainRepository.signup(nouveauIdentifiant: nouveauIdentifiant);
  }
}
