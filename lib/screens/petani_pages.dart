import 'package:flutter/material.dart';
import '../models/pasokan.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'detail_transaksi_page.dart';

/// Modal Setor / Edit Panen (Foto Produk + Opsi Wadah + Metode Pengambilan Dana)
void bukaFormSetorPanen(
  BuildContext context, {
  Pasokan? editItem,
  String? kategoriAwal,
}) {
  final data = DataSaungLobster.instance;
  final akun = data.akunAktif;
  final isEdit = editItem != null;

  final jumlahCtrl = TextEditingController(
    text: isEdit ? editItem.jumlah.toString() : '',
  );
  final catatanCtrl = TextEditingController(text: editItem?.catatan ?? '');
  final fotoCtrl = TextEditingController(text: editItem?.fotoProdukUrl ?? '');
  final rekeningCtrl = TextEditingController(
    text: editItem?.rekeningTujuan ?? '',
  );

  String kategori =
      editItem?.kategori ?? kategoriAwal ?? data.daftarKategori.first;
  if (!data.daftarKategori.contains(kategori)) {
    kategori = data.daftarKategori.first;
  }
  String kondisi = editItem?.kondisi ?? 'Segar / Hidup';
  bool siapkanWadah = editItem?.siapkanWadah ?? false;
  String jenisWadah = editItem?.jenisWadah ?? DataSaungLobster.daftarWadah.first;
  String metodeCair = editItem?.metodePencairan ??
      DataSaungLobster.daftarMetodeCairPetani.first;

  const contohFoto =
      'https://images.unsplash.com/photo-1553659971-f01207815844?w=600&q=80';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: warnaModalSheet(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (innerContext, setSheetState) {
          final teksUtama = warnaTeksUtama(innerContext);
          final teksSekunder = warnaTeksSekunder(innerContext);
          final acuanHarga = data.hargaBeli[kategori] ?? 0;
          final butuhRekening = !metodeCair.startsWith('Tunai');

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
                    isEdit ? 'Ubah Pengajuan Panen' : 'Ajukan Setoran Panen',
                    style: TextStyle(
                      color: teksUtama,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Acuan harga beli SaungLobster: ${rupiah(acuanHarga)} / kg',
                    style: const TextStyle(
                      color: hijau,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(kategori),
                    initialValue: kategori,
                    isExpanded: true,
                    dropdownColor: warnaDropdownMenu(innerContext),
                    style: TextStyle(color: teksUtama, fontSize: 14),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Ukuran Lobster',
                      icon: Icons.category_outlined,
                    ),
                    items: data.daftarKategori.map((k) {
                      return DropdownMenuItem(
                        value: k,
                        child: Text(k, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setSheetState(() => kategori = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: jumlahCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Estimasi Berat Panen (kg)',
                      icon: Icons.scale_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(kondisi),
                    initialValue: kondisi,
                    isExpanded: true,
                    dropdownColor: warnaDropdownMenu(innerContext),
                    style: TextStyle(color: teksUtama, fontSize: 14),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Kondisi Lobster',
                      icon: Icons.water_drop_outlined,
                    ),
                    items: const ['Segar / Hidup', 'Dingin', 'Lainnya']
                        .map(
                          (k) => DropdownMenuItem(
                            value: k,
                            child: Text(k, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheetState(() => kondisi = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // METODE PENGAMBILAN DANA PETANI
                  DropdownButtonFormField<String>(
                    key: ValueKey(metodeCair),
                    initialValue: metodeCair,
                    isExpanded: true,
                    dropdownColor: warnaDropdownMenu(innerContext),
                    style: TextStyle(color: teksUtama, fontSize: 14),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Metode Pengambilan Dana',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    items: DataSaungLobster.daftarMetodeCairPetani.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setSheetState(() => metodeCair = v);
                    },
                  ),
                  if (butuhRekening) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: rekeningCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: metodeCair.startsWith('Transfer')
                            ? 'No. Rekening & Nama Bank'
                            : 'Nomor DANA / GoPay',
                        hint: metodeCair.startsWith('Transfer')
                            ? 'Misal: BCA 7751234560 a.n Asep'
                            : 'Misal: DANA 081234567890',
                        icon: Icons.credit_card_outlined,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Foto Produk Panen (Opsional)',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setSheetState(() => fotoCtrl.text = contohFoto);
                        },
                        icon: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 15,
                          color: merah,
                        ),
                        label: const Text(
                          'Pakai Contoh',
                          style: TextStyle(color: merah, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: fotoCtrl,
                    onChanged: (_) => setSheetState(() {}),
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'URL Foto Hasil Panen',
                      hint: 'Tempel tautan foto lobster Anda',
                      icon: Icons.photo_camera_outlined,
                    ),
                  ),
                  if (fotoCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        fotoCtrl.text.trim(),
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: merah.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Preview foto belum tersedia',
                            style: TextStyle(color: teksSekunder, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GlassCard(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Apakah Anda menyiapkan tempat / wadah?',
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            siapkanWadah
                                ? 'Pilih jenis wadah yang sudah disiapkan'
                                : 'Kosongkan jika wadah dibawa kurir gudang',
                            style: TextStyle(color: teksSekunder, fontSize: 11),
                          ),
                          value: siapkanWadah,
                          activeThumbColor: merah,
                          onChanged: (v) {
                            setSheetState(() => siapkanWadah = v);
                          },
                        ),
                        if (siapkanWadah)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: DataSaungLobster.daftarWadah.map((w) {
                              return ChoiceChip(
                                label: Text(w),
                                selected: jenisWadah == w,
                                onSelected: (_) =>
                                    setSheetState(() => jenisWadah = w),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: catatanCtrl,
                    maxLines: 2,
                    style: TextStyle(color: teksUtama),
                    decoration: glassInputDecoration(
                      innerContext,
                      label: 'Catatan Panen (Opsional)',
                      hint: 'Misal: Siap jemput Sabtu pagi di kolam 2',
                      icon: Icons.notes_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassPrimaryButton(
                    label:
                        isEdit ? 'Simpan Perubahan' : 'Kirim Pengajuan Panen',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      final berat = double.tryParse(
                        jumlahCtrl.text.trim().replaceAll(',', '.'),
                      );
                      if (berat == null || berat <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan berat panen lebih dari 0.'),
                            backgroundColor: merahTua,
                          ),
                        );
                        return;
                      }

                      final tujuanFinal = butuhRekening
                          ? (rekeningCtrl.text.trim().isEmpty
                              ? 'Konfirmasi via WhatsApp'
                              : rekeningCtrl.text.trim())
                          : 'Dibayar tunai saat timbang';

                      if (isEdit) {
                        final err = data.editPasokan(
                          id: editItem.id,
                          namaPetani: editItem.namaPetani,
                          kategori: kategori,
                          jumlah: berat,
                          kondisi: kondisi,
                          catatan: catatanCtrl.text,
                          fotoProdukUrl: fotoCtrl.text,
                          siapkanWadah: siapkanWadah,
                          jenisWadah: siapkanWadah ? jenisWadah : null,
                          metodePencairan: metodeCair,
                          rekeningTujuan: tujuanFinal,
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
                      } else {
                        data.tambahPasokan(
                          Pasokan(
                            id: DateTime.now().microsecondsSinceEpoch % 100000,
                            namaPetani: akun?.nama ?? 'Mitra Panen',
                            kategori: kategori,
                            jumlah: double.parse(berat.toStringAsFixed(2)),
                            kondisi: kondisi,
                            tanggal: DateTime.now().toString().substring(0, 10),
                            catatan: catatanCtrl.text.trim().isEmpty
                                ? null
                                : catatanCtrl.text.trim(),
                            fotoProdukUrl: fotoCtrl.text.trim().isEmpty
                                ? null
                                : fotoCtrl.text.trim(),
                            siapkanWadah: siapkanWadah,
                            jenisWadah: siapkanWadah ? jenisWadah : null,
                            lokasiPetani: akun?.titikLokasi ??
                                'Kota Baru Parahyangan, Padalarang',
                            latitude: akun?.latitude ?? -6.8542,
                            longitude: akun?.longitude ?? 107.4685,
                            metodePencairan: metodeCair,
                            rekeningTujuan: tujuanFinal,
                            danaDicairkan: false,
                          ),
                        );
                      }

                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Pengajuan panen diperbarui.'
                                : 'Setoran panen terkirim ke SaungLobster.',
                          ),
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

// =====================================================
// 1. BERANDA ANALITIK MITRA PANEN + STATUS PENCAIRAN DANA
// =====================================================
class BerandaPetani extends StatelessWidget {
  const BerandaPetani({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final akun = data.akunAktif;
        final namaUser = akun?.nama ?? 'Mitra Panen';
        final stats = data.analitikPetani(namaUser);
        final perKategori = stats['perKategori'] as Map<String, double>;
        final skorQc = data.kualitasLolosSortirPetani(namaUser);
        final nilaiPending = data.estimasiPendingPetani(namaUser);
        final danaCair = stats['danaSudahCair'] as double;
        final danaMenunggu = stats['danaMenungguCair'] as double;
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
                    'Halo, $namaUser',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    akun?.titikLokasi ?? 'Mitra Budidaya Kota Baru Parahyangan',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  GlassPrimaryButton(
                    label: 'Ajukan Setoran Panen Baru',
                    icon: Icons.add_rounded,
                    onPressed: () => bukaFormSetorPanen(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            judulBagian(context, 'Analitik Panen Saya'),
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
                  judul: 'Total Pendapatan',
                  nilai: rupiah(stats['totalPendapatan'] as double),
                  ikon: Icons.account_balance_wallet_rounded,
                  warna: hijau,
                ),
                GlassStatCard(
                  judul: 'Total Terjual',
                  nilai:
                      '${(stats['totalKgDiterima'] as double).toStringAsFixed(1)} kg',
                  ikon: Icons.scale_rounded,
                  warna: const Color(0xFF3A86FF),
                ),
                GlassStatCard(
                  judul: 'Menunggu ACC',
                  nilai: '${stats['jumlahMenunggu']} setoran',
                  ikon: Icons.hourglass_top_rounded,
                  warna: emas,
                ),
                GlassStatCard(
                  judul: 'Diterima',
                  nilai: '${stats['jumlahDiterima']} kali',
                  ikon: Icons.verified_rounded,
                  warna: merah,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kartu Status Pengambilan / Pencairan Dana Petani
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dompet & Pencairan Dana',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      badgeStatus(
                        context,
                        danaMenunggu > 0 ? 'Proses Cair' : 'Semua Cair',
                        danaMenunggu > 0 ? emas : hijau,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sudah Dicairkan',
                              style:
                                  TextStyle(color: teksSekunder, fontSize: 11),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rupiah(danaCair),
                              style: const TextStyle(
                                color: hijau,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menunggu Pencairan',
                              style:
                                  TextStyle(color: teksSekunder, fontSize: 11),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rupiah(danaMenunggu),
                              style: TextStyle(
                                color: danaMenunggu > 0 ? emas : teksUtama,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kartu Kualitas QC & Pipeline
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Performa Kualitas & Pipeline',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      badgeStatus(
                        context,
                        'QC ${skorQc.toStringAsFixed(0)}%',
                        skorQc >= 85 ? hijau : emas,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (skorQc / 100).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: hijau.withValues(alpha: 0.16),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        skorQc >= 85 ? hijau : emas,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rasio berat lolos timbang gudang',
                        style: TextStyle(color: teksSekunder, fontSize: 11),
                      ),
                      Text(
                        'Est. Pending: ${rupiah(nilaiPending)}',
                        style: TextStyle(
                          color: nilaiPending > 0 ? emas : teksSekunder,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            GlassBarChart(
              judul: 'Volume Panen Diterima',
              subjudul: 'Per Ukuran (kg)',
              data: perKategori,
              warnaBar: hijau,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                judulBagian(context, 'Acuan Harga Beli Hari Ini'),
                Text(
                  'Ketuk untuk setor',
                  style: TextStyle(color: teksSekunder, fontSize: 11),
                ),
              ],
            ),
            ...data.daftarKategori.map((k) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                onTap: () => bukaFormSetorPanen(context, kategoriAwal: k),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hijau.withValues(alpha: 0.16),
                      ),
                      child: const Icon(
                        Icons.price_check_rounded,
                        color: hijau,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            k,
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ketuk untuk ajukan setoran ukuran ini',
                            style: TextStyle(color: teksSekunder, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${rupiah(data.hargaBeli[k] ?? 0)} / kg',
                      style: const TextStyle(
                        color: hijau,
                        fontWeight: FontWeight.bold,
                      ),
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
}

// =====================================================
// 2. RIWAYAT SETORAN PETANI (STATUS PENCAIRAN + EDIT/BATAL)
// =====================================================
class RiwayatPetaniPage extends StatefulWidget {
  const RiwayatPetaniPage({super.key});

  @override
  State<RiwayatPetaniPage> createState() => _RiwayatPetaniPageState();
}

class _RiwayatPetaniPageState extends State<RiwayatPetaniPage> {
  String? filterStatus;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final namaSaya = data.akunAktif?.nama ?? '';
        final daftar = data.cariPasokan(
          filterStatus: filterStatus,
          hanyaPetani: namaSaya,
        );
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [null, 'Menunggu', 'Diterima', 'Ditolak'].map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s ?? 'Semua'),
                      selected: filterStatus == s,
                      onSelected: (_) => setState(() => filterStatus = s),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: daftar.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Belum ada riwayat setoran panen.\nTekan tombol + di kanan bawah untuk mengajukan panen.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: teksSekunder),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 118),
                      itemCount: daftar.length,
                      itemBuilder: (context, index) {
                        final p = daftar[index];
                        final warna = p.status == 'Diterima'
                            ? hijau
                            : p.status == 'Ditolak'
                                ? merah
                                : emas;

                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPasokanPage(pasokan: p),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (p.fotoProdukUrl != null &&
                                      p.fotoProdukUrl!.isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        p.fotoProdukUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 48,
                                          height: 48,
                                          color: merah.withValues(alpha: 0.12),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: merah,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${p.kategori} • ${p.jumlah} kg',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: teksUtama,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            badgeStatus(
                                              context,
                                              p.status,
                                              warna,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${p.kondisi} • ${p.tanggal} • ${p.metodePencairan}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: teksSekunder,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  badgeStatus(
                                    context,
                                    p.siapkanWadah
                                        ? 'Wadah: ${p.jenisWadah}'
                                        : 'Wadah dari Kurir',
                                    const Color(0xFF3A86FF),
                                  ),
                                  if (p.status == 'Diterima')
                                    badgeStatus(
                                      context,
                                      p.danaDicairkan
                                          ? 'Dana Cair'
                                          : 'Menunggu Cair',
                                      p.danaDicairkan ? hijau : emas,
                                    ),
                                  if (p.fotoProdukUrl != null &&
                                      p.fotoProdukUrl!.isNotEmpty)
                                    badgeStatus(context, 'Ada Foto', hijau),
                                ],
                              ),
                              if (p.status == 'Diterima')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Diterima ${p.beratDiterima} kg • ${rupiah(p.totalBayar)}',
                                    style: const TextStyle(
                                      color: hijau,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              if (p.status == 'Menunggu') ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => bukaFormSetorPanen(
                                        context,
                                        editItem: p,
                                      ),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Color(0xFF3A86FF),
                                      ),
                                      label: const Text(
                                        'Ubah',
                                        style:
                                            TextStyle(color: Color(0xFF3A86FF)),
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        data.hapusPasokan(p.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Pengajuan dibatalkan.'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: merah,
                                      ),
                                      label: const Text(
                                        'Batalkan',
                                        style: TextStyle(color: merah),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}