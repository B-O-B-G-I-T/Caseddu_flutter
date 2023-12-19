import 'package:data_connection_checker_tv/data_connection_checker.dart';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/chat/data/datasources/databasehelper.dart';
import 'package:flutter_application_1/global/global.dart';
import 'package:flutter_application_1/global/payload.dart';
import 'package:flutter_application_1/modeles/messages_model.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat.dart';
import '../../data/datasources/chat_local_data_source.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';

class ChatProvider extends ChangeNotifier {
  ChatMessageEntity? chat;
  Failure? failure;

  ChatProvider({
    this.chat,
    this.failure,
  });

  Future<void> eitherFailureOrEnvoieDeMessage({required ChatMessageParams chatMessageParams}) async {
    chatMessageParams.sender = Global.myName;
    Global.cache[chatMessageParams.id] = chatMessageParams;
    insertIntoMessageTable(chatMessageParams);

    ChatRepositoryImpl repository = ChatRepositoryImpl(
      remoteDataSource: ChatRemoteDataSourceImpl(

      ),
      localDataSource: ChatLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrChat = await GetChat(chatRepository: repository).envoieMessage(
      chatMessageParams: chatMessageParams,
    );

    failureOrChat.fold(
      (Failure newFailure) {
        chat = null;
        failure = newFailure;
        notifyListeners();
      },
      (void d) {
        chat = null;
        failure = null;
        notifyListeners();
      },
    );
  }
}
