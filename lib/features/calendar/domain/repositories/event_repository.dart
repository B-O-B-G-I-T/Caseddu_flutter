import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';

abstract class EventRepository {
  Future<Either<Failure, EventEntity>> getEvent({
    required EventParams eventParams,
  });
}
