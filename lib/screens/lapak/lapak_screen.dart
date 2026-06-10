import 'package:flutter/material.dart';

class LapakScreen extends StatefulWidget {
  const LapakScreen({super.key});

  @override
  State<LapakScreen> createState() => _LapakScreenState();
}

class _LapakScreenState extends State<LapakScreen> {
  String selectedCategory = 'Pakaian';
  String selectedCondition = 'Seperti Baru';

  final List<String> categories = [
    'Pakaian',
    'Buku & Alat Tulis',
    'Elektronik',
    'Perabotan',
  ];
  final List<String> conditions = [
    'Baru',
    'Seperti Baru',
    'Baik',
    'Layak Pakai',
  ];

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
              _buildPhotoUploadBox(),
              const SizedBox(height: 20),

              _buildSectionLabel('Nama Barang'),
              _buildTextField(hintText: 'Contoh: Jaket Kulit Hitam'),
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
                hintText: 'Jelaskan kondisi barang, alasan jual, dll.',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Lokasi (Kos/Asrama)'),
              _buildTextField(hintText: 'Contoh: Kos Melati, Jl. Sudirman'),
              const SizedBox(height: 32),

              _buildSubmitButton(),
              const SizedBox(height: 20), // Spacing ekstra di bawah
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
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

  Widget _buildPhotoUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
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
              Icons.upload_outlined,
              color: Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Klik untuk upload foto',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '0/5 foto',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    String? prefixText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
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
        childAspectRatio: 3.5, // Mengatur rasio lebar ke tinggi tombol
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        onPressed: () {
          // Logika untuk submit / posting barang
        },
        child: const Text(
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
