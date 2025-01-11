import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomWidget extends StatelessWidget {
  final String chatId;
  final String chatroomName;
  final String username;

  const ChatRoomWidget({
    super.key,
    required this.chatId,
    required this.chatroomName,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
            ),
            const SizedBox(width: 5),
            Text(chatroomName),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Text(username),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ChatRoomPanelWidget(chatId: chatId),
          ChatMessageBoxWidget(
            chatId: chatId,
            username: username,
          ),
        ],
      ),
    );
  }
}

class ChatMessageBoxWidget extends StatelessWidget {
  final String chatId;
  final String username;

  ChatMessageBoxWidget({
    super.key,
    required this.chatId,
    required this.username,
  });

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': _messageController.text,
      'senderId': username,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'พิมพ์ข้อความ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.blue,
            ),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}

class ChatRoomPanelWidget extends StatelessWidget {
  const ChatRoomPanelWidget({
    super.key,
    required this.chatId,
  });

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('ไม่มีข้อความก่อนหน้า');
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];

              return ListTile(
                title: Text(message['text']),
                subtitle: Text(
                  message['senderId'],
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
