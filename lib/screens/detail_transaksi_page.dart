import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pasokan.dart';
import '../models/pesanan_restoran.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';

class DetailPasokanPage extends StatelessWidget {
  final Pasokan pasokan;
  final bool tampilJarak;
  final bool isAdmin;

  const DetailPasokanPage({
    super.key,
    required this.pasokan,
    this.tampilJarak = false,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final headerH = MediaQuery.of(context).padding.top + kToolbarHeight;

    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);
        final warnaStatus = pasokan.status == 'Diterima'
            ? hijau
            : pasokan.status == 'Ditolak'
                ? merah
                : emas;
        final jarakKm = data.jarakDariGudang(
          pasokan.latitude,
          pasokan.longitude,
        );
        final menit = data.estimasiMenit(jarakKm);
        final infoWadah = pasokan.siapkanWadah
            ? (pasokan.jenisWadah ?? 'Disiapkan Mitra')
            : 'Dibawa kurir gudang';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: const Text('Detail Setoran')),
          body: LiquidBackground(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(18, headerH + 10, 18, 32),
                  children: [
                    if (pasokan.fotoProdukUrl != null &&
                        pasokan.fotoProdukUrl!.isNotEmpty) ...[
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            pasokan.fotoProdukUrl!,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 120,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: teksSekunder,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Foto produk tidak dapat dimuat',
                                    style: TextStyle(
                                      color: teksSekunder,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#PSK-${pasokan.id}',
                                style: TextStyle(
                                  color: teksUtama,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                children: [
                                  badgeStatus(
                                    context,
                                    pasokan.status,
                                    warnaStatus,
                                  ),
                                  if (pasokan.status == 'Diterima')
                                    badgeStatus(
                                      context,
                                      pasokan.danaDicairkan
                                          ? 'Dana Cair'
                                          : 'Belum Cair',
                                      pasokan.danaDicairkan ? hijau : emas,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            height: 26,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(context, 'Mitra Panen', pasokan.namaPetani),
                          _barisInfo(context, 'Lokasi', pasokan.lokasiPetani),
                          if (tampilJarak)
                            _barisInfo(
                              context,
                              'Jarak Gudang',
                              '${jarakKm.toStringAsFixed(1)} km (±$menit mnt)',
                              warnaNilai: merah,
                              tebal: true,
                            ),
                          _barisInfo(context, 'Tanggal', pasokan.tanggal),
                          _barisInfo(context, 'Ukuran', pasokan.kategori),
                          _barisInfo(context, 'Kondisi', pasokan.kondisi),
                          _barisInfo(context, 'Wadah Panen', infoWadah),
                          _barisInfo(
                            context,
                            'Estimasi Awal',
                            '${pasokan.jumlah} kg',
                          ),
                          if (pasokan.status == 'Diterima') ...[
                            _barisInfo(
                              context,
                              'Berat Diterima',
                              '${pasokan.beratDiterima} kg',
                            ),
                            _barisInfo(
                              context,
                              'Harga / kg',
                              rupiah(pasokan.hargaBeliSaatTerima),
                            ),
                            Divider(
                              height: 24,
                              color: teksSekunder.withValues(alpha: 0.2),
                            ),
                            _barisInfo(
                              context,
                              'Total Pembayaran',
                              rupiah(pasokan.totalBayar),
                              tebal: true,
                              warnaNilai: hijau,
                            ),
                          ],
                          Divider(
                            height: 24,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(
                            context,
                            'Pengambilan Dana',
                            pasokan.metodePencairan,
                          ),
                          _barisInfo(
                            context,
                            'Rekening / Tujuan',
                            pasokan.rekeningTujuan ?? '-',
                          ),
                          _barisInfo(
                            context,
                            'Catatan',
                            pasokan.catatan ?? 'Tidak ada catatan',
                          ),
                        ],
                      ),
                    ),

                    if (isAdmin && pasokan.status == 'Diterima') ...[
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Status Pencairan Dana Mitra',
                            style: TextStyle(
                              color: teksUtama,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            pasokan.danaDicairkan
                                ? 'Dana ${rupiah(pasokan.totalBayar)} sudah dicairkan via ${pasokan.metodePencairan}'
                                : 'Tandai aktif setelah dana dikirim ke mitra panen',
                            style: TextStyle(color: teksSekunder, fontSize: 12),
                          ),
                          value: pasokan.danaDicairkan,
                          activeThumbColor: hijau,
                          onChanged: (val) {
                            data.cairkanDanaPetani(pasokan.id, val);
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    GlassPrimaryButton(
                      label: 'Salin Nota untuk WhatsApp',
                      icon: Icons.copy_rounded,
                      warna: hijau,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: data.buatNotaPasokan(pasokan)),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nota setoran disalin ke clipboard.'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TopHeaderFade(height: headerH),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailPesananPage extends StatelessWidget {
  final PesananRestoran pesanan;
  final bool isAdmin;

  const DetailPesananPage({
    super.key,
    required this.pesanan,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final headerH = MediaQuery.of(context).padding.top + kToolbarHeight;

    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;
        final teksUtama = warnaTeksUtama(context);
        final teksSekunder = warnaTeksSekunder(context);
        final warnaKirim = pesanan.statusKirim == 'Selesai'
            ? hijau
            : pesanan.statusKirim == 'Dikirim'
                ? const Color(0xFF3A86FF)
                : emas;
        final jarakKm = data.jarakDariGudang(
          pesanan.latitude,
          pesanan.longitude,
        );
        final menit = data.estimasiMenit(jarakKm);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: const Text('Detail Pesanan')),
          body: LiquidBackground(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(18, headerH + 10, 18, 32),
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#ORD-${pesanan.id}',
                                style: TextStyle(
                                  color: teksUtama,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                children: [
                                  badgeStatus(
                                    context,
                                    pesanan.statusKirim,
                                    warnaKirim,
                                  ),
                                  badgeStatus(
                                    context,
                                    pesanan.isLunas ? 'Lunas' : 'Tempo',
                                    pesanan.isLunas ? hijau : merah,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            height: 26,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(context, 'Pelanggan', pesanan.namaRestoran),
                          _barisInfo(context, 'WhatsApp', pesanan.noHp),
                          _barisInfo(context, 'Alamat', pesanan.alamat),
                          if (isAdmin)
                            _barisInfo(
                              context,
                              'Jarak Kirim',
                              '${jarakKm.toStringAsFixed(1)} km (±$menit mnt)',
                              warnaNilai: merah,
                              tebal: true,
                            ),
                          _barisInfo(context, 'Tanggal Order', pesanan.tanggal),
                          _barisInfo(
                            context,
                            'Metode Bayar',
                            pesanan.metodePembayaran,
                          ),
                          Divider(
                            height: 24,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(context, 'Produk', pesanan.kategori),
                          _barisInfo(context, 'Kondisi', pesanan.kondisiOrder),
                          _barisInfo(
                            context,
                            'Berat',
                            '${pesanan.beratKg} kg',
                          ),
                          _barisInfo(
                            context,
                            'Harga / kg',
                            rupiah(pesanan.hargaJualPerKg),
                          ),
                          _barisInfo(
                            context,
                            'Subtotal Produk',
                            rupiah(pesanan.subtotalProduk),
                          ),
                          _barisInfo(
                            context,
                            'Kemasan',
                            pesanan.biayaKemasan <= 0
                                ? '${pesanan.jenisKemasan} (GRATIS)'
                                : '${pesanan.jenisKemasan} (${rupiah(pesanan.biayaKemasan)})',
                            warnaNilai: pesanan.biayaKemasan <= 0 ? hijau : null,
                          ),
                          if (pesanan.garansiHidup) ...[
                            const SizedBox(height: 8),
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
                                      'Garansi 100% Lobster Hidup sampai lokasi pengiriman (termasuk kemasan Kardus Gratis).',
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
                          Divider(
                            height: 24,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(
                            context,
                            'Total Tagihan',
                            rupiah(pesanan.totalHarga),
                            tebal: true,
                            warnaNilai: merah,
                          ),
                          Divider(
                            height: 24,
                            color: teksSekunder.withValues(alpha: 0.2),
                          ),
                          _barisInfo(
                            context,
                            'Catatan',
                            pesanan.catatan ?? 'Tidak ada catatan',
                          ),
                        ],
                      ),
                    ),

                    if (isAdmin) ...[
                      const SizedBox(height: 14),
                      // Ringkasan Profit HPP Khusus Admin
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analisis Keuntungan Order (Internal Admin)',
                              style: TextStyle(
                                color: teksUtama,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _barisInfo(
                              context,
                              'Modal HPP (${rupiah(pesanan.hargaBeliModalPerKg)}/kg)',
                              rupiah(pesanan.modalProduk),
                            ),
                            _barisInfo(
                              context,
                              'Laba Order Ini',
                              '+${rupiah(pesanan.labaOrder)}',
                              tebal: true,
                              warnaNilai: hijau,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Pengiriman',
                              style: TextStyle(
                                color: teksUtama,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children:
                                  ['Disortir', 'Dikirim', 'Selesai'].map((s) {
                                return ChoiceChip(
                                  label: Text(s),
                                  selected: pesanan.statusKirim == s,
                                  onSelected: (_) {
                                    data.ubahStatusKirim(pesanan.id, s);
                                  },
                                );
                              }).toList(),
                            ),
                            Divider(
                              height: 24,
                              color: teksSekunder.withValues(alpha: 0.2),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Pembayaran Lunas',
                                style: TextStyle(
                                  color: teksUtama,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                pesanan.isLunas
                                    ? 'Sudah dibayar via ${pesanan.metodePembayaran}'
                                    : 'Belum lunas (${pesanan.metodePembayaran})',
                                style: TextStyle(
                                  color: teksSekunder,
                                  fontSize: 12,
                                ),
                              ),
                              value: pesanan.isLunas,
                              activeThumbColor: hijau,
                              onChanged: (val) {
                                data.ubahStatusLunas(pesanan.id, val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    GlassPrimaryButton(
                      label: 'Salin Invoice untuk WhatsApp',
                      icon: Icons.copy_rounded,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: data.buatNotaPesanan(pesanan)),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Invoice disalin! Siap kirim via WhatsApp.'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TopHeaderFade(height: headerH),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _barisInfo(
  BuildContext context,
  String label,
  String nilai, {
  bool tebal = false,
  Color? warnaNilai,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: TextStyle(color: warnaTeksSekunder(context), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: tebal ? FontWeight.bold : FontWeight.w500,
              fontSize: tebal ? 15 : 13,
              color: warnaNilai ?? warnaTeksUtama(context),
            ),
          ),
        ),
      ],
    ),
  );
}