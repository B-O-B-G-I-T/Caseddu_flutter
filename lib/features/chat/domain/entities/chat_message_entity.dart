class ChatMessageEntity {
  final String message;
  final String sendOrReceived; //sent or received
  final String timeStamp;
  late String typeMessage = 'Payload';
  final String id;
  ChatMessageEntity({required this.message, required this.sendOrReceived, required this.timeStamp, required this.typeMessage, required this.id});
}
