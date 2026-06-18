import 'package:flutter/material.dart';
import 'package:reuseu/models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required Product product});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.black),
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
                onPressed: () {},

                icon: const Icon(Icons.favorite_border),

                label: const Text("Wishlist"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5E57),
                ),

                onPressed: () {},

                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),

                label: const Text(
                  "Chat Penjual",
                  style: TextStyle(color: Colors.white),
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

                child: Image.asset(
                  "assets/images/hoodie.jpeg",
                  width: double.infinity,
                  height: 370,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // THUMBNAIL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),

              child: Row(
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),

                    width: 58,

                    height: 58,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),

                      child: Image.asset(
                        "assets/images/hoodie.jpeg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 18),

            // KATEGORI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                "Pakaian  •  Seperti Baru",

                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),

            const SizedBox(height: 10),

            // NAMA
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                "Hoodie H&M Navy",

                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // HARGA
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                "Rp 95.000",

                style: TextStyle(
                  fontSize: 34,
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
                  const CircleAvatar(
                    radius: 24,

                    backgroundColor: Color(0xFF7B5E57),

                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Yoga Aditya",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "✏ Universitas Airlangga",
                          style: TextStyle(color: Colors.grey),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "📍 Surabaya",
                          style: TextStyle(color: Colors.grey),
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

                    child: const Icon(Icons.chat_bubble_outline),
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

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                "Hoodie H&M warna navy size L, bahan tebal dan hangat. Kondisi 95% karena cuma dipakai 2-3 kali.",

                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
