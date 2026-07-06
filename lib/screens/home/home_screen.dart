import 'package:flutter/material.dart';
import 'package:reuseu/service/datas_service.dart';
import 'package:reuseu/dto/datas.dart';
import 'package:reuseu/screens/lapak/lapak_screen.dart';
import 'package:reuseu/screens/home/product_detail_screen.dart';
import 'package:reuseu/screens/notification_screen.dart';
import 'package:reuseu/service/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  List<ProductDto> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _notificationService = NotificationService();

  String _selectedSort = 'Terbaru';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.home_filled, 'label': 'Semua', 'value': null},
    {'icon': Icons.checkroom, 'label': 'Fashion', 'value': 'Fashion'},
    {'icon': Icons.edit_note, 'label': 'Alat Tulis', 'value': 'Alat Tulis'},
    {'icon': Icons.laptop_mac, 'label': 'Elektronik', 'value': 'Elektronik'},
    {'icon': Icons.chair_alt, 'label': 'Furnitur', 'value': 'Furnitur'},
    {'icon': Icons.soup_kitchen, 'label': 'Dapur', 'value': 'Dapur'},
    {'icon': Icons.more_horiz, 'label': 'Lainnya', 'value': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _notificationService.addListener(_onNotificationChange);
    // Muat data notifikasi dari database saat masuk Beranda
    _notificationService.fetchNotificationsFromDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notificationService.removeListener(_onNotificationChange);
    super.dispose();
  }

  void _onNotificationChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final category = _categories[_selectedCategory]['value'] as String?;
      final products = category == null
          ? await ProductService.fetchProducts()
          : await ProductService.fetchProductsByCategory(category);
      if (mounted) setState(() => _products = products);
    } catch (e, stack) {
      debugPrint('Error loading products: $e\n$stack');
      if (mounted) {
        setState(() => _products = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductDto> get _filteredProducts {
    List<ProductDto> list = List.from(_products);
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedSort == 'Terbaru') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Terlama') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_selectedSort == 'Harga Terendah') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Harga Tertinggi') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: const Color(0xFF6D4C41),
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildBanner(context),
                const SizedBox(height: 24),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildProductGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.storefront_rounded, color: Color(0xFF6D4C41), size: 22),
          SizedBox(width: 8),
          Text(
            'ReuseU',
            style: TextStyle(
              color: Color(0xFF6D4C41),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6D4C41), size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            if (_notificationService.unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${_notificationService.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Cari barang yang kamu inginkan...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mau Wisuda? 🎓',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jual barang kos yang nggak kepake lagi',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LapakScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6D4C41),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Mulai Jual', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = _selectedCategory == index;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() => _selectedCategory = index);
                    _loadProducts();
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF6D4C41) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isActive ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.black87 : Colors.grey[600],
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Daftar Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? '...' : '(${products.length})',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            PopupMenuButton<String>(
              initialValue: _selectedSort,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6D4C41), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF6D4C41)),
                    const SizedBox(width: 4),
                    Text(
                      _selectedSort,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF6D4C41)),
                  ],
                ),
              ),
              onSelected: (String value) {
                setState(() {
                  _selectedSort = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Terbaru',
                  child: Text('Terbaru'),
                ),
                const PopupMenuItem<String>(
                  value: 'Terlama',
                  child: Text('Terlama'),
                ),
                const PopupMenuItem<String>(
                  value: 'Harga Terendah',
                  child: Text('Harga Terendah'),
                ),
                const PopupMenuItem<String>(
                  value: 'Harga Tertinggi',
                  child: Text('Harga Tertinggi'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
            ),
          )
        else if (products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Tidak ada barang untuk "$_searchQuery"'
                        : 'Belum ada barang tersedia',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final imageUrl = product.images.isNotEmpty
                  ? product.images.first.imageUrl
                  : null;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                ),
                child: _buildProductCard(product, imageUrl),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductDto product, String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: Colors.grey[100],
                              child: const Icon(Icons.image, color: Colors.grey, size: 40),
                            ))
                        : Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.image, color: Colors.grey, size: 40),
                          ),
                  ),
                  // Badge kondisi
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D4C41),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.condition,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(product.price)}',
                  style: const TextStyle(
                    color: Color(0xFF6D4C41),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        product.location ?? '-',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
