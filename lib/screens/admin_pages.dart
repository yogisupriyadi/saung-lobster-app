import 'package:flutter/material.dart';
import '../models/pasokan.dart';
import '../models/pesanan_restoran.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'detail_transaksi_page.dart';

// =====================================================
// HELPER FORM ADMIN
// =====================================================
void bukaDialogKategoriAdmin(
  BuildContext context, {
  String? editKategori,
}) {
  final data = DataSaungLobster.instance;
  final isEdit = editKategori != null;

  final namaCtrl = TextEditingController(text: editKategori ?? '');
  final beliCtrl = TextEditingController(
    text: isEdit ? (data.hargaBeli[editKategori] ?? 0).toStringAsFixed(0) : '',
  );
  final jualCtrl = TextEditingController(
    text: isEdit ? (data.hargaJual[editKategori] ?? 0).toStringAsFixed(0) : '',
  );
  final stokCtrl = TextEditingController(
    text: isEdit ? (data.stok[editKategori] ?? 0).toStringAsFixed(1) : '0',
  );

  showDialog(
    context: context,
    builder: (dialogContext) {
      final teksUtama = warnaTeksUtama(dialogContext);
      final teksSekunder = warnaTeksSekunder(dialogContext);

      return AlertDialog(
        title: Text(
          isEdit ? 'Edit Ukuran & Stok' : 'Tambah Kategori Baru',
          style: TextStyle(color: teksUtama),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  dialogContext,
                  label: 'Nama Ukuran / Produk',
                  hint: 'Misal: Lobster 6 Inch',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: beliCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  dialogContext,
                  label: 'Harga Beli (Rp/kg)',
                  icon: Icons.shopping_basket_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jualCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  dialogContext,
                  label: 'Harga Jual (Rp/kg)',
                  icon: Icons.sell_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stokCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  dialogContext,
                  label: 'Stok Gudang (kg)',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: teksSekunder)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: merah,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final beli = double.tryParse(beliCtrl.text.trim()) ?? -1;
              final jual = double.tryParse(jualCtrl.text.trim()) ?? -1;
              final stokVal = double.tryParse(
                    stokCtrl.text.trim().replaceAll(',', '.'),
                  ) ??
                  -1;

              final err = isEdit
                  ? data.editKategori(
                      kategoriLama: editKategori,
                      namaBaru: namaCtrl.text,
                      beli: beli,
                      jual: jual,
                      stokBaru: stokVal,
                    )
                  : data.tambahKategoriBaru(
                      namaKategori: namaCtrl.text,
                      beli: beli,
                      jual: jual,
                      stokAwal: stokVal,
                    );

              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: merahTua),
                );
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEdit
                        ? 'Kategori, harga & stok diperbarui.'
                        : 'Kategori baru berhasil ditambahkan.',
                  ),
                ),
              );
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      );
    },
  );
}

