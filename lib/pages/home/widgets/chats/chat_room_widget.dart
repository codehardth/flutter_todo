import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatRoomWidget extends StatefulWidget {
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
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  Future<void> _subscribeToTopic() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(widget.chatroomName.toLowerCase());
      print('*** 🟢Subscribed to topic: ${widget.chatroomName.toLowerCase()}');
    } catch (e) {
      print('*** 🟢Error subscribing to topic: $e');
    }
  }

  Future<void> _unsubscribeFromTopic() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(widget.chatroomName.toLowerCase());
      print('*** 🟢Unsubscribed from topic: ${widget.chatroomName.toLowerCase()}');
    } catch (e) {
      print('*** 🟢Error unsubscribing from topic: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _subscribeToTopic();
  }

  @override
  void dispose() {
    _unsubscribeFromTopic();
    super.dispose();
  }

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
            Text(widget.chatroomName),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Text(widget.username),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ChatRoomPanelWidget(chatId: widget.chatId),
          ChatMessageBoxWidget(
            chatId: widget.chatId,
            username: widget.username,
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
      'userId': username,
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
                  message['userId'],
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
