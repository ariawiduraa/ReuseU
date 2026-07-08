import 'package:flutter/material.dart';
import 'package:reuseu/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _pushNotification = true;
  bool _emailNotification = false;

  static const Color _primaryColor = Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Akun'),
              _buildSettingsCard(
                children: [
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    onTap: () => _showEditProfileSheet(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.school_outlined,
                    title: 'Universitas & Alamat',
                    subtitle: _getUserLocation(),
                    onTap: () => _showEditLocationSheet(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'Keamanan & Password',
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Preferensi'),
              _buildSettingsCard(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifikasi Push',
                    value: _pushNotification,
                    onChanged: (value) {
                      setState(() => _pushNotification = value);
                      _showSnackBar(context, value ? 'Notifikasi push diaktifkan' : 'Notifikasi push dinonaktifkan');
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.mail_outline,
                    title: 'Notifikasi Email',
                    value: _emailNotification,
                    onChanged: (value) {
                      setState(() => _emailNotification = value);
                      _showSnackBar(context, value ? 'Notifikasi email diaktifkan' : 'Notifikasi email dinonaktifkan');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Bantuan & Informasi'),
              _buildSettingsCard(
                children: [
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    onTap: () => _showHelpDialog(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.description_outlined,
                    title: 'Syarat & Ketentuan',
                    onTap: () => _showTermsSheet(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    onTap: () => _showPrivacySheet(context),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi 1.0.0',
                    showTrailing: false,
                    onTap: () => _showAboutAppDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showLogoutDialog(context),
                  child: const Text('Keluar Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: ambil lokasi dari metadata Supabase
  String _getUserLocation() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['location'] as String? ?? 'Belum diset';
  }

  // ── Edit Profil (nama & NIM)
  void _showEditProfileSheet(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final nameCtrl = TextEditingController(text: user?.userMetadata?['full_name'] as String? ?? '');
    final nimCtrl = TextEditingController(text: user?.userMetadata?['username'] as String? ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHandle(),
            const SizedBox(height: 20),
            const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(controller: nameCtrl, label: 'Nama Lengkap', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(controller: nimCtrl, label: 'NIM', icon: Icons.badge_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await Supabase.instance.client.auth.updateUser(UserAttributes(
                      data: {'full_name': nameCtrl.text.trim(), 'username': nimCtrl.text.trim()},
                    ));
                    if (context.mounted) _showSnackBar(context, '✅ Profil berhasil diperbarui');
                  } catch (e) {
                    if (context.mounted) _showSnackBar(context, 'Gagal: $e');
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Universitas & Alamat
  void _showEditLocationSheet(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final locCtrl = TextEditingController(text: user?.userMetadata?['location'] as String? ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHandle(),
            const SizedBox(height: 20),
            const Text('Universitas & Alamat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(controller: locCtrl, label: 'Universitas / Lokasi', icon: Icons.school_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await Supabase.instance.client.auth.updateUser(UserAttributes(
                      data: {'location': locCtrl.text.trim()},
                    ));
                    if (context.mounted) {
                      _showSnackBar(context, '✅ Lokasi berhasil diperbarui');
                      setState(() {}); // refresh subtitle
                    }
                  } catch (e) {
                    if (context.mounted) _showSnackBar(context, 'Gagal: $e');
                  }
                },
                child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ganti Password
  void _showChangePasswordSheet(BuildContext context) {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        bool obscureNew = true;
        bool obscureConfirm = true;
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHandle(),
                const SizedBox(height: 20),
                const Text('Ganti Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setSheet(() => obscureNew = !obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setSheet(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (newPassCtrl.text.length < 6) {
                        _showSnackBar(ctx, 'Password minimal 6 karakter');
                        return;
                      }
                      if (newPassCtrl.text != confirmCtrl.text) {
                        _showSnackBar(ctx, 'Password tidak cocok');
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await Supabase.instance.client.auth.updateUser(UserAttributes(password: newPassCtrl.text));
                        if (context.mounted) _showSnackBar(context, '✅ Password berhasil diperbarui');
                      } catch (e) {
                        if (context.mounted) _showSnackBar(context, 'Gagal: $e');
                      }
                    },
                    child: const Text('Simpan Password', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Pusat Bantuan
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.help_outline, color: _primaryColor),
          const SizedBox(width: 8),
          const Text('Pusat Bantuan'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(title: '📦 Cara menjual barang', desc: 'Tekan tombol "+" di navigasi bawah, isi detail produk, lalu upload foto.'),
            SizedBox(height: 12),
            _HelpItem(title: '❤️ Cara menambah wishlist', desc: 'Tekan ikon hati pada produk yang kamu inginkan.'),
            SizedBox(height: 12),
            _HelpItem(title: '💬 Cara chat penjual', desc: 'Buka detail produk, lalu tekan tombol "Chat Penjual".'),
            SizedBox(height: 12),
            _HelpItem(title: '📧 Hubungi kami', desc: 'support@reuseu.id'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Syarat & Ketentuan
  void _showTermsSheet(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Syarat & Ketentuan',
      icon: Icons.description_outlined,
      content:
        '1. ReuseU adalah platform jual-beli barang bekas antar mahasiswa.\n\n'
        '2. Pengguna wajib memberikan informasi yang jujur dan akurat tentang kondisi barang.\n\n'
        '3. Transaksi dilakukan langsung antara pembeli dan penjual. ReuseU tidak bertanggung jawab atas sengketa transaksi.\n\n'
        '4. Barang yang dijual tidak boleh melanggar hukum atau norma yang berlaku.\n\n'
        '5. ReuseU berhak menghapus akun yang melanggar ketentuan tanpa pemberitahuan sebelumnya.\n\n'
        '6. Dengan menggunakan aplikasi ini, kamu menyetujui seluruh syarat dan ketentuan yang berlaku.',
    );
  }

  // ── Kebijakan Privasi
  void _showPrivacySheet(BuildContext context) {
    _showInfoSheet(
      context,
      title: 'Kebijakan Privasi',
      icon: Icons.privacy_tip_outlined,
      content:
        '🔒 Data yang Kami Kumpulkan\n'
        'Kami mengumpulkan nama, email, dan informasi profil yang kamu berikan saat mendaftar.\n\n'
        '📊 Penggunaan Data\n'
        'Data digunakan untuk mengelola akun, menampilkan profil, dan meningkatkan pengalaman pengguna.\n\n'
        '🚫 Tidak Dijual ke Pihak Ketiga\n'
        'Kami tidak menjual atau membagikan data pribadi kamu kepada pihak ketiga.\n\n'
        '🗑️ Penghapusan Data\n'
        'Kamu dapat meminta penghapusan data dengan menghubungi kami di support@reuseu.id.',
    );
  }

  // ── Tentang Aplikasi
  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.recycling, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('ReuseU', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Versi 1.0.0', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            Text(
              'Platform jual-beli barang bekas antar mahasiswa. Hemat, ramah lingkungan, dan mudah digunakan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text('© 2025 ReuseU. All rights reserved.', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet konten teks panjang (Syarat & Privasi)
  void _showInfoSheet(BuildContext context, {required String title, required IconData icon, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSheetHandle(),
              const SizedBox(height: 20),
              Row(children: [
                Icon(icon, color: _primaryColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  child: Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Handle bar abu-abu di atas bottom sheet
  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  // ── TextField standar
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }

  // ── AppBar
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
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
      ),
      title: const Text('Pengaturan', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // ── Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  // ── Card pembungkus menu
  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  // ── List tile menu biasa
  Widget _buildListTile({required IconData icon, required String title, String? subtitle, bool showTrailing = true, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
      trailing: showTrailing ? const Icon(Icons.chevron_right, color: Colors.grey, size: 20) : null,
      onTap: onTap,
    );
  }

  // ── Switch tile
  Widget _buildSwitchTile({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: _primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Switch(value: value, activeThumbColor: _primaryColor, onChanged: onChanged),
    );
  }

  // ── Divider tipis
  Widget _buildDivider() => const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5));
}

// Widget kecil untuk item FAQ di Pusat Bantuan
class _HelpItem extends StatelessWidget {
  final String title;
  final String desc;
  const _HelpItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
