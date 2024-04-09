class ChatMessageEntity {
  final String sender;
  final String receiver;
  final DateTime timestamp;
  final String message;
  final String images;
  final String type;
  final String id;

  ChatMessageEntity({
    required this.id, 
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
    required this.images,
    required this.type, 
    
  });
}
