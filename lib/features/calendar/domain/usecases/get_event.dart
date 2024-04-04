import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../repositories/event_repository.dart';

class GetEvent {
  final EventRepository eventRepository;

  GetEvent({required this.eventRepository});

  Future<Either<Failure, EventEntity>> call({
    required EventParams eventParams,
  }) async {
    return await eventRepository.getEvent(eventParams: eventParams);
  }
}
