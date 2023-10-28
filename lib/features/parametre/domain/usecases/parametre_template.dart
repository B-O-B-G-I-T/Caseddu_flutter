import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/parametre/domain/repositories/parametre_repository.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';

class GetParametre {
  final ParametreRepository parametreRepository;

  GetParametre({required this.parametreRepository});

  Future<Either<Failure, void>> call({
    required ParametreParams parametreParams,
  }) async {
    return await parametreRepository.deconnexion(parametreParams: parametreParams);
  }
}
