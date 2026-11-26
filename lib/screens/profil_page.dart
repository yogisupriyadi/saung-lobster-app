import 'package:flutter/material.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'login_page.dart';

class ProfilPenggunaPage extends StatelessWidget {
  final bool tampilAppBar;

  const ProfilPenggunaPage({super.key, this.tampilAppBar = false});

  void _bukaEditProfil(BuildContext context) {
    final data = DataSaungLobster.instance;
    final akun = data.akunAktif;
    if (akun == null) return;

    final namaCtrl = TextEditingController(text: akun.nama);
    final userCtrl = TextEditingController(text: akun.username);
    final fotoCtrl = TextEditingController(text: akun.photoUrl ?? '');
    final hpCtrl = TextEditingController(text: akun.noHp);
    final alamatCtrl = TextEditingController(text: akun.alamat);
    final titikCtrl = TextEditingController(text: akun.titikLokasi);
    final latCtrl = TextEditingController(
      text: akun.latitude.toStringAsFixed(4),
    );
    final lngCtrl = TextEditingController(
      text: akun.longitude.toStringAsFixed(4),
    );
    final passCtrl = TextEditingController();
    int warnaDipilih = akun.avatarColorIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: warnaModalSheet(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, setModalState) {
            final teksUtama = warnaTeksUtama(innerContext);
            final teksSekunder = warnaTeksSekunder(innerContext);

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(innerContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: teksSekunder.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit Profil & Titik Lokasi',
                      style: TextStyle(
                        color: teksUtama,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Warna Avatar',
                      style: TextStyle(color: teksSekunder, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(presetWarnaAvatar.length, (i) {
                        final terpilih = warnaDipilih == i;
                        return GestureDetector(
                          onTap: () => setModalState(() => warnaDipilih = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: presetWarnaAvatar[i],
                              ),
                              border: Border.all(
                                color: terpilih ? teksUtama : Colors.white24,
                                width: terpilih ? 2.5 : 1,
                              ),
                            ),
                            child: terpilih
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 17,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: fotoCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'URL Foto Profil (Opsional)',
                        hint: 'https://.../foto.jpg',
                        icon: Icons.image_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: namaCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Nama Lengkap / Usaha',
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Username (tanpa spasi)',
                        icon: Icons.alternate_email,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hpCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'No. WhatsApp',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: alamatCtrl,
                      maxLines: 2,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Alamat Lengkap',
                        icon: Icons.home_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Preset Titik Lokasi (Kota Baru Parahyangan)',
                      style: TextStyle(color: teksSekunder, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: DataSaungLobster.presetLokasiKBP.map((loc) {
                        return ActionChip(
                          label: Text(loc.$1.split(',').first),
                          avatar: const Icon(Icons.pin_drop, size: 14),
                          onPressed: () {
                            setModalState(() {
                              titikCtrl.text = loc.$1;
                              alamatCtrl.text = '${loc.$1}, Bandung Barat';
                              latCtrl.text = loc.$2.toStringAsFixed(4);
                              lngCtrl.text = loc.$3.toStringAsFixed(4);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titikCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Nama Titik Lokasi / Patokan',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: TextStyle(color: teksUtama),
                            decoration: glassInputDecoration(
                              innerContext,
                              label: 'Latitude',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: lngCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: TextStyle(color: teksUtama),
                            decoration: glassInputDecoration(
                              innerContext,
                              label: 'Longitude',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Password Baru (Kosongkan jika tetap)',
                        icon: Icons.lock_reset,
                      ),
                    ),
                    const SizedBox(height: 20),

                    GlassPrimaryButton(
                      label: 'Simpan Perubahan Profil',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        final lat = double.tryParse(
                              latCtrl.text.trim().replaceAll(',', '.'),
                            ) ??
                            akun.latitude;
                        final lng = double.tryParse(
                              lngCtrl.text.trim().replaceAll(',', '.'),
                            ) ??
                            akun.longitude;

                        final err = data.perbaruiProfilAktif(
                          nama: namaCtrl.text,
                          username: userCtrl.text,
                          noHp: hpCtrl.text,
                          alamat: alamatCtrl.text,
                          titikLokasi: titikCtrl.text,
                          latitude: lat,
                          longitude: lng,
                          avatarColorIndex: warnaDipilih,
                          photoUrl: fotoCtrl.text,
                          passwordBaru: passCtrl.text,
                        );

                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: merahTua,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil & lokasi berhasil diperbarui.'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    final isi = AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final akun = data.akunAktif;
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            tampilAppBar ? topPad : 12,
            18,
            tampilAppBar ? 32 : 120,
          ),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GlassAvatar(akun: akun, radius: 44),
                      GestureDetector(
                        onTap: () => _bukaEditProfil(context),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: merah,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    akun?.nama ?? 'Pengguna SaungLobster',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: teksUtama,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${akun?.username ?? 'user'} • ${akun?.peran ?? '-'}',
                    style: TextStyle(color: teksSekunder, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GlassPrimaryButton(
                      label: 'Edit Profil & Lokasi',
                      icon: Icons.tune_rounded,
                      onPressed: () => _bukaEditProfil(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Mode Gelap / Terang di Profil
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema Tampilan',
                          style: TextStyle(
                            color: teksUtama,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data.isDarkMode
                              ? 'Mode Gelap Aktif'
                              : 'Mode Terang Aktif',
                          style: TextStyle(color: teksSekunder, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const ThemeToggleButton(size: 38),
                ],
              ),
            ),
            const SizedBox(height: 16),

            judulBagian(context, 'Informasi Akun'),
            kartuMenu(
              context,
              ikon: Icons.email_outlined,
              judul: 'Email',
              keterangan: akun?.email ?? '-',
            ),
            const SizedBox(height: 10),
            kartuMenu(
              context,
              ikon: Icons.phone_outlined,
              judul: 'WhatsApp',
              keterangan: akun?.noHp ?? '-',
              warna: hijau,
            ),
            const SizedBox(height: 10),
            kartuMenu(
              context,
              ikon: Icons.home_outlined,
              judul: 'Alamat',
              keterangan: akun?.alamat ?? '-',
              warna: emas,
            ),
            const SizedBox(height: 16),

            judulBagian(context, 'Titik Lokasi'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: merah.withValues(alpha: 0.18),
                      border: Border.all(color: merah.withValues(alpha: 0.45)),
                    ),
                    child: const Icon(
                      Icons.pin_drop_rounded,
                      color: merah,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          akun?.titikLokasi ?? '-',
                          style: TextStyle(
                            color: teksUtama,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${akun?.latitude.toStringAsFixed(4) ?? '-'}  •  Lng: ${akun?.longitude.toStringAsFixed(4) ?? '-'}',
                          style: TextStyle(color: teksSekunder, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            GlassPrimaryButton(
              label: 'Keluar dari Akun',
              icon: Icons.logout_rounded,
              warna: merahTua,
              onPressed: () {
                data.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );

    if (!tampilAppBar) return isi;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Profil & Lokasi')),
      body: LiquidBackground(
        child: Stack(
          children: [
            isi,
            TopHeaderFade(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          ],
        ),
      ),
    );
  }
}