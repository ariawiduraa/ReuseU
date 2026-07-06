import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reuseu/navigation/main_navigation.dart';
import 'package:reuseu/service/datas_service.dart';


class LapakScreen extends StatefulWidget {
  const LapakScreen({super.key});

  @override
  State<LapakScreen> createState() => _LapakScreenState();
}

class _LapakScreenState extends State<LapakScreen> {
  String selectedCategory = 'Fashion';
  String selectedCondition = 'Seperti Baru';
  bool _isPosting = false;

  // Controller untuk form fields
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();

  // List foto yang dipilih (maks 5)
  // _imageBytes dipakai untuk preview (Image.memory — support web & mobile)
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    'Fashion',
    'Alat Tulis',
    'Elektronik',
    'Furnitur',
    'Dapur',
    'Lainnya',
  ];
  final List<String> conditions = [
    'Baru',
    'Seperti Baru',
    'Baik',
    'Layak Pakai',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  // ============================================================
  // Buka pilihan: Kamera atau Galeri
  // ============================================================
  void _showImageSourceDialog() {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 foto')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F2F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF6D4C41)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Ambil gambar dari kamera / galeri
  // ============================================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        // Baca bytes sekarang — Image.memory() bekerja di web & mobile
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImages.add(image);
          _imageBytes.add(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka ${source == ImageSource.camera ? "kamera" : "galeri"}: $e')),
        );
      }
    }
  }

  // ============================================================
  // Hapus foto yang sudah dipilih
  // ============================================================
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.removeAt(index);
    });
  }

  // ============================================================
  // Submit / Posting Barang → navigasi ke Profile tab
  // ============================================================
  Future<void> _submitPost() async {
    // Validasi sederhana
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama barang wajib diisi')),
      );
      return;
    }
    if (_hargaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga wajib diisi')),
      );
      return;
    }
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 foto harus diupload')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // 1. Upload semua foto ke Supabase Storage & kumpulkan URL-nya
      final imageUrls = <String>[];
      for (int i = 0; i < _selectedImages.length; i++) {
        final url = await ProductService.uploadProductImageBytes(
          bytes: _imageBytes[i],
          fileName: '${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        imageUrls.add(url);
      }

      // 2. Simpan data produk ke tabel 'products' + 'product_images'
      await ProductService.addProduct(
        name: _namaController.text.trim(),
        description: _deskripsiController.text.trim(),
        price: int.tryParse(_hargaController.text.trim()) ?? 0,
        condition: selectedCondition,
        category: selectedCategory,
        location: _lokasiController.text.trim(),
        imageUrls: imageUrls,
      );

      if (!mounted) return;

      // Tampilkan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Barang berhasil diposting!'),
          backgroundColor: Color(0xFF6D4C41),
        ),
      );

      // Navigasi ke MainNavigation dan langsung ke tab Profile (index 4)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 4),
        ),
        (route) => false, // hapus semua route sebelumnya
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Foto Barang'),
              _buildPhotoSection(),
              const SizedBox(height: 20),

              _buildSectionLabel('Nama Barang'),
              _buildTextField(
                controller: _namaController,
                hintText: 'Contoh: Jaket Kulit Hitam',
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Kategori'),
              _buildDropdown(),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Harga'),
                        _buildTextField(
                          controller: _hargaController,
                          hintText: '50000',
                          prefixText: 'Rp  ',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Stok'),
                        _buildTextField(
                          controller: _stokController,
                          hintText: '1',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Kondisi'),
              _buildConditionSelector(),
              const SizedBox(height: 20),

              _buildSectionLabel('Deskripsi'),
              _buildTextField(
                controller: _deskripsiController,
                hintText: 'Jelaskan kondisi barang, alasan jual, dll.',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Lokasi (Kos/Asrama)'),
              _buildTextField(
                controller: _lokasiController,
                hintText: 'Contoh: Kos Melati, Jl. Sudirman',
              ),
              const SizedBox(height: 32),

              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widget Builders
  // ============================================================

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
      ),
      title: const Text(
        'Jual Barang',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ============================================================
  // Bagian foto: preview + tombol tambah
  // ============================================================
  Widget _buildPhotoSection() {
    return Column(
      children: [
        // Preview foto yang sudah dipilih
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Tombol hapus foto
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        if (_selectedImages.isNotEmpty) const SizedBox(height: 12),

        // Tombol upload / tambah foto
        if (_selectedImages.length < 5)
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF6D4C41),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kamera / Galeri',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedImages.length}/5 foto',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? prefixText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F2F0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F2F0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: categories.map((String category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
      },
    );
  }

  Widget _buildConditionSelector() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: conditions.length,
      itemBuilder: (context, index) {
        final condition = conditions[index];
        final isSelected = selectedCondition == condition;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCondition = condition;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6D4C41)
                  : const Color(0xFFF5F2F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              condition,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6D4C41),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isPosting ? null : _submitPost,
        child: _isPosting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Posting Barang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
