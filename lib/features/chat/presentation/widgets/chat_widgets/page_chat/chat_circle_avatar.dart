// Dans widget_utils.dart
import 'package:caseddu/features/chat/data/models/chat_user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/utils/p2p/circle_avatar_with_text_or_image.dart';
import '../../../providers/chat_provider.dart';

class ChatCircleAvatar extends StatefulWidget {
  final String text;
  final String? image;
  final Color? backgroundColor; // Couleur spécifiée par l'utilisateur
  final double radius;
  final Function? customImage;
  final BuildContext context;
  const ChatCircleAvatar(
      {super.key, required this.text, this.image, this.backgroundColor, this.radius = 24.0, this.customImage, required this.context});

  @override
  State<ChatCircleAvatar> createState() => _ChatCircleAvatarState();
}

class _ChatCircleAvatarState extends State<ChatCircleAvatar> {
  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final user = chatProvider.users.firstWhere(
      (user) => user.name == widget.text,
      orElse: () => UserModel(id: '', name: '', pathImageProfile: ''), // Valeur par défaut
    );

    return CircleAvatarWithTextOrImage(
      backgroundColor: widget.backgroundColor,
      customImage: () {
        // Vérifier si l'utilisateur est inconnu
        final bool isUnknownUser = user.name.isEmpty;

        // Notifier si l'utilisateur est inconnu
        if (isUnknownUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Utilisateur inconnu. Attendez la première connexion.",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });
        } else {
          context.push("/ProfilePage/${widget.text}");
        }
      },
      image: user.pathImageProfile,
      radius: widget.radius,
      text: widget.text.isNotEmpty ? widget.text.toUpperCase() : "?",
    );
  }
}
