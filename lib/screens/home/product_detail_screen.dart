import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dto/datas.dart';
import '../../service/datas_service.dart';
import '../chat/chat_detailed_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductDto product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isWishlisted = false;
  bool _isLoadingWishlist = true;
  bool _isActionLoading = false;

  String get _currentUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final status = await WishlistService.isWishlisted(widget.product.id);
      if (mounted) {
        setState(() {
          _isWishlisted = status;
          _isLoadingWishlist = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingWishlist = false);
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    try {
      final newStatus = await WishlistService.toggleWishlist(widget.product.id);
      if (mounted) {
        setState(() {
          _isWishlisted = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Ditambahkan ke Wishlist'
                  : 'Dihapus dari Wishlist',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah wishlist: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _startChat() async {
    if (widget.product.sellerId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ini adalah barang Anda sendiri.')),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final chat = await ChatService.getOrCreateChat(
        sellerId: widget.product.sellerId,
        productId: widget.product.id,
      );

      // fetchChats returns chat details containing buyer/seller objects,
      // but getOrCreateChat returns the record without joining buyer/seller profiles sometimes.
      // So let's load/refresh chat details if profiles are null.
      ChatDto finalChat = chat;
      if (chat.seller == null || chat.buyer == null) {
        final chats = await ChatService.fetchChats();
        finalChat = chats.firstWhere((c) => c.id == chat.id, orElse: () => chat);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chat: finalChat),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.images.isNotEmpty
        ? widget.product.images.first.imageUrl
        : null;

    final sellerName = widget.product.seller?.fullName ??
        widget.product.seller?.username ??
        'Penjual';

    final sellerLocation = widget.product.location ?? 'Lokasi tidak diset';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Barang",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _isLoadingWishlist ? null : _toggleWishlist,
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoadingWishlist ? null : _toggleWishlist,
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: _isWishlisted ? Colors.red : Colors.grey[700],
                ),
                label: Text(
                  _isWishlisted ? "Tersimpan" : "Wishlist",
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5E57),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                onPressed: _isActionLoading ? null : _startChat,
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  "Chat Penjual",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO BESAR
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 370,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 64, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 64, color: Colors.grey),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // KATEGORI & KONDISI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "${widget.product.category}  •  ${widget.product.condition}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            // NAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product.name,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // HARGA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Rp ${_formatPrice(widget.product.price)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B5E57),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // SELLER CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEEB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF7B5E57),
                    child: Text(
                      sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'P',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "📍 $sellerLocation",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: _isActionLoading ? null : _startChat,
                      child: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // DESKRIPSI
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Deskripsi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product.description ?? 'Tidak ada deskripsi.',
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
