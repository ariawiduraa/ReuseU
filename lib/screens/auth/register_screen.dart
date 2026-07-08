import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isAgreed = false;
  bool _isLoading = false;

  // Controllers
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universitasController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _universitasController.dispose();
    _lokasiController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // Register ke Supabase
  // ============================================================
  Future<void> _register() async {
    // Validasi field wajib
    if (_namaController.text.trim().isEmpty) {
      _showSnack('Nama lengkap wajib diisi');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnack('Email wajib diisi');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnack('Password minimal 6 karakter');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Password dan konfirmasi password tidak cocok');
      return;
    }
    if (!_isAgreed) {
      _showSnack('Kamu harus menyetujui syarat & ketentuan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Daftar ke Supabase Auth
      // Data tambahan (full_name, username, dll) otomatis disimpan ke tabel
      // 'profiles' via trigger on_auth_user_created yang sudah dibuat di SQL
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _namaController.text.trim(),
          'username': _nimController.text.trim().isNotEmpty
              ? _nimController.text.trim()
              : null,
          'phone': _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          'location': _lokasiController.text.trim().isNotEmpty
              ? '${_universitasController.text.trim()} - ${_lokasiController.text.trim()}'
              : _universitasController.text.trim().isNotEmpty
                  ? _universitasController.text.trim()
                  : null,
        },
      );

      final user = response.user;
      if (user != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': user.id,
            'full_name': _namaController.text.trim(),
            'username': _nimController.text.trim().isNotEmpty
                ? _nimController.text.trim()
                : null,
            'phone': _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            'location': _lokasiController.text.trim().isNotEmpty
                ? '${_universitasController.text.trim()} - ${_lokasiController.text.trim()}'
                : _universitasController.text.trim().isNotEmpty
                    ? _universitasController.text.trim()
                    : null,
          });
        } catch (e) {
          debugPrint('Profile upsert fallback warning: $e');
        }
      }

      if (!mounted) return;

      // Tampilkan dialog sukses / info verifikasi email
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF6D4C41)),
              SizedBox(width: 10),
              Flexible(child: Text('Pendaftaran Berhasil!', overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: const Text(
            'Akun kamu berhasil dibuat.\n\n'
            'Silakan cek email untuk verifikasi (jika diperlukan), '
            'kemudian login dengan akun yang sudah didaftarkan.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // tutup dialog
                // Kembali ke login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('OK, Masuk Sekarang', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      _showSnack(_mapAuthError(e.message));
    } catch (e) {
      _showSnack('Registrasi gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Terjemahkan pesan error Supabase ke bahasa Indonesia
  String _mapAuthError(String message) {
    if (message.contains('already registered') || message.contains('already been registered')) {
      return 'Email sudah terdaftar. Gunakan email lain atau langsung login.';
    }
    if (message.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    if (message.contains('Password should be at least')) {
      return 'Password terlalu pendek, minimal 6 karakter.';
    }
    return message;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF795548),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/logo/splash.png',
                      width: 48,
                      height: 48,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daftar Akun',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai jual-beli barang preloved',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Nama Lengkap *'),
                        _buildTextField(
                          controller: _namaController,
                          hintText: 'Ahmad Rizki',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('NIM'),
                        _buildTextField(
                          controller: _nimController,
                          hintText: 'Contoh: 21151010XX',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('Email *'),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'email@mahasiswa.ac.id',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('No. WhatsApp'),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '081234567890',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('Universitas'),
                        _buildTextField(
                          controller: _universitasController,
                          hintText: 'Contoh: Universitas Pendidikan Ganesha',
                          prefixIcon: Icons.school_outlined,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('Lokasi (Kota)'),
                        _buildTextField(
                          controller: _lokasiController,
                          hintText: 'Contoh: Singaraja, Bali',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('Password * (min. 6 karakter)'),
                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Minimal 6 karakter',
                          isObscure: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInputLabel('Konfirmasi Password *'),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Ulangi password',
                          isObscure: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Checkbox Syarat & Ketentuan
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _isAgreed,
                                activeColor: const Color(0xFF6D4C41),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _isAgreed = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saya setuju dengan Syarat & Ketentuan dan Kebijakan Privasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6D4C41),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (_isAgreed && !_isLoading) ? _register : null,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Link ke login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Color(0xFF6D4C41),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Widget helpers
  // ============================================================
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: Colors.grey[500], size: 20),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500], size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: onToggle,
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
}
