import 'package:flutter/material.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'dashboard_page.dart';

enum _ModeAuth { masuk, daftarPelanggan, daftarMitra }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _ModeAuth _mode = _ModeAuth.masuk;
  bool _tampilPassword = false;

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _hpCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  void _pindahMode(_ModeAuth modeBaru) {
    setState(() => _mode = modeBaru);
  }

  void _masukKeDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  void _submit() {
    final data = DataSaungLobster.instance;

    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email/username dan password wajib diisi.')),
      );
      return;
    }

    String? error;
    if (_mode == _ModeAuth.masuk) {
      error = data.login(_emailCtrl.text, _passwordCtrl.text);
    } else {
      if (_namaCtrl.text.trim().isEmpty ||
          _hpCtrl.text.trim().isEmpty ||
          _alamatCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi nama, nomor WhatsApp, dan alamat.'),
          ),
        );
        return;
      }

      final peranTarget =
          _mode == _ModeAuth.daftarPelanggan ? 'Restoran' : 'Petani';

      error = data.daftarAkunBaru(
        nama: _namaCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        peran: peranTarget,
        noHp: _hpCtrl.text,
        alamat: _alamatCtrl.text,
      );
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: merahTua),
      );
      return;
    }

    _masukKeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final dark = isTemaGelap(context);
    final isMasuk = _mode == _ModeAuth.masuk;
    final isMitra = _mode == _ModeAuth.daftarMitra;

    final String judulForm = isMasuk
        ? 'Selamat Datang'
        : isMitra
            ? 'Daftar Mitra Panen'
            : 'Buat Akun Pelanggan';

    final String subjudulForm = isMasuk
        ? 'Masuk ke akun SaungLobster Anda'
        : isMitra
            ? 'Setor hasil budidaya lobster langsung ke SaungLobster'
            : 'Pesan lobster air tawar segar untuk kebutuhan usaha Anda';

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          merah.withValues(alpha: 0.92),
                          merahTua.withValues(alpha: 0.80),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: merah.withValues(alpha: 0.42),
                          blurRadius: 26,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.set_meal_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'SAUNG LOBSTER',
                    style: TextStyle(
                      color: warnaTeksUtama(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Freshwater Lobster Supplier • EST 2021',
                    style: TextStyle(
                      color: warnaTeksSekunder(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 26),

                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                    borderRadius: 28,
                    blur: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isMasuk) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => _pindahMode(_ModeAuth.masuk),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 14,
                                    color: warnaTeksSekunder(context),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kembali ke Masuk',
                                    style: TextStyle(
                                      color: warnaTeksSekunder(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const SizedBox(width: 38),
    Expanded(
      child: Text(
        judulForm,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: warnaTeksUtama(context),
          fontSize: 21,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    ),
    const ThemeToggleButton(size: 38),
  ],
),
                        const SizedBox(height: 6),
                        Text(
                          subjudulForm,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: warnaTeksSekunder(context),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),

                        if (!isMasuk) ...[
                          TextField(
                            controller: _namaCtrl,
                            style: TextStyle(color: warnaTeksUtama(context)),
                            decoration: glassInputDecoration(
                              context,
                              label: isMitra
                                  ? 'Nama Pembudidaya / Kolam'
                                  : 'Nama Restoran / Usaha',
                              icon: isMitra
                                  ? Icons.person_outline
                                  : Icons.storefront_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: warnaTeksUtama(context)),
                          decoration: glassInputDecoration(
                            context,
                            label: 'Email atau Username',
                            hint: 'nama@saunglobster.com',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _passwordCtrl,
                          obscureText: !_tampilPassword,
                          style: TextStyle(color: warnaTeksUtama(context)),
                          decoration: glassInputDecoration(
                            context,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _tampilPassword = !_tampilPassword,
                                );
                              },
                              icon: Icon(
                                _tampilPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: warnaTeksSekunder(context),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        if (!isMasuk) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _hpCtrl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: warnaTeksUtama(context)),
                            decoration: glassInputDecoration(
                              context,
                              label: 'Nomor WhatsApp',
                              icon: Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _alamatCtrl,
                            style: TextStyle(color: warnaTeksUtama(context)),
                            decoration: glassInputDecoration(
                              context,
                              label: isMitra
                                  ? 'Lokasi Kolam (Kota Baru Parahyangan)'
                                  : 'Alamat Pengiriman',
                              icon: Icons.location_on_outlined,
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        GlassPrimaryButton(
                          label: isMasuk
                              ? 'Masuk'
                              : isMitra
                                  ? 'Daftar sebagai Mitra'
                                  : 'Daftar Sekarang',
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 18),

                        if (isMasuk)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pelanggan baru? ',
                                style: TextStyle(
                                  color: warnaTeksSekunder(context),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _pindahMode(_ModeAuth.daftarPelanggan),
                                child: Text(
                                  'Daftar sekarang',
                                  style: TextStyle(
                                    color: dark ? Colors.white : merah,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: TextStyle(
                                  color: warnaTeksSekunder(context),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _pindahMode(_ModeAuth.masuk),
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: dark ? Colors.white : merah,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  if (isMasuk) ...[
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: () => _pindahMode(_ModeAuth.daftarMitra),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: dark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.78),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.12)
                                : merah.withValues(alpha: 0.2),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: warnaTeksSekunder(context),
                            ),
                            children: [
                              const TextSpan(text: 'Anda pembudidaya lobster? '),
                              TextSpan(
                                text: 'Daftar Mitra Panen',
                                style: TextStyle(
                                  color: dark ? const Color(0xFFFF858D) : merah,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}