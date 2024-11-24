import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/parameter_entity.dart';


abstract class ParametreRepository {
  Future<Either<Failure, void>> deconnexion();
  Future<Either<Failure, ParameterEntity>> update({
    required ParameterParams parametreParams,
  });
}
