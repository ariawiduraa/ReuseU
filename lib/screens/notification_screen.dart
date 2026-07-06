import 'package:flutter/material.dart';
import '../service/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _notificationService.addListener(_onNotificationChange);
    // Muat data notifikasi dari database saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.fetchNotificationsFromDatabase();
    });
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationChange);
    super.dispose();
  }

  void _onNotificationChange() {
    if (mounted) {
      setState(() {});
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transaksi:
        return Icons.shopping_bag_outlined;
      case NotificationCategory.pesan:
        return Icons.chat_bubble_outline;
      case NotificationCategory.info:
        return Icons.info_outline;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transaksi:
        return const Color(0xFFE8F5E9); // Hijau lembut
      case NotificationCategory.pesan:
        return const Color(0xFFFFF3E0); // Oranye/kuning lembut
      case NotificationCategory.info:
        return const Color(0xFFE3F2FD); // Biru lembut
    }
  }

  Color _getCategoryIconColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transaksi:
        return Colors.green[700]!;
      case NotificationCategory.pesan:
        return Colors.orange[700]!;
      case NotificationCategory.info:
        return Colors.blue[700]!;
    }
  }

  String _getCategoryLabel(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.transaksi:
        return 'Transaksi';
      case NotificationCategory.pesan:
        return 'Pesan';
      case NotificationCategory.info:
        return 'Info';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotifications = _notificationService.notifications;

    // Filter berdasarkan kategori
    final filteredNotifications = allNotifications.where((n) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Transaksi' && n.category == NotificationCategory.transaksi) return true;
      if (_selectedFilter == 'Pesan' && n.category == NotificationCategory.pesan) return true;
      if (_selectedFilter == 'Info' && n.category == NotificationCategory.info) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF6D4C41)),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF6D4C41),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (allNotifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                _notificationService.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi ditandai telah dibaca'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Baca Semua',
                style: TextStyle(
                  color: Color(0xFF6D4C41),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6D4C41)),
            onSelected: (value) {
              if (value == 'clear') {
                _notificationService.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi berhasil dihapus'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Semua', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6D4C41),
        onRefresh: () => _notificationService.fetchNotificationsFromDatabase(),
        child: Column(
          children: [
            // Filter Chips Row
            _buildFilterChips(),
            const Divider(height: 1),
            // Notification List / Loader
            Expanded(
              child: _notificationService.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6D4C41),
                      ),
                    )
                  : filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredNotifications.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, index) {
                            final item = filteredNotifications[index];
                            return _buildNotificationItem(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Transaksi', 'Pesan', 'Info'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6D4C41),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF6D4C41),
              backgroundColor: Colors.grey[100],
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red[100],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (direction) {
        _notificationService.deleteNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            action: SnackBarAction(
              label: 'Batal',
              textColor: const Color(0xFFDBCAB9),
              onPressed: () {
                _notificationService.addNotification(item);
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          _notificationService.markAsRead(item.id);
        },
        child: Container(
          color: item.isRead ? Colors.transparent : const Color(0xFFFAF6F0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: _getCategoryIconColor(item.category),
                      size: 22,
                    ),
                  ),
                  if (!item.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6D4C41),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCategoryLabel(item.category),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryIconColor(item.category),
                          ),
                        ),
                        Text(
                          _formatTime(item.time),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada notifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Notifikasi mengenai transaksi, pesan chat, dan info penting lainnya akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
