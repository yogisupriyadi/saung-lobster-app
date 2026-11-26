import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pesanan_restoran.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'detail_transaksi_page.dart';

/// Membuka halaman Checkout lengkap bergaya Shopee
void bukaCheckoutRestoran(
  BuildContext context, {
  String? kategoriAwal,
  double? beratAwal,
  PesananRestoran? editItem,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CheckoutRestoranPage(
        kategoriAwal: kategoriAwal,
        beratAwal: beratAwal,
        editItem: editItem,
      ),
    ),
  );
}

// =====================================================
// HALAMAN CHECKOUT ALA SHOPEE (ALAMAT + KEMASAN + METODE PEMBAYARAN)
// =====================================================
class CheckoutRestoranPage extends StatefulWidget {
  final String? kategoriAwal;
  final double? beratAwal;
  final PesananRestoran? editItem;

  const CheckoutRestoranPage({
    super.key,
    this.kategoriAwal,
    this.beratAwal,
    this.editItem,
  });

  @override
  State<CheckoutRestoranPage> createState() => _CheckoutRestoranPageState();
}

class _CheckoutRestoranPageState extends State<CheckoutRestoranPage> {
  late String _kategori;
  late double _beratKg;
  late String _kondisiOrder;
  late String _jenisKemasan;
  late String _metodePembayaran;
  late bool _bayarLangsung;
  late String _namaPenerima;
  late String _noHp;
  late String _alamatKirim;
  late double _lat;
  late double _lng;
  late TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    final data = DataSaungLobster.instance;
    final akun = data.akunAktif;
    final edit = widget.editItem;

    _kategori =
        edit?.kategori ?? widget.kategoriAwal ?? data.daftarKategori.first;
    if (!data.daftarKategori.contains(_kategori)) {
      _kategori = data.daftarKategori.first;
    }

    final stokSekarang = data.stok[_kategori] ?? 0;
    final beratDefault = edit?.beratKg ?? widget.beratAwal ?? 2.0;
    _beratKg = (edit == null && stokSekarang > 0 && beratDefault > stokSekarang)
        ? stokSekarang
        : beratDefault;

    _kondisiOrder = edit?.kondisiOrder ?? 'Lobster Hidup';
    _jenisKemasan = edit?.jenisKemasan ?? 'Kardus';
    _metodePembayaran = edit?.metodePembayaran ??
        DataSaungLobster.daftarMetodeBayarResto.first;
    _bayarLangsung = edit?.isLunas ?? false;
    _namaPenerima = edit?.namaRestoran ?? akun?.nama ?? 'Resto Sunda Jaya';
    _noHp = edit?.noHp ?? akun?.noHp ?? '085799887766';
    _alamatKirim = edit?.alamat ??
        akun?.alamat ??
        'Jl. Bujanggamanik No. 05, Kota Baru Parahyangan, Bandung Barat';
    _lat = edit?.latitude ?? akun?.latitude ?? -6.8588;
    _lng = edit?.longitude ?? akun?.longitude ?? 107.4792;
    _catatanCtrl = TextEditingController(text: edit?.catatan ?? '');
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  bool get _bisaBayarSekarang =>
      _metodePembayaran.startsWith('Transfer') ||
      _metodePembayaran.startsWith('QRIS');

  String _infoMetodeBayar(String metode) {
    if (metode.startsWith('Transfer')) {
      return 'BCA 7750-8812-34 a.n SaungLobster KBP • Verifikasi cepat';
    }
    if (metode.startsWith('QRIS')) {
      return 'Scan QRIS resmi SaungLobster • Bebas biaya admin';
    }
    if (metode.startsWith('COD')) {
      return 'Bayar tunai langsung ke kurir saat lobster tiba & dicek hidup';
    }
    return 'Khusus mitra restoran • Jatuh tempo 7 hari setelah barang diterima';
  }

  IconData _ikonMetodeBayar(String metode) {
    if (metode.startsWith('Transfer')) return Icons.account_balance_rounded;
    if (metode.startsWith('QRIS')) return Icons.qr_code_2_rounded;
    if (metode.startsWith('COD')) return Icons.payments_outlined;
    return Icons.calendar_month_rounded;
  }

