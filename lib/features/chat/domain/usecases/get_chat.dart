import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../repositories/chat_repository.dart';

class GetChat {
  final ChatRepository chatRepository;

  GetChat({required this.chatRepository});

  Future<Either<Failure, NearbyService>> init() async {
    return await chatRepository.init();
  }

  Future<Either<Failure, List<ChatMessageEntity>>> getConversation(String senderName, String receiverName, {DateTime? beforeDate, int limit = 20}) async {
    return await chatRepository.getConversation( senderName,  receiverName, beforeDate: beforeDate, limit: limit);
  }
Future<Either<Failure, List<UserEntity>>> getAllConversations() async {
    return await chatRepository.getAllConversations();
  }

  Future<Either<Failure, ChatMessageEntity>> envoieMessage({required ChatMessageParams chatMessageParams}) async {
    return await chatRepository.envoieMessage(chatMessageParams: chatMessageParams);
  }

  Future<Either<Failure, ChatMessageEntity>> enregistreMessage({required ChatMessageParams chatMessageParams}) async {
    return await chatRepository.enregistreMessage(chatMessageParams: chatMessageParams);
  }

  Future<Either<Failure, void>> deleteMessage(ChatMessageEntity chatMessageEntity ) async {
    return await chatRepository.deleteMessage(chatMessageEntity: chatMessageEntity);
  }

  Future<Either<Failure, void>> deleteConversation(UserEntity userEntity) async {
    return await chatRepository.deleteConversation(  userEntity: userEntity);
  }

Future<Either<Failure, UserEntity>> saveSendedImageProfile({required UserParams userParams}) async {
    return await chatRepository.saveSendedImageProfile(userParams: userParams);
  }
Future<Either<Failure, UserEntity>> setUser({required UserParams userParams}) async {
    return await chatRepository.setUser(userParams: userParams);
  }

}
