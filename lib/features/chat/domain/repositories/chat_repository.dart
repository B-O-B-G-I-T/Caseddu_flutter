import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';

abstract class ChatRepository {
  Future<Either<Failure, NearbyService>> init();
  Future<Either<Failure, List<ChatMessageEntity>>> getConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20});
  Future<Either<Failure, List<UserEntity>>> getAllConversations();
  Future<Either<Failure, ChatMessageEntity>> envoieMessage({
    required ChatMessageParams chatMessageParams,
  });
  Future<Either<Failure, ChatMessageEntity>> enregistreMessage({
    required ChatMessageParams chatMessageParams,
  });
  Future<Either<Failure, void>> deleteConversation({required UserEntity userEntity});
  Future<Either<Failure, void>> deleteMessage({required ChatMessageEntity chatMessageEntity});

  Future<Either<Failure, UserEntity>> saveSendedImageProfile({
    required UserParams userParams,
  });

  Future<Either<Failure, UserEntity>> setUser({
    required UserParams userParams,
  });
}