  void _ubahAlamatSheet() {
    final namaCtrl = TextEditingController(text: _namaPenerima);
    final hpCtrl = TextEditingController(text: _noHp);
    final alamatCtrl = TextEditingController(text: _alamatKirim);
    double latTemp = _lat;
    double lngTemp = _lng;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: warnaModalSheet(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (innerContext, setSheetState) {
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
                    'Alamat Pengiriman',
                    style: TextStyle(
                      color: teksUtama,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pilih Cepat Area Kota Baru Parahyangan:',
                    style: TextStyle(color: teksSekunder, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: DataSaungLobster.presetLokasiKBP.map((loc) {
                      return ActionChip(
                        avatar: const Icon(Icons.pin_drop, size: 14),
                        label: Text(loc.$1.split(',').first),
                        onPressed: () {
                          setSheetState(() {
                            alamatCtrl.text = '${loc.$1}, Bandung Barat';
                            latTemp = loc.$2;
                            lngTemp = loc.$3;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: namaCtrl,
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Nama Penerima / Restoran',
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: hpCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Nomor WhatsApp',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: alamatCtrl,
                    maxLines: 2,
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Detail Alamat (Jalan, Blok, Patokan)',
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassPrimaryButton(
                    label: 'Gunakan Alamat Ini',
                    onPressed: () {
                      setState(() {
                        _namaPenerima = namaCtrl.text.trim().isEmpty
                            ? _namaPenerima
                            : namaCtrl.text.trim();
                        _noHp = hpCtrl.text.trim().isEmpty
                            ? _noHp
                            : hpCtrl.text.trim();
                        _alamatKirim = alamatCtrl.text.trim().isEmpty
                            ? _alamatKirim
                            : alamatCtrl.text.trim();
                        _lat = latTemp;
                        _lng = lngTemp;
                      });
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _buatPesanan() {
    final data = DataSaungLobster.instance;
    final hargaJual = data.hargaJual[_kategori] ?? 0;
    final edit = widget.editItem;
    final statusLunas = _bisaBayarSekarang && _bayarLangsung;

    final err = edit != null
        ? data.editPesanan(
            id: edit.id,
            namaRestoran: _namaPenerima,
            noHp: _noHp,
            alamat: _alamatKirim,
            kategori: _kategori,
            beratKg: _beratKg,
            hargaJualPerKg: hargaJual,
            catatan: _catatanCtrl.text,
            kondisiOrder: _kondisiOrder,
            jenisKemasan: _jenisKemasan,
            metodePembayaran: _metodePembayaran,
          )
        : data.tambahPesanan(
            namaRestoran: _namaPenerima,
            noHp: _noHp,
            alamat: _alamatKirim,
            kategori: _kategori,
            beratKg: _beratKg,
            hargaJualPerKg: hargaJual,
            isLunas: statusLunas,
            catatan: _catatanCtrl.text,
            kondisiOrder: _kondisiOrder,
            jenisKemasan: _jenisKemasan,
            metodePembayaran: _metodePembayaran,
            latitude: _lat,
            longitude: _lng,
          );

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: merahTua),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          edit != null
              ? 'Pesanan berhasil diperbarui!'
              : 'Pesanan berhasil dibuat via $_metodePembayaran.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerH = MediaQuery.of(context).padding.top + kToolbarHeight;
    final data = DataSaungLobster.instance;
    final teksUtama = warnaTeksUtama(context);
    final teksSekunder = warnaTeksSekunder(context);
    final dark = isTemaGelap(context);

    final stokTersedia = data.stok[_kategori] ?? 0;
    final maxStok = widget.editItem != null &&
            widget.editItem!.kategori == _kategori
        ? stokTersedia + widget.editItem!.beratKg
        : stokTersedia;

    final hargaPerKg = data.hargaJual[_kategori] ?? 0;
    final subtotal = _beratKg * hargaPerKg;
    final biayaKemasan = DataSaungLobster.tarifKemasan[_jenisKemasan] ?? 0;
    final totalBayar = subtotal + biayaKemasan;
    final isHidup = _kondisiOrder == 'Lobster Hidup';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.editItem != null ? 'Ubah Pesanan' : 'Checkout'),
      ),
      body: LiquidBackground(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(16, headerH + 8, 16, 122),
              children: [
                // 1. KARTU ALAMAT PENGIRIMAN
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  onTap: _ubahAlamatSheet,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: merah,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _namaPenerima,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: teksUtama,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '($_noHp)',
                                  style: TextStyle(
                                    color: teksSekunder,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _alamatKirim,
                              style: TextStyle(
                                color: teksSekunder,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, color: teksSekunder),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. PRODUK, BERAT & KONDISI
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: merah,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'OFFICIAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SaungLobster Fresh Supply',
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_kategori),
                        initialValue: _kategori,
                        isExpanded: true,
                        dropdownColor: warnaDropdownMenu(context),
                        style: TextStyle(color: teksUtama, fontSize: 14),
                        decoration: glassInputDecoration(
                          context,
                          label: 'Ukuran Lobster',
                          icon: Icons.set_meal_outlined,
                        ),
                        items: data.daftarKategori.map((k) {
                          return DropdownMenuItem(
                            value: k,
                            child: Text(k, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _kategori = v;
                              final s = data.stok[v] ?? 0;
                              if (_beratKg > s && s > 0) _beratKg = s;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rupiah(hargaPerKg)} / kg',
                                style: const TextStyle(
                                  color: merah,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Tersisa ${maxStok.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  color: hijau,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: teksSekunder.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  icon: Icon(
                                    Icons.remove,
                                    size: 17,
                                    color: teksUtama,
                                  ),
                                  onPressed: () {
                                    if (_beratKg > 0.5) {
                                      setState(
                                        () => _beratKg = double.parse(
                                          (_beratKg - 0.5).toStringAsFixed(1),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    '${_beratKg.toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                      color: teksUtama,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    size: 17,
                                    color: teksUtama,
                                  ),
                                  onPressed: () {
                                    if (_beratKg + 0.5 <= maxStok) {
                                      setState(
                                        () => _beratKg = double.parse(
                                          (_beratKg + 0.5).toStringAsFixed(1),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Kondisi Pesanan',
                        style: TextStyle(
                          color: teksSekunder,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Lobster Hidup', 'Segar Dingin'].map((k) {
                          return ChoiceChip(
                            label: Text(k),
                            selected: _kondisiOrder == k,
                            onSelected: (_) =>
                                setState(() => _kondisiOrder = k),
                          );
                        }).toList(),
                      ),
                      if (isHidup) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: hijau.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hijau.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: hijau,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jaminan 100% Hidup: Meski memilih kemasan Kardus (Gratis), kami menjamin lobster sampai lokasi dalam keadaan hidup.',
                                  style: TextStyle(
                                    color: hijau,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. OPSI KEMASAN PENGIRIMAN
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opsi Kemasan Pengiriman',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...DataSaungLobster.daftarWadah.map((kemasan) {
                        final terpilih = _jenisKemasan == kemasan;
                        final biaya =
                            DataSaungLobster.tarifKemasan[kemasan] ?? 0;
                        final desc =
                            DataSaungLobster.deskripsiKemasan[kemasan] ?? '';

                        return GestureDetector(
                          onTap: () => setState(() => _jenisKemasan = kemasan),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: terpilih
                                  ? (biaya == 0 ? hijau : merah)
                                      .withValues(alpha: dark ? 0.16 : 0.10)
                                  : Colors.transparent,
                              border: Border.all(
                                color: terpilih
                                    ? (biaya == 0 ? hijau : merah)
                                    : teksSekunder.withValues(alpha: 0.25),
                                width: terpilih ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  terpilih
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: terpilih
                                      ? (biaya == 0 ? hijau : merah)
                                      : teksSekunder,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            kemasan,
                                            style: TextStyle(
                                              color: teksUtama,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (biaya <= 0)
                                            Row(
                                              children: [
                                                Text(
                                                  'Rp10.000 ',
                                                  style: TextStyle(
                                                    color: teksSekunder,
                                                    fontSize: 11,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                                const Text(
                                                  'GRATIS',
                                                  style: TextStyle(
                                                    color: hijau,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Text(
                                              '+${rupiah(biaya)}',
                                              style: TextStyle(
                                                color: teksUtama,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        style: TextStyle(
                                          color: teksSekunder,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. METODE PEMBAYARAN (ALA SHOPEE)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...DataSaungLobster.daftarMetodeBayarResto.map((metode) {
                        final terpilih = _metodePembayaran == metode;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _metodePembayaran = metode;
                              if (!_bisaBayarSekarang) {
                                _bayarLangsung = false;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: terpilih
                                  ? merah.withValues(alpha: dark ? 0.16 : 0.08)
                                  : Colors.transparent,
                              border: Border.all(
                                color: terpilih
                                    ? merah
                                    : teksSekunder.withValues(alpha: 0.22),
                                width: terpilih ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _ikonMetodeBayar(metode),
                                  color: terpilih ? merah : teksSekunder,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        metode,
                                        style: TextStyle(
                                          color: teksUtama,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _infoMetodeBayar(metode),
                                        style: TextStyle(
                                          color: teksSekunder,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  terpilih
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: terpilih ? merah : teksSekunder,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_bisaBayarSekarang && widget.editItem == null)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Konfirmasi Bayar Sekarang (Lunas)',
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            'Aktifkan jika sudah transfer/scan QRIS',
                            style: TextStyle(color: teksSekunder, fontSize: 11),
                          ),
                          value: _bayarLangsung,
                          activeThumbColor: hijau,
                          onChanged: (v) => setState(() => _bayarLangsung = v),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 5. PESAN & RINCIAN BIAYA
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _catatanCtrl,
                        style: TextStyle(color: teksUtama),
                        decoration: glassInputDecoration(
                          context,
                          label: 'Pesan untuk Penjual (Opsional)',
                          hint: 'Misal: Kirim jam 10 pagi, titip ke dapur',
                          icon: Icons.chat_bubble_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _barisRingkasan(
                        context,
                        'Subtotal Produk (${_beratKg.toStringAsFixed(1)} kg)',
                        rupiah(subtotal),
                      ),
                      _barisRingkasan(
                        context,
                        'Biaya Kemasan ($_jenisKemasan)',
                        biayaKemasan <= 0
                            ? 'Rp0 (Gratis)'
                            : rupiah(biayaKemasan),
                        warnaNilai: biayaKemasan <= 0 ? hijau : null,
                      ),
                      _barisRingkasan(
                        context,
                        'Metode Pembayaran',
                        _metodePembayaran.split('(').first.trim(),
                      ),
                      Divider(
                        height: 20,
                        color: teksSekunder.withValues(alpha: 0.2),
                      ),
                      _barisRingkasan(
                        context,
                        'Total Pembayaran',
                        rupiah(totalBayar),
                        tebal: true,
                        warnaNilai: merah,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            TopHeaderFade(height: headerH),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    borderRadius: 22,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                rupiah(totalBayar),
                                style: const TextStyle(
                                  color: merah,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (biayaKemasan <= 0)
                                const Text(
                                  'Hemat Rp10.000 (Kardus Gratis)',
                                  style: TextStyle(
                                    color: hijau,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 152,
                          child: GlassPrimaryButton(
                            label: widget.editItem != null
                                ? 'Simpan'
                                : 'Buat Pesanan',
                            onPressed: maxStok > 0 ? _buatPesanan : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisRingkasan(
    BuildContext context,
    String label,
    String nilai, {
    bool tebal = false,
    Color? warnaNilai,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    tebal ? warnaTeksUtama(context) : warnaTeksSekunder(context),
                fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
                fontSize: tebal ? 14 : 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nilai,
            style: TextStyle(
              color: warnaNilai ?? warnaTeksUtama(context),
              fontWeight: tebal ? FontWeight.bold : FontWeight.w600,
              fontSize: tebal ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// 1. BERANDA ANALITIK PELANGGAN (ODOO PORTAL + LIVE TRACKER + REORDER)
// =====================================================
class BerandaRestoranPage extends StatelessWidget {
  final ValueChanged<int>? onPindahTab;

  const BerandaRestoranPage({super.key, this.onPindahTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final akun = data.akunAktif;
        final namaResto = akun?.nama ?? 'Pelanggan SaungLobster';
        final stats = data.analitikRestoran(namaResto);
        final perKategori = stats['perKategori'] as Map<String, double>;
        final orderAktif = data.pesananAktifTerbaruResto(namaResto);
        final orderTerakhir = data.pesananTerakhirResto(namaResto);
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
          children: [
            GlassCard(
              tintColor: merah,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $namaResto',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    akun?.titikLokasi ?? 'Kota Baru Parahyangan, Bandung Barat',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  GlassPrimaryButton(
                    label: 'Pesan Lobster Sekarang',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: () => bukaCheckoutRestoran(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (orderAktif != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPesananPage(
                        pesanan: orderAktif,
                        isAdmin: false,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pelacakan Pesanan Aktif',
                          style: TextStyle(
                            color: teksUtama,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        badgeStatus(context, '#ORD-${orderAktif.id}', merah),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${orderAktif.kategori} • ${orderAktif.beratKg} kg • ${orderAktif.metodePembayaran.split('(').first.trim()}',
                      style: TextStyle(color: teksSekunder, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    _orderStepper(context, orderAktif.statusKirim),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            judulBagian(context, 'Analitik Pembelian'),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.42,
              children: [
                GlassStatCard(
                  judul: 'Total Belanja',
                  nilai: rupiah(stats['totalBelanja'] as double),
                  ikon: Icons.payments_rounded,
                  warna: merah,
                ),
                GlassStatCard(
                  judul: 'Total Pembelian',
                  nilai:
                      '${(stats['totalKg'] as double).toStringAsFixed(1)} kg',
                  ikon: Icons.scale_rounded,
                  warna: hijau,
                ),
                GlassStatCard(
                  judul: 'Order Aktif',
                  nilai: '${stats['jumlahAktif']} pesanan',
                  ikon: Icons.local_shipping_rounded,
                  warna: const Color(0xFF3A86FF),
                ),
                GlassStatCard(
                  judul: 'Tagihan Tempo',
                  nilai: rupiah(stats['totalTempo'] as double),
                  ikon: Icons.receipt_long_rounded,
                  warna: emas,
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (orderTerakhir != null) ...[
              kartuMenu(
                context,
                ikon: Icons.replay_rounded,
                judul: 'Pesan Ulang Cepat (${orderTerakhir.kategori})',
                keterangan:
                    'Ulangi pesanan terakhir ${orderTerakhir.beratKg} kg langsung ke Checkout',
                warna: hijau,
                onTap: () => bukaCheckoutRestoran(
                  context,
                  kategoriAwal: orderTerakhir.kategori,
                  beratAwal: orderTerakhir.beratKg,
                ),
              ),
              const SizedBox(height: 14),
            ],

            GlassBarChart(
              judul: 'Pembelian per Ukuran',
              subjudul: 'Total (kg)',
              data: perKategori,
              warnaBar: merah,
            ),
            const SizedBox(height: 16),

            judulBagian(context, 'Menu Cepat'),
            kartuMenu(
              context,
              ikon: Icons.flash_on_rounded,
              judul: 'Katalog Flash Stock Segar',
              keterangan:
                  '${data.daftarKategori.length} ukuran siap kirim dengan Garansi Hidup',
              warna: merah,
              onTap: () => onPindahTab?.call(1),
            ),
            const SizedBox(height: 10),
            kartuMenu(
              context,
              ikon: Icons.shopping_bag_rounded,
              judul: 'Semua Riwayat Pesanan',
              keterangan:
                  '${stats['jumlahAktif']} diproses • ${stats['jumlahSelesai']} selesai',
              warna: const Color(0xFF3A86FF),
              onTap: () => onPindahTab?.call(2),
            ),
          ],
        );
      },
    );
  }

  Widget _orderStepper(BuildContext context, String status) {
    const steps = ['Disortir', 'Dikirim', 'Selesai'];
    final currentIdx = steps.indexOf(status).clamp(0, 2);

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepBefore = i ~/ 2;
          final lewat = stepBefore < currentIdx;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: lewat
                    ? hijau
                    : warnaTeksSekunder(context).withValues(alpha: 0.22),
              ),
            ),
          );
        }

        final idx = i ~/ 2;
        final selesai = idx <= currentIdx;
        final aktif = idx == currentIdx;

        return Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selesai
                    ? (aktif ? merah : hijau)
                    : warnaTeksSekunder(context).withValues(alpha: 0.16),
                border: Border.all(
                  color: selesai
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                idx == 0
                    ? Icons.inventory_2_rounded
                    : idx == 1
                        ? Icons.local_shipping_rounded
                        : Icons.check_rounded,
                size: 14,
                color: selesai ? Colors.white : warnaTeksSekunder(context),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              steps[idx],
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
                color: selesai
                    ? warnaTeksUtama(context)
                    : warnaTeksSekunder(context),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// =====================================================
// 2. KATALOG FLASH SALE REAL-TIME
// =====================================================
class KatalogRestoranPage extends StatefulWidget {
  const KatalogRestoranPage({super.key});

  @override
  State<KatalogRestoranPage> createState() => _KatalogRestoranPageState();
}

class _KatalogRestoranPageState extends State<KatalogRestoranPage> {
  Timer? _timer;
  Duration _sisaWaktu = Duration.zero;

  @override
  void initState() {
    super.initState();
    _hitungSisa();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_hitungSisa);
    });
  }

  void _hitungSisa() {
    final diff =
        DataSaungLobster.instance.akhirSesiStok.difference(DateTime.now());
    _sisaWaktu = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jam = _sisaWaktu.inHours.toString().padLeft(2, '0');
    final menit = (_sisaWaktu.inMinutes % 60).toString().padLeft(2, '0');
    final detik = (_sisaWaktu.inSeconds % 60).toString().padLeft(2, '0');

    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
          children: [
            GlassCard(
              tintColor: merah,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: emas, size: 30),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLASH STOCK SEGAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Batch panen hari ini • Garansi 100% Hidup',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _kotakWaktu(jam),
                      const Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _kotakWaktu(menit),
                      const Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _kotakWaktu(detik),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            judulBagian(context, 'Katalog Siap Kirim'),
            ...data.daftarKategori.map((k) {
              final stokKg = data.stok[k] ?? 0;
              final kuota = data.kuotaSesi[k] ?? 20.0;
              final rasioStok =
                  (stokKg / (kuota <= 0 ? 1 : kuota)).clamp(0.0, 1.0);
              final harga = data.hargaJual[k] ?? 0;
              final hampirHabis = stokKg > 0 && stokKg <= 8.0;

              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                merah.withValues(alpha: 0.25),
                                merahTua.withValues(alpha: 0.14),
                              ],
                            ),
                            border: Border.all(
                              color: merah.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Icon(
                            Icons.set_meal_rounded,
                            color: merah,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      k,
                                      style: TextStyle(
                                        color: teksUtama,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (hampirHabis)
                                    badgeStatus(context, 'Terbatas', emas),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${rupiah(harga)} / kg',
                                style: const TextStyle(
                                  color: merah,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kardus Gratis • Garansi 100% Hidup',
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: stokKg > 0 ? merah : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: stokKg > 0
                              ? () => bukaCheckoutRestoran(
                                    context,
                                    kategoriAwal: k,
                                  )
                              : null,
                          child: const Text('Pesan'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: stokKg > 0 ? rasioStok : 0,
                            minHeight: 18,
                            backgroundColor: merah.withValues(alpha: 0.16),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hampirHabis ? emas : merah,
                            ),
                          ),
                        ),
                        Text(
                          stokKg > 0
                              ? 'Tersisa ${stokKg.toStringAsFixed(1)} kg dari ${kuota.toStringAsFixed(0)} kg'
                              : 'STOK HABIS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _kotakWaktu(String angka) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        angka,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// =====================================================
// 3. PESANAN SAYA (BEBAS OVERFLOW DENGAN EXPANDED + WRAP)
// =====================================================
class PesananRestoranSayaPage extends StatelessWidget {
  const PesananRestoranSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final namaResto = data.akunAktif?.nama ?? '';
        final daftarSaya = data.cariPesanan(hanyaRestoran: namaResto);
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        if (daftarSaya.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Anda belum memiliki pesanan.\nPilih produk di Katalog Flash Stock untuk memesan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: teksSekunder),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 118),
          itemCount: daftarSaya.length,
          itemBuilder: (context, index) {
            final o = daftarSaya[index];
            final warnaKirim = o.statusKirim == 'Selesai'
                ? hijau
                : o.statusKirim == 'Dikirim'
                    ? const Color(0xFF3A86FF)
                    : emas;

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPesananPage(
                      pesanan: o,
                      isAdmin: false,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${o.kategori} • ${o.beratKg} kg',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: teksUtama,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rupiah(o.totalHarga),
                        style: const TextStyle(
                          color: merah,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#ORD-${o.id} • ${o.tanggal} • ${o.jenisKemasan} • ${o.metodePembayaran.split('(').first.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: teksSekunder, fontSize: 11.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            badgeStatus(context, o.statusKirim, warnaKirim),
                            badgeStatus(
                              context,
                              o.isLunas ? 'Lunas' : 'Tempo',
                              o.isLunas ? hijau : merah,
                            ),
                            if (o.garansiHidup)
                              badgeStatus(context, 'Garansi Hidup', hijau),
                          ],
                        ),
                      ),
                      if (o.statusKirim == 'Disortir') ...[
                        const SizedBox(width: 4),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          tooltip: 'Ubah Pesanan',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                            color: Color(0xFF3A86FF),
                          ),
                          onPressed: () => bukaCheckoutRestoran(
                            context,
                            editItem: o,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          tooltip: 'Batalkan Pesanan',
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: merah,
                          ),
                          onPressed: () {
                            data.hapusPesanan(o.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan dibatalkan.'),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}