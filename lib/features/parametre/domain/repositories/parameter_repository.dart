import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';


abstract class ParametreRepository {
  Future<Either<Failure, void>> deconnexion({
    required ParametreParams parametreParams,
  });
}
