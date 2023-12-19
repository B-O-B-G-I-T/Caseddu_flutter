import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/features/chat/data/models/chat_message_model.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });


  @override
  Future<Either<Failure, void>> envoieMessage({required ChatMessageParams chatMessageParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        await remoteDataSource.sentToConversations(chatMessageParams: chatMessageParams);

        await localDataSource.enregistreDansLesConversations(chatMessageParams: chatMessageParams);

        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        // todo peutetre fzire un truc 
        return const Right(null);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }
}
