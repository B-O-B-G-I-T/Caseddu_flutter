import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/connection/network_info.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';

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
  Future<Either<Failure, NearbyService>> init() async {
    try {
      NearbyService nearbyService = await remoteDataSource.init();

      return Right(nearbyService);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageModel>>> getConversation(String senderName, String receiverName) async {
    //if (await networkInfo.isConnected!) {
    try {
      List<ChatMessageModel> listChatModel = await localDataSource.getConversation(senderName, receiverName);

      return Right(listChatModel);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
    // } else {
    //   return Left(ServerFailure(errorMessage: "Erreur connection"));
    // }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getAllConversations() async {
    //if (await networkInfo.isConnected!) {
    try {
      List<UserModel> listChatModel = await localDataSource.getAllConversation();

      return Right(listChatModel);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
    // } else {
    //   return Left(ServerFailure(errorMessage: "Erreur connection"));
    // }
  }

  @override
  Future<Either<Failure, ChatMessageModel>> envoieMessage({required ChatMessageParams chatMessageParams}) async {
    ChatMessageModel chatMessageModel;

    try {
      chatMessageModel = await remoteDataSource.sentToConversations(chatMessageParams: chatMessageParams);

      await localDataSource.insertMessage(chatMessageModel: chatMessageModel, isSender: true);

      return Right(chatMessageModel);
    } on ServerException {
      return Left(ServerFailure(errorMessage: 'This is a server exception'));
    }
  }

  @override
  Future<Either<Failure, ChatMessageModel>> enregistreMessage({required ChatMessageParams chatMessageParams}) async {
    //if (await networkInfo.isConnected!) {
    try {
      ChatMessageModel chatMessageModel = chatMessageParams.toModel();
      await localDataSource.insertMessage(chatMessageModel: chatMessageModel, isSender: false);

      return Right(chatMessageModel);
    } catch (e) {
      return Left(ServerFailure(errorMessage: e.toString()));
    }
    // } else {
    //   return Left(ServerFailure(errorMessage: "Erreur connection"));
    // }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(UserEntity userEntity) async {
      try {
        await localDataSource.deleteConversation(userEntity);
        return Right(true);
      } catch (e) {
        return Left(ServerFailure(errorMessage: e.toString()));
      }
    }
  }

