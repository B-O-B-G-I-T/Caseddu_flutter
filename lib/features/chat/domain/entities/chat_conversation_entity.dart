class ChatConversationEntity {
  final String sendOrReceived;
  final String message;
  final String id;
  final String converser;
  final String timeStamp;
  final String typeMessage;

  ChatConversationEntity({required this.sendOrReceived, required this.message, required this.id, required this.converser, required this.timeStamp, required this.typeMessage});
}
