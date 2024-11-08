import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:caseddu/features/chat/data/models/chat_message_model.dart';
import 'package:caseddu/features/chat/domain/entities/chat_user_entity.dart';
import 'package:caseddu/core/utils/p2p/fonctions.dart';
import 'package:caseddu/features/chat/presentation/providers/chat_provider.dart';
import 'package:caseddu/features/chat/presentation/widgets/P2P_widgets/list_tile_pour_utilisateur_connu.dart';
import 'package:caseddu/features/chat/presentation/widgets/P2P_widgets/search_widget.dart';

class ChatKnownListPage extends StatefulWidget {
  const ChatKnownListPage({super.key});

  @override
  State<ChatKnownListPage> createState() => _ChatKnownListPageState();
}

class _ChatKnownListPageState extends State<ChatKnownListPage> {
  final TextEditingController _searchController = TextEditingController();
  late ChatProvider chatProvider;
  List<UserEntity> allConversations = [];
  List<UserEntity> filteredConversations = [];
  List<ChatMessageModel?> lastMessages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.eitherFailureOrAllConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        allConversations = provider.users;
        lastMessages = allConversations.map((user) => user.dernierMessage).toList();

        // Filtrer les conversations si une recherche est en cours
        filteredConversations = _searchController.text.isEmpty
            ? allConversations
            : Utils.runFilter(
                _searchController.text,
                allConversations,
                (user) => user.name,
              );

        return Column(
          children: [
            // Barre de recherche pour filtrer les utilisateurs
            SearchWidget(
              onChanged: (query) {
                setState(() {
                  filteredConversations = Utils.runFilter(query, allConversations, (user) => user.name);
                });
              },
              searchController: _searchController,
            ),
            const SizedBox(height: 10),
            Expanded(
              // Affiche un message si aucune conversation n'est disponible
              child: filteredConversations.isEmpty
                  ? const Center(
                      child: Text("Pas de conversation"),
                    )
                  : ListView.builder(
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        final lastMessage = lastMessages[index];

                        return Dismissible(
                          key: Key('${conversation.id}-${DateTime.now().millisecondsSinceEpoch}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            provider.eitherFailureOrDeleteConversation(userEntity: conversation);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Supprimé",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          child: ListTilePourUtilisateurConnu(
                            deviceName: conversation.name,
                            message: lastMessage?.message ?? "Aucun message",
                            timestamp: lastMessage?.timestamp.toString() ?? "",
                            typeMessage: lastMessage?.type ?? "texte",
                            onTap: () {
                              context.push('/ChatPage/${conversation.name}');
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
