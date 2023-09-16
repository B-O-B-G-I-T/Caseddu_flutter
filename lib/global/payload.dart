/// This is the model to transfer the message from one device to another.
class Payload {
  String id = '';
  String sender = '';
  String receiver = '';
  String message = '';
  String timestamp = '';
  bool broadcast = true;
  String type = '';
  Payload(this.id, this.sender, this.receiver, this.message, this.timestamp, this.type);
}

class Ack {
  String id = '';
  String type = "Ack";
  Ack(this.id);
}
