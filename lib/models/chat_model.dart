class ChatUser {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  const ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });

  static List<ChatUser> dummyChats() {
    return const [
      ChatUser(
        id: '1',
        name: 'Akira',
        lastMessage: 'Masih tersedia kak?',
        time: '09:12',
        unread: 2,
      ),
      ChatUser(
        id: '2',
        name: 'Adhel',
        lastMessage: 'Bisa nego seratus?',
        time: 'Kemarin',
        unread: 0,
      ),
      ChatUser(
        id: '3',
        name: 'Nadia',
        lastMessage: 'Barang jadi saya ambil ya',
        time: '10:45',
        unread: 1,
      ),
      ChatUser(
        id: '4',
        name: 'Kevin',
        lastMessage: 'Lokasinya dimana?',
        time: 'Senin',
        unread: 0,
      ),
      ChatUser(
        id: '5',
        name: 'Fajar',
        lastMessage: 'Siap gan makasih 🙏',
        time: 'Minggu',
        unread: 0,
      ),
    ];
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });

  static List<ChatMessage> dummyMessages() {
    return const [
      ChatMessage(
        text: 'Halo, hoodie navy masih ada?',
        isMe: false,
        time: '09:10',
      ),
      ChatMessage(
        text: 'Masih kak, mau langsung ambil?',
        isMe: true,
        time: '09:11',
      ),
      ChatMessage(text: 'Iya, bisa COD dimana?', isMe: false, time: '09:12'),
      ChatMessage(
        text: 'Bisa di kampus ITS atau area Keputih kak',
        isMe: true,
        time: '09:13',
      ),
      ChatMessage(
        text: 'Oke besok siang ya kak 👍',
        isMe: false,
        time: '09:14',
      ),
      ChatMessage(text: 'Siap kak, ditunggu!', isMe: true, time: '09:15'),
    ];
  }
}
