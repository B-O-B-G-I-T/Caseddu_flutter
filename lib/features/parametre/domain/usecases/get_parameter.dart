import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../repositories/parameter_repository.dart';

class GetParametre {
  final ParametreRepository parametreRepository;

  GetParametre({required this.parametreRepository});

  Future<Either<Failure, void>> call({
    required ParametreParams parametreParams,
  }) async {
    return await parametreRepository.deconnexion(parametreParams: parametreParams);
  }
}
