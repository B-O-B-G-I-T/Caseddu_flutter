import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_local_data_source.dart';
import '../datasources/event_remote_data_source.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EventModel>> getEvent({required EventParams eventParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        EventModel remoteEvent = await remoteDataSource.getEvent(eventParams: eventParams);

        localDataSource.cacheEvent(eventToCache: remoteEvent);

        return Right(remoteEvent);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        EventModel localEvent = await localDataSource.getLastEvent();
        return Right(localEvent);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }

  @override
  Future<Either<Failure, EventModel>> ajoutEvenement({required EventParams eventParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        EventModel evenementAjoute = eventParams.toEventModel();

        localDataSource.ajoutEvenement(evenementAjoute);

        return Right(evenementAjoute);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        EventModel evenementAjoute = eventParams.toEventModel();
        localDataSource.ajoutEvenement(evenementAjoute);
        return Right(evenementAjoute);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }
}
