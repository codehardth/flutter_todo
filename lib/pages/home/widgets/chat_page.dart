import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';
import 'chats/chat_room_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String currentUsername = 'unknow-user';

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken == null || authToken.isEmpty) {
      logout();
    }

    setState(() {
      currentUsername = prefs.getString('username') ?? 'unknow-user';
    });
  }

  @override
  void initState() {
    super.initState();

    getAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chatrooms').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: Text(
            'ไม่พบห้องแชท',
          ));
        }

        final chats = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: Text('${chat['name']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomWidget(
                        chatId: chat.id,
                        chatroomName: chat['name'],
                        username: currentUsername,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
