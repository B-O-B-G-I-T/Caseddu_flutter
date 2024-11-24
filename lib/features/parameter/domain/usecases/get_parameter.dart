import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/parameter_entity.dart';
import '../repositories/parameter_repository.dart';

class GetParametre {
  final ParametreRepository parametreRepository;

  GetParametre({required this.parametreRepository});

  Future<Either<Failure, void>> call() async {
    return await parametreRepository.deconnexion();
  }
  Future<Either<Failure, ParameterEntity>> update({
    required ParameterParams parametreParams,
  }) async {
    return await parametreRepository.update(parametreParams: parametreParams);
  }
}