void bukaFormPesananAdmin(
  BuildContext context, {
  PesananRestoran? editItem,
}) {
  final data = DataSaungLobster.instance;
  final namaCtrl = TextEditingController(text: editItem?.namaRestoran ?? '');
  final hpCtrl = TextEditingController(text: editItem?.noHp ?? '');
  final alamatCtrl = TextEditingController(
    text: editItem?.alamat ?? 'Jl. Bujanggamanik No. 05, Kota Baru Parahyangan',
  );

  String kategoriTerpilih = editItem?.kategori ?? data.daftarKategori.first;
  if (!data.daftarKategori.contains(kategoriTerpilih)) {
    kategoriTerpilih = data.daftarKategori.first;
  }
  String kondisiOrder = editItem?.kondisiOrder ?? 'Lobster Hidup';
  String jenisKemasan = editItem?.jenisKemasan ?? 'Kardus';
  String metodeBayar = editItem?.metodePembayaran ??
      DataSaungLobster.daftarMetodeBayarResto.first;

  final beratCtrl = TextEditingController(
    text: editItem != null ? editItem.beratKg.toString() : '',
  );
  final hargaCtrl = TextEditingController(
    text: (editItem?.hargaJualPerKg ?? data.hargaJual[kategoriTerpilih] ?? 0)
        .toStringAsFixed(0),
  );
  final catatanCtrl = TextEditingController(text: editItem?.catatan ?? '');
  bool isLunas = editItem?.isLunas ?? false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (innerContext, setDialogState) {
          final teksUtama = warnaTeksUtama(innerContext);
          final teksSekunder = warnaTeksSekunder(innerContext);
          final sisaStok = data.stok[kategoriTerpilih] ?? 0;

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: Text(
              editItem == null ? 'Catat Pesanan Baru' : 'Ubah Pesanan',
              style: TextStyle(color: teksUtama),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: namaCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Nama Restoran / Pembeli',
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
                        label: 'No. WhatsApp',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: alamatCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Alamat (Kota Baru Parahyangan)',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(kategoriTerpilih),
                      initialValue: kategoriTerpilih,
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
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            kategoriTerpilih = val;
                            hargaCtrl.text =
                                (data.hargaJual[val] ?? 0).toStringAsFixed(0);
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 10),
                      child: Text(
                        'Stok tersedia: ${sisaStok.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: hijau,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextField(
                      controller: beratCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Berat Pesanan (kg)',
                        icon: Icons.scale_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hargaCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Harga Jual (Rp/kg)',
                        icon: Icons.payments_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(jenisKemasan),
                      initialValue: jenisKemasan,
                      isExpanded: true,
                      dropdownColor: warnaDropdownMenu(innerContext),
                      style: TextStyle(color: teksUtama, fontSize: 13.5),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Kemasan Pengiriman',
                        icon: Icons.inventory_2_outlined,
                      ),
                      items: DataSaungLobster.daftarWadah.map((w) {
                        final biaya = DataSaungLobster.tarifKemasan[w] ?? 0;
                        final teks = biaya <= 0
                            ? '$w (Gratis)'
                            : '$w (+${rupiah(biaya)})';
                        return DropdownMenuItem(
                          value: w,
                          child: Text(
                            teks,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => jenisKemasan = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(metodeBayar),
                      initialValue: metodeBayar,
                      isExpanded: true,
                      dropdownColor: warnaDropdownMenu(innerContext),
                      style: TextStyle(color: teksUtama, fontSize: 13.5),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Metode Pembayaran',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      items: DataSaungLobster.daftarMetodeBayarResto.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            m,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => metodeBayar = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey(kondisiOrder),
                      initialValue: kondisiOrder,
                      isExpanded: true,
                      dropdownColor: warnaDropdownMenu(innerContext),
                      style: TextStyle(color: teksUtama, fontSize: 14),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Kondisi Pesanan',
                        icon: Icons.verified_user_outlined,
                      ),
                      items: const ['Lobster Hidup', 'Segar Dingin']
                          .map(
                            (k) => DropdownMenuItem(
                              value: k,
                              child: Text(k, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => kondisiOrder = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catatanCtrl,
                      style: TextStyle(color: teksUtama),
                      decoration: glassInputDecoration(
                        innerContext,
                        label: 'Catatan (Opsional)',
                        icon: Icons.notes_outlined,
                      ),
                    ),
                    if (editItem == null)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Sudah Lunas',
                          style: TextStyle(color: teksUtama, fontSize: 13),
                        ),
                        value: isLunas,
                        activeColor: hijau,
                        onChanged: (v) {
                          setDialogState(() => isLunas = v ?? false);
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Batal', style: TextStyle(color: teksSekunder)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: merah,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final berat = double.tryParse(
                        beratCtrl.text.trim().replaceAll(',', '.'),
                      ) ??
                      0;
                  final harga = double.tryParse(hargaCtrl.text.trim()) ?? 0;

                  final err = editItem == null
                      ? data.tambahPesanan(
                          namaRestoran: namaCtrl.text,
                          noHp: hpCtrl.text,
                          alamat: alamatCtrl.text,
                          kategori: kategoriTerpilih,
                          beratKg: berat,
                          hargaJualPerKg: harga,
                          isLunas: isLunas,
                          catatan: catatanCtrl.text,
                          kondisiOrder: kondisiOrder,
                          jenisKemasan: jenisKemasan,
                          metodePembayaran: metodeBayar,
                        )
                      : data.editPesanan(
                          id: editItem.id,
                          namaRestoran: namaCtrl.text,
                          noHp: hpCtrl.text,
                          alamat: alamatCtrl.text,
                          kategori: kategoriTerpilih,
                          beratKg: berat,
                          hargaJualPerKg: harga,
                          catatan: catatanCtrl.text,
                          kondisiOrder: kondisiOrder,
                          jenisKemasan: jenisKemasan,
                          metodePembayaran: metodeBayar,
                        );

                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err), backgroundColor: merahTua),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        editItem == null
                            ? 'Pesanan dicatat & stok gudang otomatis dipotong.'
                            : 'Pesanan berhasil diperbarui.',
                      ),
                    ),
                  );
                },
                child: Text(editItem == null ? 'Simpan' : 'Update'),
              ),
            ],
          );
        },
      );
    },
  );
}

