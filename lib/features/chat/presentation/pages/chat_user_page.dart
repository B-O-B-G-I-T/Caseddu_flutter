import 'package:caseddu/core/utils/genral_widgets/leading_button_go_back.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/circle_avatar_with_text_or_image.dart';
import '../../data/models/chat_user_model.dart';
import '../providers/chat_provider.dart';

class ChatUserPage extends StatefulWidget {
  final String userName;
  const ChatUserPage({required this.userName, super.key});

  @override
  State<ChatUserPage> createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    // TODO: faire une requete pour avoir tout de l'utilisateur
    final user = chatProvider.users.firstWhere(
      (user) => user.name == widget.userName,
      orElse: () => UserModel(id: '', name: '', pathImageProfile: ''), // Valeur par défaut
    );

    return Scaffold(
      appBar: AppBar(
        leading: const LeadingButtonGoBack(),
        title: Text(widget.userName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatarWithTextOrImage(
                text: user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                radius: 64,
                image: user.pathImageProfile,
              ),
              Text(
                'Nom d\'utilisateur: ${user.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ceci est la description de l\'utilisateur. Vous pouvez ajouter plus d\'informations ici.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
