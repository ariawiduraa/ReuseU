import 'package:flutter/material.dart';
import '../../dto/datas.dart';
import '../../service/datas_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductDto product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late String selectedCategory;
  late String selectedCondition;
  bool _isSaving = false;

  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _lokasiController;

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
  void initState() {
    super.initState();
    selectedCategory = widget.product.category;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Lainnya';
    }
    selectedCondition = widget.product.condition;
    if (!conditions.contains(selectedCondition)) {
      selectedCondition = 'Seperti Baru';
    }

    _namaController = TextEditingController(text: widget.product.name);
    _hargaController = TextEditingController(text: widget.product.price.toString());
    _deskripsiController = TextEditingController(text: widget.product.description ?? '');
    _lokasiController = TextEditingController(text: widget.product.location ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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

    setState(() => _isSaving = true);

    try {
      await ProductService.updateProduct(
        productId: widget.product.id,
        name: _namaController.text.trim(),
        description: _deskripsiController.text.trim(),
        price: int.tryParse(_hargaController.text.trim()) ?? 0,
        condition: selectedCondition,
        category: selectedCategory,
        location: _lokasiController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Perubahan berhasil disimpan!'),
          backgroundColor: Color(0xFF6D4C41),
        ),
      );

      Navigator.pop(context, true); // kembalikan true agar profile screen reload data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
              _buildSectionLabel('Nama Barang'),
              _buildTextField(
                controller: _namaController,
                hintText: 'Contoh: Jaket Kulit Hitam',
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Kategori'),
              _buildDropdown(),
              const SizedBox(height: 20),

              _buildSectionLabel('Harga'),
              _buildTextField(
                controller: _hargaController,
                hintText: '50000',
                prefixText: 'Rp  ',
                keyboardType: TextInputType.number,
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
        'Edit Barang',
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
        if (newValue != null) {
          setState(() {
            selectedCategory = newValue;
          });
        }
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
        onPressed: _isSaving ? null : _saveChanges,
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Simpan Perubahan',
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
