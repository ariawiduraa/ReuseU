import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';
import '../../models/product_model.dart'; // Pastikan path import ini sesuai

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildBanner(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 24),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: const [
          Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
          SizedBox(width: 4),
          Text(
            'Depok, Jawa Barat',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Cari barang yang kamu inginkan...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6D4C41),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mau Wisuda? 🎓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jual barang kos yang nggak kepake lagi',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6D4C41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Mulai Jual'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    // Tambahkan kategori Olahraga di sini
    final categories = [
      {'icon': Icons.home_filled, 'label': 'Semua', 'active': true},
      {'icon': Icons.checkroom, 'label': 'Pakaian', 'active': false},
      {'icon': Icons.menu_book, 'label': 'Buku & Alat', 'active': false},
      {'icon': Icons.laptop_mac, 'label': 'Elektronik', 'active': false},
      {'icon': Icons.chair_alt, 'label': 'Perabotan', 'active': false},
      {
        'icon': Icons.sports_tennis,
        'label': 'Olahraga',
        'active': false,
      }, // Kategori baru
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90, // Batasi tinggi area scroll
          // ListView dengan arah horizontal
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(), // Efek pantulan khas iOS/Android saat di-scroll mentok
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isActive = cat['active'] as bool;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF6D4C41)
                            : Colors.grey[100],
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
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final filters = [
      'Terbaru',
      'Termurah',
      'Terdekat',
      'Seperti Baru',
      'Harga Turun',
    ]; // Tambah dummy jika ingin melihat efek scroll

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Kunci agar bisa scroll ke samping
      physics: const BouncingScrollPhysics(), // Efek pantulan halus
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == 'Terbaru';
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? const Color(0xFF6D4C41)
                  : Colors.grey[100],
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid() {
    // Memanggil list data dummy dari Product model
    final products = Product.dummyProducts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Barang Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '(${products.length})', // Jumlah disesuaikan dinamis dengan panjang list
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length, // Iterasi sebanyak jumlah data produk
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              imagePath: product.image,
              condition: product.condition,
              category: product.category,
              title: product.name,
              price: product.price,
              location: product.location,
            );
          },
        ),
      ],
    );
  }
}
