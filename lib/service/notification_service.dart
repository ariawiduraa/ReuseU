import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/service/datas_service.dart';
import 'package:reuseu/dto/datas.dart';

enum NotificationCategory { transaksi, pesan, info }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationCategory category;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Menyimpan ID notifikasi yang ditandai dibaca secara lokal dalam satu sesi
  final Set<String> _readIdsLocal = {};

  /// Mengambil data transaksi dan pesan dari database Supabase
  /// lalu mengonversinya menjadi notifikasi
  Future<void> fetchNotificationsFromDatabase() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      _notifications.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<NotificationItem> tempNotifications = [];

      // 1. Fetch Transaksi
      try {
        final transactions = await TransactionService.fetchTransactions();
        for (var tx in transactions) {
          final isBuyer = tx.buyerId == currentUser.id;
          final roleLabel = isBuyer ? 'Pembelian' : 'Penjualan';
          final productTitle = tx.product?.name ?? 'Produk';

          String message = '';
          if (tx.status == 'pending') {
            message =
                'Transaksi untuk "$productTitle" menunggu konfirmasi pembayaran.';
          } else if (tx.status == 'completed' || tx.status == 'success') {
            message =
                'Transaksi untuk "$productTitle" telah selesai. Terima kasih!';
          } else {
            message =
                'Status transaksi "$productTitle" saat ini: ${tx.status}.';
          }

          tempNotifications.add(
            NotificationItem(
              id: 'tx_${tx.id}',
              title: '$roleLabel: ${tx.status.toUpperCase()} 🧾',
              message: message,
              time: tx.createdAt,
              category: NotificationCategory.transaksi,
              isRead: _readIdsLocal.contains('tx_${tx.id}'),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error fetching transactions for notifications: $e');
      }

      // 2. Fetch Pesan (Chat)
      try {
        final chats = await ChatService.fetchChats();

        // Ambil pesan terakhir untuk setiap chat secara paralel
        final List<Future<List<MessageDto>>> messageFutures = chats.map((chat) {
          return ChatService.fetchMessages(chat.id);
        }).toList();

        final List<List<MessageDto>> messagesList = await Future.wait(
          messageFutures,
        );

        for (int i = 0; i < chats.length; i++) {
          final chat = chats[i];
          final messages = messagesList[i];

          if (messages.isNotEmpty) {
            // Urutkan pesan berdasarkan tanggal untuk mendapatkan yang terbaru
            messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final lastMessage = messages.last;

            // Hanya tampilkan notifikasi jika pengirimnya bukan user saat ini
            if (lastMessage.senderId != currentUser.id) {
              final otherUser = chat.buyerId == currentUser.id
                  ? chat.seller
                  : chat.buyer;
              final otherName =
                  otherUser?.fullName ?? otherUser?.username ?? 'Pengguna Lain';

              tempNotifications.add(
                NotificationItem(
                  id: 'msg_${lastMessage.id}',
                  title: 'Pesan baru dari $otherName 💬',
                  message: lastMessage.content,
                  time: lastMessage.createdAt,
                  category: NotificationCategory.pesan,
                  isRead:
                      lastMessage.isRead ||
                      _readIdsLocal.contains('msg_${lastMessage.id}'),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching chats for notifications: $e');
      }

      // 3. Fallback / Info Notifikasi Sistem
      // Selalu tambahkan info sambutan jika user terdaftar
      tempNotifications.add(
        NotificationItem(
          id: 'info_welcome',
          title: 'Selamat Datang di ReuseU! 🎉',
          message:
              'Temukan berbagai barang bekas kos berkualitas atau mulai jual barang tidak terpakai milikmu.',
          time:
              DateTime.tryParse(currentUser.createdAt) ??
              DateTime.now().subtract(const Duration(days: 1)),
          category: NotificationCategory.info,
          isRead: _readIdsLocal.contains('info_welcome'),
        ),
      );

      // Urutkan berdasarkan waktu paling baru
      tempNotifications.sort((a, b) => b.time.compareTo(a.time));

      _notifications.clear();
      _notifications.addAll(tempNotifications);
    } catch (e) {
      debugPrint('Error populating notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tandai satu notifikasi sebagai dibaca
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _readIdsLocal.add(id);
      notifyListeners();
    }
  }

  /// Tandai semua notifikasi sebagai dibaca
  void markAllAsRead() {
    bool updated = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        _readIdsLocal.add(n.id);
        updated = true;
      }
    }
    if (updated) {
      notifyListeners();
    }
  }

  /// Hapus satu notifikasi secara lokal
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Hapus semua notifikasi secara lokal
  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  /// Tambahkan notifikasi baru ke daftar lokal
  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    _notifications.sort((a, b) => b.time.compareTo(a.time));
    notifyListeners();
  }
}