// =====================================================
// 1. BERANDA ANALITIK ADMIN + LAPORAN KEUNTUNGAN HPP
// =====================================================
class BerandaAdmin extends StatelessWidget {
  final ValueChanged<int>? onPindahTab;

  const BerandaAdmin({super.key, this.onPindahTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final akun = data.akunAktif;
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);
        final stokTipis = data.kategoriStokMenipis;
        final panenPending =
            data.pasokan.where((p) => p.status == 'Menunggu').take(2).toList();
        final orderAktif = data.pesanan
            .where((o) => o.statusKirim != 'Selesai')
            .take(2)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
          children: [
            GlassCard(
              tintColor: merah,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${akun?.nama ?? 'Admin'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.pin_drop_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                akun?.titikLokasi ??
                                    'Gudang Kota Baru Parahyangan',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    child: const Icon(
                      Icons.set_meal_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            judulBagian(context, 'Ringkasan Operasional'),
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
                  judul: 'Total Stok',
                  nilai: '${data.totalStok.toStringAsFixed(1)} kg',
                  ikon: Icons.warehouse_rounded,
                  warna: hijau,
                ),
                GlassStatCard(
                  judul: 'Panen Menunggu',
                  nilai: '${data.jumlahMenunggu} item',
                  ikon: Icons.pending_actions_rounded,
                  warna: emas,
                ),
                GlassStatCard(
                  judul: 'Order Aktif',
                  nilai: '${data.jumlahPesananAktif} order',
                  ikon: Icons.local_shipping_rounded,
                  warna: const Color(0xFF3A86FF),
                ),
                GlassStatCard(
                  judul: 'Nilai Aset Stok',
                  nilai: rupiah(data.totalNilaiStok),
                  ikon: Icons.payments_rounded,
                  warna: merah,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // LAPORAN KEUNTUNGAN & ARUS KAS ADMIN (BERBASIS HPP)
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Keuntungan & Arus Kas',
                        style: TextStyle(
                          color: teksUtama,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      badgeStatus(
                        context,
                        'Margin ${data.persenMarginLaba.toStringAsFixed(1)}%',
                        hijau,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sorotan Laba Kotor + Terealisasi + Tempo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hijau.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: hijau.withValues(alpha: 0.30)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laba Terealisasi (Lunas)',
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '+${rupiah(data.labaTerealisasi)}',
                                style: const TextStyle(
                                  color: hijau,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Potensi Laba Tempo',
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '+${rupiah(data.potensiLabaTempo)}',
                                style: const TextStyle(
                                  color: emas,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _kolomKeuangan(
                          context,
                          'Omzet Jual',
                          data.totalPenjualan,
                          const Color(0xFF3A86FF),
                        ),
                      ),
                      Expanded(
                        child: _kolomKeuangan(
                          context,
                          'Modal HPP',
                          data.totalModalTerjual,
                          teksUtama,
                        ),
                      ),
                      Expanded(
                        child: _kolomKeuangan(
                          context,
                          'Total Laba',
                          data.labaKotorPenjualan,
                          hijau,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: data.rasioPelunasan,
                      minHeight: 7,
                      backgroundColor: merah.withValues(alpha: 0.18),
                      valueColor: const AlwaysStoppedAnimation<Color>(hijau),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Piutang Tempo Resto (${data.jumlahOrderTempo} order)',
                        style: TextStyle(color: teksSekunder, fontSize: 11),
                      ),
                      Text(
                        rupiah(data.totalPiutangTempo),
                        style: TextStyle(
                          color: data.totalPiutangTempo > 0 ? emas : hijau,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kewajiban Cair ke Petani (${data.jumlahMenungguCairPetani} item)',
                        style: TextStyle(color: teksSekunder, fontSize: 11),
                      ),
                      Text(
                        rupiah(data.totalKewajibanPetani),
                        style: TextStyle(
                          color: data.totalKewajibanPetani > 0 ? merah : hijau,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (stokTipis.isNotEmpty) ...[
              const SizedBox(height: 14),
              GlassCard(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: emas,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Peringatan Stok Menipis (≤ 8 kg)',
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          'Ketuk restock',
                          style: TextStyle(color: teksSekunder, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stokTipis.map((k) {
                        final sisa = data.stok[k] ?? 0;
                        return ActionChip(
                          avatar: const Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: emas,
                          ),
                          label: Text('$k (${sisa.toStringAsFixed(1)} kg)'),
                          onPressed: () =>
                              bukaDialogKategoriAdmin(context, editKategori: k),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            GlassBarChart(
              judul: 'Analitik Stok per Ukuran',
              subjudul: 'Real-time (kg)',
              data: data.analitikStokPerKategori,
              warnaBar: merah,
            ),
            const SizedBox(height: 16),

            if (panenPending.isNotEmpty || orderAktif.isNotEmpty) ...[
              judulBagian(context, 'Antrean Perlu Tindakan'),
              ...panenPending.map((p) {
                final jarak = data
                    .jarakDariGudang(p.latitude, p.longitude)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: kartuMenu(
                    context,
                    ikon: Icons.move_to_inbox_rounded,
                    judul: 'Panen: ${p.namaPetani} (${p.jumlah} kg)',
                    keterangan:
                        '${p.kategori} • $jarak km • Menunggu verifikasi',
                    warna: emas,
                    onTap: () => onPindahTab?.call(1),
                  ),
                );
              }),
              ...orderAktif.map((o) {
                final jarak = data
                    .jarakDariGudang(o.latitude, o.longitude)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: kartuMenu(
                    context,
                    ikon: Icons.local_shipping_rounded,
                    judul: 'Order: ${o.namaRestoran} (${o.beratKg} kg)',
                    keterangan:
                        '${o.kategori} • ${o.statusKirim} • $jarak km',
                    warna: const Color(0xFF3A86FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPesananPage(
                            pesanan: o,
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],

            judulBagian(context, 'Modul Operasional'),
            kartuMenu(
              context,
              ikon: Icons.inventory_2_rounded,
              judul: 'Kelola Stok, Ukuran & Harga',
              keterangan:
                  '${data.daftarKategori.length} ukuran aktif • tambah/edit/hapus lewat GUI',
              warna: hijau,
              onTap: () => onPindahTab?.call(2),
            ),
            const SizedBox(height: 10),
            kartuMenu(
              context,
              ikon: Icons.receipt_long_rounded,
              judul: 'Semua Pesanan & Jarak Kirim',
              keterangan:
                  '${data.daftarMitraRestoranUnik.length} pelanggan • ${data.pesanan.length} total order',
              warna: merah,
              onTap: () => onPindahTab?.call(3),
            ),
          ],
        );
      },
    );
  }

  Widget _kolomKeuangan(
    BuildContext context,
    String label,
    double nilai,
    Color warna,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: warnaTeksSekunder(context), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          rupiah(nilai),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: warna,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// 2. PENERIMAAN PANEN PETANI (JARAK KM + CAIRKAN DANA)
// =====================================================
class PenerimaanPage extends StatefulWidget {
  const PenerimaanPage({super.key});

  @override
  State<PenerimaanPage> createState() => _PenerimaanPageState();
}

class _PenerimaanPageState extends State<PenerimaanPage> {
  String kataKunci = '';
  String? filterStatus;

  void _periksaPasokan(BuildContext context, Pasokan p) {
    final beratController = TextEditingController(text: p.jumlah.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        final teksUtama = warnaTeksUtama(dialogContext);
        final teksSekunder = warnaTeksSekunder(dialogContext);

        return AlertDialog(
          title: Text(
            'Verifikasi Timbangan',
            style: TextStyle(color: teksUtama),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mitra: ${p.namaPetani}', style: TextStyle(color: teksUtama)),
              Text('Ukuran: ${p.kategori}',
                  style: TextStyle(color: teksSekunder)),
              Text('Diajukan: ${p.jumlah} kg',
                  style: TextStyle(color: teksSekunder)),
              const SizedBox(height: 14),
              TextField(
                controller: beratController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  dialogContext,
                  label: 'Berat aktual diterima (kg)',
                  icon: Icons.scale_outlined,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: teksSekunder)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hijau,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final berat = double.tryParse(
                  beratController.text.replaceAll(',', '.'),
                );
                if (berat == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan angka berat valid.')),
                  );
                  return;
                }
                final err = DataSaungLobster.instance.terimaPasokan(p, berat);
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: merahTua),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Panen diterima & stok gudang otomatis bertambah.'),
                  ),
                );
              },
              child: const Text('Terima'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final daftar = data.cariPasokan(
          kataKunci: kataKunci,
          filterStatus: filterStatus,
        );
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => kataKunci = v),
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  context,
                  label: 'Cari mitra, lokasi KBP, atau ukuran...',
                  icon: Icons.search_rounded,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const SizedBox(height: 6),
            Expanded(
              child: daftar.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada pengajuan panen yang cocok.',
                        style: TextStyle(color: teksSekunder),
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
                        final jarakKm = data.jarakDariGudang(
                          p.latitude,
                          p.longitude,
                        );
                        final menit = data.estimasiMenit(jarakKm);

                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPasokanPage(
                                  pasokan: p,
                                  tampilJarak: true,
                                  isAdmin: true,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (p.fotoProdukUrl != null &&
                                      p.fotoProdukUrl!.isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        p.fotoProdukUrl!,
                                        width: 54,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 54,
                                          height: 54,
                                          color: merah.withValues(alpha: 0.12),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: merah,
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
                                                p.namaPetani,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: teksUtama,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                                          '${p.kategori} • ${p.jumlah} kg • ${p.kondisi}',
                                          style: TextStyle(
                                            color: teksUtama,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    color: merah,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '${jarakKm.toStringAsFixed(1)} km (±$menit mnt) • ${p.lokasiPetani}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: teksSekunder,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pencairan: ${p.metodePencairan}${p.rekeningTujuan != null ? ' (${p.rekeningTujuan})' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 11.5,
                                ),
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
                                        : 'Tanpa Wadah',
                                    const Color(0xFF3A86FF),
                                  ),
                                  if (p.status == 'Diterima')
                                    badgeStatus(
                                      context,
                                      p.danaDicairkan
                                          ? 'Dana Cair'
                                          : 'Belum Cair',
                                      p.danaDicairkan ? hijau : emas,
                                    ),
                                  badgeStatus(context, p.tanggal, teksSekunder),
                                ],
                              ),
                              if (p.status == 'Diterima')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Diterima: ${p.beratDiterima} kg (${rupiah(p.totalBayar)})',
                                    style: const TextStyle(
                                      color: hijau,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (p.status == 'Menunggu') ...[
                                    ElevatedButton(
                                      onPressed: () =>
                                          _periksaPasokan(context, p),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hijau,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text('ACC & Timbang'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: teksSekunder,
                                        side: BorderSide(
                                          color: teksSekunder.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => data.tolakPasokan(p),
                                      child: const Text('Tolak'),
                                    ),
                                  ] else if (p.status == 'Diterima' &&
                                      !p.danaDicairkan) ...[
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        data.cairkanDanaPetani(p.id, true);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Dana ${rupiah(p.totalBayar)} untuk ${p.namaPetani} ditandai cair.',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: emas,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.payments_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Cairkan Dana',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Hapus Data',
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: teksSekunder,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      data.hapusPasokan(p.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Data panen dihapus.'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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

// =====================================================
// 3. KATALOG STOK, UKURAN & HARGA (CRUD PENUH VIA GUI)
// =====================================================
class KatalogAdminPage extends StatelessWidget {
  const KatalogAdminPage({super.key});

  void _konfirmasiHapus(BuildContext context, String kategori) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Kategori?',
          style: TextStyle(color: warnaTeksUtama(dialogContext)),
        ),
        content: Text(
          'Hapus "$kategori" dari daftar stok dan harga aktif?',
          style: TextStyle(color: warnaTeksSekunder(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(color: warnaTeksSekunder(dialogContext)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: merah,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final err = DataSaungLobster.instance.hapusKategori(kategori);
              Navigator.pop(dialogContext);
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: merahTua),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Persediaan Gudang',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${data.totalStok.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nilai Aset: ${rupiah(data.totalNilaiStok)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Tambah Ukuran / Kategori',
                    onPressed: () => bukaDialogKategoriAdmin(context),
                    icon: const Icon(Icons.add_rounded, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                judulBagian(context, 'Daftar Ukuran, Stok & Harga'),
                TextButton.icon(
                  onPressed: () => bukaDialogKategoriAdmin(context),
                  icon: const Icon(Icons.add, size: 17, color: merah),
                  label: const Text('Tambah', style: TextStyle(color: merah)),
                ),
              ],
            ),
            ...data.daftarKategori.map((item) {
              final berat = data.stok[item] ?? 0;
              final beli = data.hargaBeli[item] ?? 0;
              final jual = data.hargaJual[item] ?? 0;
              final margin = jual - beli;

              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                onTap: () =>
                    bukaDialogKategoriAdmin(context, editKategori: item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: merah.withValues(alpha: 0.18),
                            border:
                                Border.all(color: merah.withValues(alpha: 0.45)),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: merah,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item,
                                style: TextStyle(
                                  color: teksUtama,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Stok: ${berat.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  color: berat > 0 ? hijau : merah,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        badgeStatus(
                          context,
                          '+${rupiah(margin)}',
                          margin >= 0 ? hijau : merah,
                        ),
                      ],
                    ),
                    Divider(
                      height: 22,
                      color: teksSekunder.withValues(alpha: 0.18),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Beli: ${rupiah(beli)}/kg  •  Jual: ${rupiah(jual)}/kg',
                            style: TextStyle(color: teksSekunder, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit Stok & Harga',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF3A86FF),
                            size: 19,
                          ),
                          onPressed: () => bukaDialogKategoriAdmin(
                            context,
                            editKategori: item,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hapus Kategori',
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: teksSekunder,
                            size: 19,
                          ),
                          onPressed: () => _konfirmasiHapus(context, item),
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
}

// =====================================================
// 4. PESANAN RESTORAN (JARAK + METODE BAYAR + LABA PER ORDER)
// =====================================================
class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  String kataKunci = '';
  String? filterStatus;
  bool hanyaBelumLunas = false;

  void _konfirmasiHapus(PesananRestoran order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Pesanan?',
          style: TextStyle(color: warnaTeksUtama(dialogContext)),
        ),
        content: Text(
          'Hapus pesanan #ORD-${order.id} dari ${order.namaRestoran}? '
          'Jika belum selesai dikirim, stok otomatis kembali ke gudang.',
          style: TextStyle(color: warnaTeksSekunder(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(color: warnaTeksSekunder(dialogContext)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: merah,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              DataSaungLobster.instance.hapusPesanan(order.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan berhasil dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final daftar = data.cariPesanan(
          kataKunci: kataKunci,
          filterStatus: filterStatus,
          hanyaBelumLunas: hanyaBelumLunas,
        );
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => kataKunci = v),
                style: TextStyle(color: teksUtama),
                decoration: glassInputDecoration(
                  context,
                  label: 'Cari restoran, alamat KBP, atau ukuran...',
                  icon: Icons.search_rounded,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ...[null, 'Disortir', 'Dikirim', 'Selesai'].map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s ?? 'Semua'),
                        selected: filterStatus == s,
                        onSelected: (_) => setState(() => filterStatus = s),
                      ),
                    );
                  }),
                  FilterChip(
                    label: const Text('Tempo'),
                    selected: hanyaBelumLunas,
                    onSelected: (v) => setState(() => hanyaBelumLunas = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: daftar.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada pesanan yang cocok.',
                        style: TextStyle(color: teksSekunder),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 118),
                      itemCount: daftar.length,
                      itemBuilder: (context, index) {
                        final o = daftar[index];
                        final warnaKirim = o.statusKirim == 'Selesai'
                            ? hijau
                            : o.statusKirim == 'Dikirim'
                                ? const Color(0xFF3A86FF)
                                : emas;
                        final jarakKm = data.jarakDariGudang(
                          o.latitude,
                          o.longitude,
                        );
                        final menit = data.estimasiMenit(jarakKm);

                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPesananPage(
                                  pesanan: o,
                                  isAdmin: true,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      o.namaRestoran,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: teksUtama,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rupiah(o.totalHarga),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: merah,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${o.kategori} • ${o.beratKg} kg • ${o.jenisKemasan} • ${o.metodePembayaran.split('(').first.trim()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: teksUtama,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    color: merah,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${jarakKm.toStringAsFixed(1)} km (±$menit mnt) • ${o.alamat}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: teksSekunder,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        badgeStatus(
                                          context,
                                          o.statusKirim,
                                          warnaKirim,
                                        ),
                                        badgeStatus(
                                          context,
                                          o.isLunas ? 'Lunas' : 'Tempo',
                                          o.isLunas ? hijau : merah,
                                        ),
                                        badgeStatus(
                                          context,
                                          'Laba +${rupiah(o.labaOrder)}',
                                          hijau,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Edit Pesanan',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 19,
                                      color: Color(0xFF3A86FF),
                                    ),
                                    onPressed: () => bukaFormPesananAdmin(
                                      context,
                                      editItem: o,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Hapus Pesanan',
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 19,
                                      color: teksSekunder,
                                    ),
                                    onPressed: () => _konfirmasiHapus(o),
                                  ),
                                ],
                              ),
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