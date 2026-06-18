import 'package:flutter/material.dart';
import 'package:reuseu/screens/lapak/lapak_screen.dart';
import '../../models/transaction_model.dart';
import 'package:reuseu/screens/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan DefaultTabController untuk mengatur state tab bar
    return DefaultTabController(
      length: 3, // Jumlah tab sekarang menjadi 3
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEmptyState(context), // Tab 1: Barang Dijual
                  _buildTransactionList(
                    TransactionType.penjualan,
                  ), // Tab 2: Penjualan
                  _buildTransactionList(
                    TransactionType.pembelian,
                  ), // Tab 3: Pembelian
                ],
              ),
            ),
          ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
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
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFF6D4C41),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.blue,
            ), // Placeholder avatar
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '@Stechu_Store',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Singaraja, Bali',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
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
          Expanded(child: _buildStatBox('0', 'Dijual')),
          const SizedBox(width: 8),
          Expanded(child: _buildStatBox('12', 'Terjual')),
          const SizedBox(width: 8),
          Expanded(child: _buildStatBox('5', 'Dibeli')), // Tambahan box Dibeli
          const SizedBox(width: 8),
          Expanded(child: _buildStatBox('0', 'Wishlist')),
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
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: const TabBar(
        isScrollable: true, // Agar tab bisa di-scroll jika kepanjangan
        tabAlignment: TabAlignment.start,
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF6D4C41),
        indicatorWeight: 3,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: 'Barang Dijual (0)'),
          Tab(text: 'Riwayat Penjualan'),
          Tab(text: 'Riwayat Pembelian'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F2F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Belum ada barang yang dijual',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          // 4. LOGIKA NAVIGASI SAAT TOMBOL DIKLIK
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LapakScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Jual Barang Pertama'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D4C41),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(TransactionType type) {
    // Filter transaksi berdasarkan jenis tab yang sedang dibuka
    final transactions = TransactionModel.dummyTransactions()
        .where((trx) => trx.type == type)
        .toList();

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat transaksi.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final trx = transactions[index];
        // Mewarnai status berdasarkan teksnya
        Color statusColor = Colors.green;
        if (trx.status == 'Dibatalkan') statusColor = Colors.red;
        if (trx.status == 'Dikirim') statusColor = Colors.orange;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trx.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trx.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      trx.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trx.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trx.price,
                          style: const TextStyle(
                            color: Color(0xFF6D4C41),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == TransactionType.penjualan
                              ? 'Pembeli: ${trx.counterpartyName}'
                              : 'Penjual: ${trx.counterpartyName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
