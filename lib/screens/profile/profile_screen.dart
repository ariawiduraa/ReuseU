import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/screens/lapak/lapak_screen.dart';
import 'package:reuseu/screens/setting_screen.dart';
import 'package:reuseu/service/datas_service.dart';
import 'package:reuseu/dto/datas.dart';
import 'package:reuseu/screens/lapak/edit_product_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ProductDto> _myProducts = [];
  List<WishlistDto> _wishlist = [];
  bool _isLoading = true;

  // Stats
  int get _dijualCount => _myProducts.where((p) => p.status == 'available').length;
  int get _terjualCount => _myProducts.where((p) => p.status == 'sold').length;
  int get _wishlistCount => _wishlist.length;

  // User info dari Supabase Auth
  User? get _user => Supabase.instance.client.auth.currentUser;
  String get _displayName =>
      _user?.userMetadata?['full_name'] as String? ??
      _user?.email?.split('@').first ??
      'Pengguna';
  // 'username' di Supabase menyimpan NIM mahasiswa (lihat register_screen.dart)
  String get _nim =>
      _user?.userMetadata?['username'] as String? ?? '-';
  String get _location =>
      _user?.userMetadata?['location'] as String? ?? 'Lokasi tidak diset';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ProductService.fetchMyProducts(),
        WishlistService.fetchWishlists(),
      ]);
      if (mounted) {
        setState(() {
          _myProducts = results[0] as List<ProductDto>;
          _wishlist = results[1] as List<WishlistDto>;
        });
      }
    } catch (e, stack) {
      debugPrint('Error loading Profile data: $e\n$stack');
      // Tetap tampilkan kosong kalau gagal
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Hapus produk
  // ============================================================
  Future<void> _deleteProduct(ProductDto product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Barang?'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ProductService.deleteProduct(product.id);
      setState(() => _myProducts.remove(product));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Barang berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  // ============================================================
  // Tandai sebagai terjual / tersedia (toggle status)
  // ============================================================
  Future<void> _toggleStatus(ProductDto product) async {
    final newStatus = product.status == 'available' ? 'sold' : 'available';
    try {
      await ProductService.updateProductStatus(product.id, newStatus);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e')),
        );
      }
    }
  }

  void _editProduct(ProductDto product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(product: product),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          color: const Color(0xFF6D4C41),
          onRefresh: _loadData,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildStats(),
              const SizedBox(height: 16),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMyProductsTab(context),
                    _buildWishlistTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Profil Saya',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingScreen()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF6D4C41),
            child: Text(
              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'NIM: $_nim',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildStatBox(_dijualCount.toString(), 'Dijual')),
          const SizedBox(width: 8),
          Expanded(child: _buildStatBox(_terjualCount.toString(), 'Terjual')),
          const SizedBox(width: 8),
          Expanded(child: _buildStatBox(_wishlistCount.toString(), 'Wishlist')),
        ],
      ),
    );
  }

  Widget _buildStatBox(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _isLoading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6D4C41)),
                )
              : Text(
                  count,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TabBar(
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF6D4C41),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: [
          Tab(text: 'Barang Dijual (${_isLoading ? "..." : _myProducts.length.toString()})'),
          Tab(text: 'Wishlist (${_isLoading ? "..." : _wishlistCount.toString()})'),
        ],
      ),
    );
  }

  // ============================================================
  // Tab 1: Barang Dijual (dengan edit & delete)
  // ============================================================
  Widget _buildMyProductsTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)));
    }
    if (_myProducts.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada barang yang dijual',
        buttonLabel: 'Jual Barang Pertama',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LapakScreen()),
        ).then((_) => _loadData()),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: _myProducts.length,
      itemBuilder: (context, index) {
        final product = _myProducts[index];
        final imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : null;
        return _buildProductCard(product, imageUrl);
      },
    );
  }

  Widget _buildProductCard(ProductDto product, String? imageUrl) {
    final isAvailable = product.status == 'available';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto dengan badge status
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image, color: Colors.grey, size: 40),
                            ),
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.image, color: Colors.grey, size: 40),
                          ),
                  ),
                ),
                // Badge status
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isAvailable ? 'Tersedia' : 'Terjual',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${_formatPrice(product.price)}',
                  style: const TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tombol aksi
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _toggleStatus(product),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Terjual' : 'Jual Lagi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Tombol Edit
                InkWell(
                  onTap: () => _editProduct(product),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D4C41).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF6D4C41)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _deleteProduct(product),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Tab 2: Wishlist dari Supabase
  // ============================================================
  Widget _buildWishlistTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)));
    }
    if (_wishlist.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.favorite_border,
        message: 'Wishlist kamu masih kosong',
        buttonLabel: 'Jelajahi Barang',
        onTap: () {},
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _wishlist.length,
      itemBuilder: (context, index) {
        final item = _wishlist[index];
        final product = item.product;
        if (product == null) return const SizedBox.shrink();
        final imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : null;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ))
                            : Container(
                                color: Colors.grey[100],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    ),
                    // Tombol hapus dari wishlist
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () async {
                          await WishlistService.removeFromWishlist(product.id);
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatPrice(product.price)}',
                      style: const TextStyle(
                        color: Color(0xFF6D4C41),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // Empty state reusable
  // ============================================================
  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F2F0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
            label: Text(buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
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
