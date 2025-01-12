import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../services/chat_services.dart';

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
          ChatRoomPanelWidget(chatRoomId: chatId),
          ChatMessageBoxWidget(
            chatRoomId: chatId,
            username: username,
          ),
        ],
      ),
    );
  }
}

class ChatMessageBoxWidget extends StatelessWidget {
  final String chatRoomId;
  final String username;

  ChatMessageBoxWidget({
    super.key,
    required this.chatRoomId,
    required this.username,
  });

  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    await ChatService().sendMessage(
      chatRoomId,
      text,
      username,
    );

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

class ChatRoomPanelWidget extends StatefulWidget {
  const ChatRoomPanelWidget({
    super.key,
    required this.chatRoomId,
  });

  final String chatRoomId;

  @override
  State<ChatRoomPanelWidget> createState() => _ChatRoomPanelWidgetState();
}

class _ChatRoomPanelWidgetState extends State<ChatRoomPanelWidget> {
  final List<DocumentSnapshot> _previousMessages = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final _chatService = ChatService();
  final ScrollController _scrollController =
      ScrollController(); // ScrollController

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // โหลดข้อความเมื่อเปิดหน้าจอ
    _scrollController.addListener(_onScroll); // ฟังการเลื่อนหน้าจอ
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ล้าง ScrollController
    super.dispose();
  }

  // ดัก event เมื่อผู้ใช้เลื่อนหน้าจอ
  void _onScroll() {
    if (_scrollController.position.pixels <= 50) {
      // ถ้าเลื่อนมาถึงด้านบนสุด (50 pixels เป็น buffer กันเล็กน้อย)
      _fetchMessages();
    }
  }

  Future<void> _fetchMessages() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // ดึงข้อความเก่า
      List<DocumentSnapshot> previousMessages =
          await _chatService.fetchMessages(
        widget.chatRoomId,
        lastDocument: _lastDocument,
      );

      setState(() {
        if (previousMessages.isNotEmpty) {
          // เพิ่มข้อความเก่าโดยไม่ซ้ำ
          _previousMessages.addAll(previousMessages);
          _lastDocument = previousMessages.last;
        }
        _hasMore = previousMessages.length == ChatConstant.paginationSize;
      });
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<DocumentSnapshot>>(
        stream: _chatService.getMessageStream(widget.chatRoomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading...'),
            );
          }

          final newMessages = snapshot.data ?? [];

          // รวมข้อความใหม่กับข้อความเก่าโดยไม่ซ้ำ
          final Set<String> messageIdsExisting =
              _previousMessages.map((msg) => msg.id).toSet();
          final List<DocumentSnapshot> allMessages = [
            ...newMessages.where((msg) => !messageIdsExisting.contains(msg.id)),
            ..._previousMessages,
          ];

          if (allMessages.isEmpty) {
            return const Center(
              child: Text('ไม่มีข้อความก่อนหน้า'),
            );
          }

          return ListView.builder(
            controller: _scrollController, // ใช้ ScrollController
            reverse: true, // แสดงข้อความจากล่างขึ้นบน
            itemCount: allMessages.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isLoadingMore && index == allMessages.length) {
                // แสดง Loading เมื่อกำลังโหลดข้อความเก่า
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Loading...'),
                  ),
                );
              }

              final message = allMessages[index];
              final title = Text(
                  '${message[ChatConstant.fieldUserId]}: ${message[ChatConstant.fieldText]}');
              final subTitle = Text(message[ChatConstant.fieldTimestamp] != null
                  ? DateFormat('dd-MMM-yyyy hh:mm:ss')
                      .format(
                          (message[ChatConstant.fieldTimestamp] as Timestamp)
                              .toDate()
                              .toLocal())
                      .toString()
                  : 'Sending...');

              return ListTile(
                title: title,
                subtitle: subTitle,
              );
            },
          );
        },
      ),
    );
  }
}
