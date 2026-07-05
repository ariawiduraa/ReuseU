import 'package:flutter/material.dart';
import 'package:reuseu/service/datas_service.dart';
import 'package:reuseu/dto/datas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/screens/chat/chat_detailed_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatDto> _chats = [];
  bool _isLoading = true;

  final _myId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final chats = await ChatService.fetchChats();
      if (mounted) setState(() => _chats = chats);
    } catch (_) {
      if (mounted) setState(() => _chats = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada pesan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai chat dengan penjual dari halaman produk',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF6D4C41),
                  onRefresh: _loadChats,
                  child: ListView.separated(
                    itemCount: _chats.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey[100], height: 1),
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      // Tentukan lawan bicara (bukan diri sendiri)
                      final other = chat.buyerId == _myId ? chat.seller : chat.buyer;
                      final otherName = other?.fullName ?? other?.username ?? 'Pengguna';
                      final initials = otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF6D4C41).withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF6D4C41),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          otherName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          chat.product?.name ?? 'Produk',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _formatTime(chat.lastMessageAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(chat: chat),
                            ),
                          ).then((_) => _loadChats());
                        },
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }
}
