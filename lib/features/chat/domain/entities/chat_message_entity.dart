class ChatMessageEntity {
  String? get id => _id;
  final String sender;
  final String receiver;
  final DateTime timestamp;
  final String message;
  final String images;
  final String type;
  String? _id;

  ChatMessageEntity({
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
    required this.images,
    required this.type, String? id, 
  });
}
