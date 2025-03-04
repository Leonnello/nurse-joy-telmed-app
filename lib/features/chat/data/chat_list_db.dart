import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class Chat {
  // ghet the chatlist by checking if the userID is included in the users pair in the chat doc
  Stream<QuerySnapshot> getChatList(String userID) {
    return db
        .collection('chats')
        .where('users', arrayContains: userID)
        .snapshots();
  }

  Stream<QuerySnapshot> getOnlineUsers() {
    return db.collection('users').snapshots();
  }

  // function to generate the chatroom
  Future<void> generateChatRoom(
      String chatRoomID, String userID, String recipientID) async {
    await db.collection('chats').doc(chatRoomID).set({
      'users': [userID, recipientID],
      'last_message': '',
    });
  }

  String generateChatRoomID(String userID, String recipientID) {
    List<String> chatRoomUsers = [userID, recipientID]..sort();
    return '${chatRoomUsers[0]}_${chatRoomUsers[1]}';
  }

  // function to get the recipient user details
  Future<DocumentSnapshot<Object>> getRecipientDetails(String userID) async {
    return await db.collection('users').doc(userID).get();
  }

  Stream<QuerySnapshot> getChatRoomMessages(String chatRoomID) {
    return db
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // function to send a message
  Future<void> sendMessage(String chatRoomID, String? userID,
      String recipientID, String messageBody) async {
    await db.collection('chats').doc(chatRoomID).collection('messages').add({
      'senderID': userID,
      'recipientID': recipientID,
      'message_body': messageBody,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
