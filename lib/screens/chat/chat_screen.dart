import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../chat/chat_detailed_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = ChatUser.dummyChats();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pesan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey[200], height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6D4C41).withOpacity(0.1),
              child: Text(
                chat.name[0], // Mengambil huruf pertama dari nama
                style: const TextStyle(
                  color: Color(0xFF6D4C41),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unread > 0 ? Colors.black87 : Colors.grey[600],
                  fontWeight: chat.unread > 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: chat.unread > 0
                        ? const Color(0xFF6D4C41)
                        : Colors.grey[500],
                  ),
                ),
                if (chat.unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6D4C41),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              // Navigasi ke Chat Detail saat diklik
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(user: chat),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
