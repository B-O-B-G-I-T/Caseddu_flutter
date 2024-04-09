import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../repositories/chat_repository.dart';

class GetChat {
  final ChatRepository chatRepository;

  GetChat({required this.chatRepository});


  Future<Either<Failure, void>> envoieMessage({
    required ChatMessageParams chatMessageParams,
  }) async {
    return await chatRepository.envoieMessage(chatMessageParams: chatMessageParams);
  }
}
