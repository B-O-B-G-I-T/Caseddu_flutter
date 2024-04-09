import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {

  Future<Either<Failure, void>> envoieMessage({
    required ChatMessageParams chatMessageParams,
  });
}
