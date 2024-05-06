class ChatMessageEntity {
  final String id;
  final String sender;
  final String receiver;
  final DateTime timestamp;
  final String message;
  String images;
  final String type;

  ChatMessageEntity({
    required this.id, 
    required this.sender,
    required this.receiver,
    required this.timestamp,
    required this.message,
    required this.images,
    required this.type, 
    
  });

  set setImage(String newImages) {
    newImages = images;
  }
}
