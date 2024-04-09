import 'package:caseddu/features/chat/domain/entities/chat_message_entity.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_user_model.dart';
import '../repositories/chat_repository.dart';

class GetChat {
  final ChatRepository chatRepository;

  GetChat({required this.chatRepository});

  Future<Either<Failure, NearbyService>> init() async {
    return await chatRepository.init();
  }

  Future<Either<Failure, List<ChatMessageEntity>>> getConversation(String senderName, String receiverName) async {
    return await chatRepository.getConversation( senderName,  receiverName);
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

}