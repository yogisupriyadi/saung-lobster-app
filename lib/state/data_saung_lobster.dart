import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/akun_pengguna.dart';
import '../models/pasokan.dart';
import '../models/pesanan_restoran.dart';

class DataSaungLobster extends ChangeNotifier {
  static final DataSaungLobster instance = DataSaungLobster._();

  DataSaungLobster._();

  // =====================================================
  // 0. TEMA, KEMASAN, METODE BAYAR & PENCAIRAN
  // =====================================================
  bool isDarkMode = true;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  static const List<String> daftarWadah = [
    'Kardus',
    'Boks Styrofoam',
    'Keranjang Plastik',
  ];

  static const Map<String, double> tarifKemasan = {
    'Kardus': 0,
    'Boks Styrofoam': 25000,
    'Keranjang Plastik': 35000,
  };

  static const Map<String, String> deskripsiKemasan = {
    'Kardus':
        'Gratis • Dilapisi pengaman lembap, garansi 100% hidup untuk order Lobster Hidup',
    'Boks Styrofoam':
        'Insulasi suhu dingin + es gel, cocok perjalanan menengah/jauh',
    'Keranjang Plastik':
        'Sirkulasi udara maksimal, praktis untuk muatan besar & bongkar muat',
  };

  static const List<String> daftarMetodeBayarResto = [
    'Transfer Bank (BCA / Mandiri)',
    'QRIS SaungLobster',
    'COD (Tunai saat Terima)',
    'Tempo 7 Hari (Invoice B2B)',
  ];

  static const List<String> daftarMetodeCairPetani = [
    'Transfer Bank',
    'E-Wallet (DANA / GoPay)',
    'Tunai di Lokasi',
  ];

  static const List<(String, double, double)> presetLokasiKBP = [
    ('Jl. Parahyangan Raya Kav. 12, Kota Baru Parahyangan', -6.8614, 107.4758),
    ('Tatar Ratnasasih No. 24, Kota Baru Parahyangan', -6.8542, 107.4685),
    ('Jl. Bujanggamanik No. 05, Kota Baru Parahyangan', -6.8588, 107.4792),
    ('Tatar Jingganagara No. 14, Kota Baru Parahyangan', -6.8685, 107.4640),
    ('Tatar Wangsakerta Blok C-08, Kota Baru Parahyangan', -6.8718, 107.4862),
  ];

  final DateTime akhirSesiStok = DateTime.now().add(
    const Duration(hours: 3, minutes: 42, seconds: 19),
  );

  // =====================================================
  // 1. AUTENTIKASI & PROFIL PENGGUNA (ALAMAT KBP)
  // =====================================================
  final List<AkunPengguna> daftarAkun = [
    AkunPengguna(
      id: 'U01',
      nama: 'Admin SaungLobster',
      username: 'admin_saung',
      email: 'admin@saunglobster.com',
      password: 'admin123',
      peran: 'Admin',
      noHp: '081122334455',
      alamat: 'Jl. Parahyangan Raya Kav. 12, Kota Baru Parahyangan, Padalarang',
      avatarColorIndex: 0,
      titikLokasi: 'Gudang Utama SaungLobster, KBP',
      latitude: -6.8614,
      longitude: 107.4758,
    ),
    AkunPengguna(
      id: 'U02',
      nama: 'Pak Asep',
      username: 'asep_kolam',
      email: 'petani@saunglobster.com',
      password: 'petani123',
      peran: 'Petani',
      noHp: '081234567890',
      alamat: 'Tatar Ratnasasih No. 24, Kota Baru Parahyangan, Bandung Barat',
      avatarColorIndex: 1,
      titikLokasi: 'Kolam Budidaya Tatar Ratnasasih, KBP',
      latitude: -6.8542,
      longitude: 107.4685,
    ),
    AkunPengguna(
      id: 'U03',
      nama: 'Resto Sunda Jaya',
      username: 'sunda_jaya',
      email: 'resto@saunglobster.com',
      password: 'resto123',
      peran: 'Restoran',
      noHp: '085799887766',
      alamat: 'Jl. Bujanggamanik No. 05, Kota Baru Parahyangan, Bandung Barat',
      avatarColorIndex: 2,
      titikLokasi: 'Resto Sunda Jaya, KBP',
      latitude: -6.8588,
      longitude: 107.4792,
    ),
  ];

  AkunPengguna? akunAktif;

  AkunPengguna get akunAdmin =>
      daftarAkun.firstWhere((a) => a.peran == 'Admin');

  double hitungJarakKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  double jarakDariGudang(double latTujuan, double lngTujuan) {
    final gudang = akunAdmin;
    return hitungJarakKm(
      gudang.latitude,
      gudang.longitude,
      latTujuan,
      lngTujuan,
    );
  }

  int estimasiMenit(double jarakKm) => math.max(5, (jarakKm * 3.5).round());

  String? login(String identitas, String password) {
    final kunci = identitas.trim().toLowerCase().replaceAll('@', '');
    final emailRaw = identitas.trim().toLowerCase();
    for (final akun in daftarAkun) {
      final cocokEmail = akun.email.toLowerCase() == emailRaw;
      final cocokUser = akun.username.toLowerCase() == kunci;
      if ((cocokEmail || cocokUser) && akun.password == password) {
        akunAktif = akun;
        notifyListeners();
        return null;
      }
    }
    return 'Email/username atau password tidak sesuai.';
  }

  String? daftarAkunBaru({
    required String nama,
    required String email,
    required String password,
    required String peran,
    required String noHp,
    required String alamat,
    String? username,
    String? titikLokasi,
  }) {
    final emailBersih = email.trim().toLowerCase();
    if (!emailBersih.contains('@')) return 'Format email tidak valid.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (daftarAkun.any((a) => a.email.toLowerCase() == emailBersih)) {
      return 'Email sudah terdaftar. Silakan gunakan email lain.';
    }

    final defaultUser = nama
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final usernameFinal = (username != null && username.trim().isNotEmpty)
        ? username.trim().toLowerCase().replaceAll('@', '')
        : (defaultUser.isEmpty ? 'user_saung' : defaultUser);

    final baru = AkunPengguna(
      id: 'U${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      nama: nama.trim(),
      username: usernameFinal,
      email: emailBersih,
      password: password,
      peran: peran,
      noHp: noHp.trim(),
      alamat: alamat.trim(),
      titikLokasi: (titikLokasi != null && titikLokasi.trim().isNotEmpty)
          ? titikLokasi.trim()
          : alamat.trim(),
      latitude: -6.8630,
      longitude: 107.4720,
    );

    daftarAkun.add(baru);
    akunAktif = baru;
    notifyListeners();
    return null;
  }

  String? perbaruiProfilAktif({
    required String nama,
    required String username,
    required String noHp,
    required String alamat,
    required String titikLokasi,
    required double latitude,
    required double longitude,
    required int avatarColorIndex,
    String? photoUrl,
    String? passwordBaru,
  }) {
    final akun = akunAktif;
    if (akun == null) return 'Tidak ada akun aktif.';
    if (nama.trim().isEmpty || username.trim().isEmpty) {
      return 'Nama dan username wajib diisi.';
    }
    final userBersih =
        username.trim().toLowerCase().replaceAll('@', '').replaceAll(' ', '_');
    final bentrok = daftarAkun.any(
      (a) => a.id != akun.id && a.username.toLowerCase() == userBersih,
    );
    if (bentrok) return 'Username @$userBersih sudah dipakai akun lain.';
    if (passwordBaru != null &&
        passwordBaru.trim().isNotEmpty &&
        passwordBaru.trim().length < 6) {
      return 'Password baru minimal 6 karakter.';
    }

    final namaLama = akun.nama;
    final namaBaru = nama.trim();

    akun.perbaruiProfil(
      namaBaru: namaBaru,
      usernameBaru: userBersih,
      noHpBaru: noHp.trim(),
      alamatBaru: alamat.trim(),
      titikLokasiBaru: titikLokasi.trim(),
      latBaru: latitude,
      lngBaru: longitude,
      avatarColorBaru: avatarColorIndex,
      photoUrlBaru: photoUrl,
      passwordBaru: passwordBaru,
    );

    if (akun.peran == 'Petani') {
      for (final p in pasokan) {
        if (p.namaPetani.toLowerCase() == namaLama.toLowerCase()) {
          p.namaPetani = namaBaru;
          p.lokasiPetani = akun.titikLokasi;
          p.latitude = akun.latitude;
          p.longitude = akun.longitude;
        }
      }
    } else if (akun.peran == 'Restoran') {
      for (final o in pesanan) {
        if (o.namaRestoran.toLowerCase() == namaLama.toLowerCase()) {
          o.namaRestoran = namaBaru;
          o.noHp = akun.noHp;
          o.alamat = akun.alamat;
          o.latitude = akun.latitude;
          o.longitude = akun.longitude;
        }
      }
    }

    notifyListeners();
    return null;
  }

  void logout() {
    akunAktif = null;
    notifyListeners();
  }

  // =====================================================
  // 2. KATALOG UKURAN INCI, HARGA & STOK (CRUD PENUH)
  // =====================================================
  final List<String> daftarKategori = [
    'Lobster Bibit',
    'Lobster 3 Inch',
    'Lobster 4 Inch',
    'Lobster 5 Inch',
  ];

  final Map<String, double> hargaBeli = {
    'Lobster Bibit': 110000,
    'Lobster 3 Inch': 135000,
    'Lobster 4 Inch': 160000,
    'Lobster 5 Inch': 195000,
  };

  final Map<String, double> hargaJual = {
    'Lobster Bibit': 145000,
    'Lobster 3 Inch': 180000,
    'Lobster 4 Inch': 215000,
    'Lobster 5 Inch': 260000,
  };

  final Map<String, double> stok = {
    'Lobster Bibit': 8.0,
    'Lobster 3 Inch': 12.0,
    'Lobster 4 Inch': 15.5,
    'Lobster 5 Inch': 6.0,
  };

  final Map<String, double> kuotaSesi = {
    'Lobster Bibit': 15.0,
    'Lobster 3 Inch': 20.0,
    'Lobster 4 Inch': 25.0,
    'Lobster 5 Inch': 15.0,
  };

  String? tambahKategoriBaru({
    required String namaKategori,
    required double beli,
    required double jual,
    required double stokAwal,
  }) {
    final bersih = namaKategori.trim();
    if (bersih.isEmpty) return 'Nama ukuran/kategori wajib diisi.';
    if (daftarKategori.any((k) => k.toLowerCase() == bersih.toLowerCase())) {
      return 'Kategori "$bersih" sudah ada.';
    }
    if (beli < 0 || jual < 0 || stokAwal < 0) {
      return 'Harga dan stok tidak boleh negatif.';
    }

    daftarKategori.add(bersih);
    hargaBeli[bersih] = beli;
    hargaJual[bersih] = jual;
    stok[bersih] = double.parse(stokAwal.toStringAsFixed(2));
    kuotaSesi[bersih] = math.max(15.0, stokAwal * 1.4);
    notifyListeners();
    return null;
  }

  String? editKategori({
    required String kategoriLama,
    required String namaBaru,
    required double beli,
    required double jual,
    required double stokBaru,
  }) {
    final bersih = namaBaru.trim();
    if (bersih.isEmpty) return 'Nama kategori wajib diisi.';
    if (beli < 0 || jual < 0 || stokBaru < 0) {
      return 'Harga dan stok tidak boleh negatif.';
    }
    final index = daftarKategori.indexOf(kategoriLama);
    if (index == -1) return 'Kategori tidak ditemukan.';

    final bentrok = daftarKategori.any(
      (k) => k != kategoriLama && k.toLowerCase() == bersih.toLowerCase(),
    );
    if (bentrok) return 'Kategori "$bersih" sudah ada.';

    if (kategoriLama != bersih) {
      daftarKategori[index] = bersih;
      hargaBeli.remove(kategoriLama);
      hargaJual.remove(kategoriLama);
      stok.remove(kategoriLama);
      kuotaSesi[bersih] = kuotaSesi.remove(kategoriLama) ?? 20.0;

      for (final p in pasokan) {
        if (p.kategori == kategoriLama) p.kategori = bersih;
      }
      for (final o in pesanan) {
        if (o.kategori == kategoriLama) o.kategori = bersih;
      }
    }

    hargaBeli[bersih] = beli;
    hargaJual[bersih] = jual;
    stok[bersih] = double.parse(stokBaru.toStringAsFixed(2));
    if ((kuotaSesi[bersih] ?? 0) < stokBaru) {
      kuotaSesi[bersih] = stokBaru;
    }
    notifyListeners();
    return null;
  }

  String? hapusKategori(String kategori) {
    if (daftarKategori.length <= 1) {
      return 'Minimal harus ada 1 kategori produk aktif.';
    }
    daftarKategori.remove(kategori);
    hargaBeli.remove(kategori);
    hargaJual.remove(kategori);
    stok.remove(kategori);
    kuotaSesi.remove(kategori);
    notifyListeners();
    return null;
  }

  // =====================================================
  // 3. DATA PASOKAN PETANI (FOTO + WADAH + PENCAIRAN DANA)
  // =====================================================
  final List<Pasokan> pasokan = [
    Pasokan(
      id: 1001,
      namaPetani: 'Pak Asep',
      kategori: 'Lobster 4 Inch',
      jumlah: 8.0,
      kondisi: 'Segar / Hidup',
      tanggal: '2026-11-23',
      status: 'Diterima',
      beratDiterima: 8.0,
      hargaBeliSaatTerima: 160000,
      catatan: 'Standby Sabtu pagi, kondisi aktif semua',
      siapkanWadah: true,
      jenisWadah: 'Keranjang Plastik',
      lokasiPetani: 'Tatar Ratnasasih No. 24, Kota Baru Parahyangan',
      latitude: -6.8542,
      longitude: 107.4685,
      metodePencairan: 'Transfer Bank',
      rekeningTujuan: 'BCA 7751234560 a.n Asep',
      danaDicairkan: true,
    ),
    Pasokan(
      id: 1003,
      namaPetani: 'Pak Asep',
      kategori: 'Lobster 3 Inch',
      jumlah: 5.5,
      kondisi: 'Segar / Hidup',
      tanggal: '2026-11-24',
      status: 'Diterima',
      beratDiterima: 5.0,
      hargaBeliSaatTerima: 135000,
      catatan: 'Hasil panen kolam 2',
      siapkanWadah: true,
      jenisWadah: 'Kardus',
      lokasiPetani: 'Tatar Ratnasasih No. 24, Kota Baru Parahyangan',
      latitude: -6.8542,
      longitude: 107.4685,
      metodePencairan: 'E-Wallet (DANA / GoPay)',
      rekeningTujuan: 'DANA 081234567890',
      danaDicairkan: false, // Menunggu dicairkan Admin
    ),
    Pasokan(
      id: 1002,
      namaPetani: 'Mang Ujang',
      kategori: 'Lobster 5 Inch',
      jumlah: 6.5,
      kondisi: 'Segar / Hidup',
      tanggal: '2026-11-25',
      status: 'Menunggu',
      catatan: 'Siap panen akhir pekan ini, ukuran seragam',
      siapkanWadah: true,
      jenisWadah: 'Boks Styrofoam',
      lokasiPetani: 'Tatar Wangsakerta Blok C-08, Kota Baru Parahyangan',
      latitude: -6.8718,
      longitude: 107.4862,
      metodePencairan: 'Tunai di Lokasi',
      rekeningTujuan: 'Dibayar tunai saat timbang',
      danaDicairkan: false,
    ),
  ];

  void tambahPasokan(Pasokan data) {
    pasokan.insert(0, data);
    notifyListeners();
  }

  String? editPasokan({
    required int id,
    required String namaPetani,
    required String kategori,
    required double jumlah,
    required String kondisi,
    String? catatan,
    String? fotoProdukUrl,
    bool? siapkanWadah,
    String? jenisWadah,
    String? metodePencairan,
    String? rekeningTujuan,
  }) {
    final index = pasokan.indexWhere((p) => p.id == id);
    if (index == -1) return 'Data pasokan tidak ditemukan.';
    if (pasokan[index].status != 'Menunggu') {
      return 'Pasokan yang sudah diproses tidak dapat diubah.';
    }
    if (namaPetani.trim().isEmpty || jumlah <= 0) {
      return 'Nama dan jumlah berat harus diisi dengan benar.';
    }
    pasokan[index].perbaruiData(
      namaPetaniBaru: namaPetani.trim(),
      kategoriBaru: kategori,
      jumlahBaru: double.parse(jumlah.toStringAsFixed(2)),
      kondisiBaru: kondisi,
      catatanBaru: (catatan != null && catatan.trim().isNotEmpty)
          ? catatan.trim()
          : null,
      fotoBaru: fotoProdukUrl,
      siapkanWadahBaru: siapkanWadah,
      jenisWadahBaru: jenisWadah,
      metodePencairanBaru: metodePencairan,
      rekeningTujuanBaru: rekeningTujuan,
    );
    notifyListeners();
    return null;
  }

  void hapusPasokan(int id) {
    final index = pasokan.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final target = pasokan[index];
    if (target.status == 'Diterima') {
      final sisa = (stok[target.kategori] ?? 0) - target.beratDiterima;
      stok[target.kategori] =
          double.parse((sisa < 0 ? 0 : sisa).toStringAsFixed(2));
    }
    pasokan.removeAt(index);
    notifyListeners();
  }

  String? terimaPasokan(Pasokan data, double berat) {
    if (data.status != 'Menunggu') {
      return 'Pasokan ini sudah diproses sebelumnya.';
    }
    if (berat <= 0 || berat > data.jumlah) {
      return 'Berat harus > 0 dan maksimal ${data.jumlah} kg.';
    }

    data.beratDiterima = double.parse(berat.toStringAsFixed(2));
    data.hargaBeliSaatTerima = hargaBeli[data.kategori] ?? 0;
    data.status = 'Diterima';

    final stokSekarang = stok[data.kategori] ?? 0;
    final stokBaru =
        double.parse((stokSekarang + data.beratDiterima).toStringAsFixed(2));
    stok[data.kategori] = stokBaru;
    if ((kuotaSesi[data.kategori] ?? 0) < stokBaru) {
      kuotaSesi[data.kategori] = stokBaru;
    }

    notifyListeners();
    return null;
  }

  void tolakPasokan(Pasokan data) {
    if (data.status != 'Menunggu') return;
    data.status = 'Ditolak';
    notifyListeners();
  }

  void cairkanDanaPetani(int idPasokan, bool cair) {
    final index = pasokan.indexWhere((p) => p.id == idPasokan);
    if (index != -1 && pasokan[index].status == 'Diterima') {
      pasokan[index].danaDicairkan = cair;
      notifyListeners();
    }
  }

  // =====================================================
  // 4. DATA PESANAN RESTORAN (METODE BAYAR + HPP + KEMASAN)
  // =====================================================
  final List<PesananRestoran> pesanan = [
    PesananRestoran(
      id: 2001,
      namaRestoran: 'Resto Sunda Jaya',
      noHp: '085799887766',
      alamat: 'Jl. Bujanggamanik No. 05, Kota Baru Parahyangan, Bandung Barat',
      kategori: 'Lobster 4 Inch',
      beratKg: 5.0,
      hargaJualPerKg: 215000,
      hargaBeliModalPerKg: 160000,
      tanggal: '2026-11-25',
      statusKirim: 'Dikirim',
      isLunas: false,
      catatan: 'Minta lobster hidup semua untuk menu malam',
      kondisiOrder: 'Lobster Hidup',
      jenisKemasan: 'Kardus',
      biayaKemasan: 0,
      garansiHidup: true,
      metodePembayaran: 'Tempo 7 Hari (Invoice B2B)',
      latitude: -6.8588,
      longitude: 107.4792,
    ),
    PesananRestoran(
      id: 2003,
      namaRestoran: 'Resto Sunda Jaya',
      noHp: '085799887766',
      alamat: 'Jl. Bujanggamanik No. 05, Kota Baru Parahyangan, Bandung Barat',
      kategori: 'Lobster 3 Inch',
      beratKg: 3.5,
      hargaJualPerKg: 180000,
      hargaBeliModalPerKg: 135000,
      tanggal: '2026-11-23',
      statusKirim: 'Selesai',
      isLunas: true,
      catatan: 'Pesanan rutin akhir pekan',
      kondisiOrder: 'Lobster Hidup',
      jenisKemasan: 'Boks Styrofoam',
      biayaKemasan: 25000,
      garansiHidup: true,
      metodePembayaran: 'Transfer Bank (BCA / Mandiri)',
      latitude: -6.8588,
      longitude: 107.4792,
    ),
    PesananRestoran(
      id: 2002,
      namaRestoran: 'RM Seafood Nusantara',
      noHp: '081355667788',
      alamat: 'Tatar Jingganagara No. 14, Kota Baru Parahyangan, Bandung Barat',
      kategori: 'Lobster 5 Inch',
      beratKg: 4.0,
      hargaJualPerKg: 260000,
      hargaBeliModalPerKg: 195000,
      tanggal: '2026-11-24',
      statusKirim: 'Selesai',
      isLunas: true,
      catatan: 'Kirim sebelum jam 10 pagi',
      kondisiOrder: 'Lobster Hidup',
      jenisKemasan: 'Keranjang Plastik',
      biayaKemasan: 35000,
      garansiHidup: true,
      metodePembayaran: 'QRIS SaungLobster',
      latitude: -6.8685,
      longitude: 107.4640,
    ),
  ];

  String? tambahPesanan({
    required String namaRestoran,
    required String noHp,
    required String alamat,
    required String kategori,
    required double beratKg,
    required double hargaJualPerKg,
    bool isLunas = false,
    String? catatan,
    String kondisiOrder = 'Lobster Hidup',
    String jenisKemasan = 'Kardus',
    String metodePembayaran = 'Transfer Bank (BCA / Mandiri)',
    double? latitude,
    double? longitude,
  }) {
    if (namaRestoran.trim().isEmpty) return 'Nama restoran wajib diisi.';
    if (beratKg <= 0 || hargaJualPerKg <= 0) {
      return 'Berat pesanan dan harga jual harus lebih dari 0.';
    }

    final stokTersedia = stok[kategori] ?? 0;
    if (beratKg > stokTersedia) {
      return 'Stok tidak mencukupi! Sisa $kategori hanya ${stokTersedia.toStringAsFixed(1)} kg.';
    }

    stok[kategori] = double.parse((stokTersedia - beratKg).toStringAsFixed(2));
    final biayaPack = tarifKemasan[jenisKemasan] ?? 0;
    final modalHpp = hargaBeli[kategori] ?? 0;

    final baru = PesananRestoran(
      id: DateTime.now().microsecondsSinceEpoch % 100000,
      namaRestoran: namaRestoran.trim(),
      noHp: noHp.trim().isEmpty ? '-' : noHp.trim(),
      alamat: alamat.trim().isEmpty ? '-' : alamat.trim(),
      kategori: kategori,
      beratKg: double.parse(beratKg.toStringAsFixed(2)),
      hargaJualPerKg: hargaJualPerKg,
      hargaBeliModalPerKg: modalHpp,
      tanggal: DateTime.now().toString().substring(0, 10),
      statusKirim: 'Disortir',
      isLunas: isLunas,
      catatan: (catatan != null && catatan.trim().isNotEmpty)
          ? catatan.trim()
          : null,
      kondisiOrder: kondisiOrder,
      jenisKemasan: jenisKemasan,
      biayaKemasan: biayaPack,
      garansiHidup: kondisiOrder == 'Lobster Hidup',
      metodePembayaran: metodePembayaran,
      latitude: latitude ?? -6.8588,
      longitude: longitude ?? 107.4792,
    );

    pesanan.insert(0, baru);
    notifyListeners();
    return null;
  }

  String? editPesanan({
    required int id,
    required String namaRestoran,
    required String noHp,
    required String alamat,
    required String kategori,
    required double beratKg,
    required double hargaJualPerKg,
    String? catatan,
    String? kondisiOrder,
    String? jenisKemasan,
    String? metodePembayaran,
  }) {
    final index = pesanan.indexWhere((o) => o.id == id);
    if (index == -1) return 'Data pesanan tidak ditemukan.';
    if (namaRestoran.trim().isEmpty) return 'Nama restoran wajib diisi.';
    if (beratKg <= 0 || hargaJualPerKg <= 0) {
      return 'Berat dan harga jual harus lebih dari 0.';
    }

    final lama = pesanan[index];
    final stokEfektif = lama.kategori == kategori
        ? (stok[kategori] ?? 0) + lama.beratKg
        : (stok[kategori] ?? 0);

    if (beratKg > stokEfektif) {
      return 'Stok tidak mencukupi! Maksimal $kategori: ${stokEfektif.toStringAsFixed(1)} kg.';
    }

    stok[lama.kategori] = double.parse(
      ((stok[lama.kategori] ?? 0) + lama.beratKg).toStringAsFixed(2),
    );
    stok[kategori] = double.parse(
      ((stok[kategori] ?? 0) - beratKg).toStringAsFixed(2),
    );

    final kemasanFinal = jenisKemasan ?? lama.jenisKemasan;
    final kondisiFinal = kondisiOrder ?? lama.kondisiOrder;

    lama.perbaruiData(
      namaRestoranBaru: namaRestoran.trim(),
      noHpBaru: noHp.trim().isEmpty ? '-' : noHp.trim(),
      alamatBaru: alamat.trim().isEmpty ? '-' : alamat.trim(),
      kategoriBaru: kategori,
      beratKgBaru: double.parse(beratKg.toStringAsFixed(2)),
      hargaJualBaru: hargaJualPerKg,
      hargaBeliModalBaru: hargaBeli[kategori] ?? lama.hargaBeliModalPerKg,
      catatanBaru: (catatan != null && catatan.trim().isNotEmpty)
          ? catatan.trim()
          : null,
      kondisiBaru: kondisiFinal,
      kemasanBaru: kemasanFinal,
      biayaKemasanBaru: tarifKemasan[kemasanFinal] ?? 0,
      garansiBaru: kondisiFinal == 'Lobster Hidup',
      metodePembayaranBaru: metodePembayaran,
    );

    notifyListeners();
    return null;
  }

  void hapusPesanan(int id) {
    final index = pesanan.indexWhere((o) => o.id == id);
    if (index == -1) return;

    final target = pesanan[index];
    if (target.statusKirim != 'Selesai') {
      final sekarang = stok[target.kategori] ?? 0;
      stok[target.kategori] =
          double.parse((sekarang + target.beratKg).toStringAsFixed(2));
    }

    pesanan.removeAt(index);
    notifyListeners();
  }

  void ubahStatusKirim(int id, String statusBaru) {
    final index = pesanan.indexWhere((o) => o.id == id);
    if (index != -1) {
      pesanan[index].statusKirim = statusBaru;
      notifyListeners();
    }
  }

  void ubahStatusLunas(int id, bool lunas) {
    final index = pesanan.indexWhere((o) => o.id == id);
    if (index != -1) {
      pesanan[index].isLunas = lunas;
      notifyListeners();
    }
  }

  // =====================================================
  // 5. PENCARIAN, FILTER & ANALITIK KEUNTUNGAN (3 ROLE)
  // =====================================================
  Set<String> get daftarMitraPetaniUnik =>
      pasokan.map((p) => p.namaPetani).toSet();

  Set<String> get daftarMitraRestoranUnik =>
      pesanan.map((o) => o.namaRestoran).toSet();

  List<Pasokan> cariPasokan({
    String kataKunci = '',
    String? filterStatus,
    String? hanyaPetani,
  }) {
    final q = kataKunci.trim().toLowerCase();
    return pasokan.where((p) {
      final cocokPetani = hanyaPetani == null ||
          p.namaPetani.toLowerCase() == hanyaPetani.toLowerCase();
      final cocokTeks = q.isEmpty ||
          p.namaPetani.toLowerCase().contains(q) ||
          p.kategori.toLowerCase().contains(q) ||
          p.lokasiPetani.toLowerCase().contains(q);
      final cocokStatus = filterStatus == null || p.status == filterStatus;
      return cocokPetani && cocokTeks && cocokStatus;
    }).toList();
  }

  List<PesananRestoran> cariPesanan({
    String kataKunci = '',
    String? filterStatus,
    bool hanyaBelumLunas = false,
    String? hanyaRestoran,
  }) {
    final q = kataKunci.trim().toLowerCase();
    return pesanan.where((o) {
      final cocokResto = hanyaRestoran == null ||
          o.namaRestoran.toLowerCase() == hanyaRestoran.toLowerCase();
      final cocokTeks = q.isEmpty ||
          o.namaRestoran.toLowerCase().contains(q) ||
          o.kategori.toLowerCase().contains(q) ||
          o.alamat.toLowerCase().contains(q);
      final cocokStatus =
          filterStatus == null || o.statusKirim == filterStatus;
      final cocokLunas = !hanyaBelumLunas || !o.isLunas;
      return cocokResto && cocokTeks && cocokStatus && cocokLunas;
    }).toList();
  }

  // Ringkasan Stok & Omzet
  double get totalStok => stok.values.fold(0, (a, b) => a + b);

  double get totalNilaiStok {
    double total = 0;
    for (final k in daftarKategori) {
      total += (stok[k] ?? 0) * (hargaBeli[k] ?? 0);
    }
    return total;
  }

  double get totalPembelian => pasokan
      .where((p) => p.status == 'Diterima')
      .fold(0, (sum, p) => sum + p.totalBayar);

  double get totalPenjualan =>
      pesanan.fold(0, (sum, o) => sum + o.totalHarga);

  double get totalModalTerjual =>
      pesanan.fold(0, (sum, o) => sum + o.modalProduk);

  /// Keuntungan (Laba Kotor Penjualan berbasis HPP per order terjual)
  double get labaKotorPenjualan =>
      pesanan.fold(0, (sum, o) => sum + o.labaOrder);

  /// Laba yang sudah benar-benar masuk kas (dari order berstatus Lunas)
  double get labaTerealisasi => pesanan
      .where((o) => o.isLunas)
      .fold(0, (sum, o) => sum + o.labaOrder);

  /// Potensi laba yang masih tertahan di tagihan Tempo/COD
  double get potensiLabaTempo => pesanan
      .where((o) => !o.isLunas)
      .fold(0, (sum, o) => sum + o.labaOrder);

  /// Persentase rata-rata margin keuntungan dari omzet produk
  double get persenMarginLaba {
    final omzetProduk = pesanan.fold(0.0, (s, o) => s + o.subtotalProduk);
    if (omzetProduk <= 0) return 0;
    return (labaKotorPenjualan / omzetProduk) * 100;
  }

  /// Kewajiban pencairan dana ke petani (sudah diterima gudang tapi belum dicairkan)
  double get totalKewajibanPetani => pasokan
      .where((p) => p.status == 'Diterima' && !p.danaDicairkan)
      .fold(0, (sum, p) => sum + p.totalBayar);

  int get jumlahMenungguCairPetani =>
      pasokan.where((p) => p.status == 'Diterima' && !p.danaDicairkan).length;

  double get estimasiMargin => labaKotorPenjualan;

  int get jumlahMenunggu =>
      pasokan.where((p) => p.status == 'Menunggu').length;

  int get jumlahPesananAktif =>
      pesanan.where((o) => o.statusKirim != 'Selesai').length;

  Map<String, double> get analitikStokPerKategori {
    return {for (final k in daftarKategori) k: stok[k] ?? 0};
  }

  List<String> get kategoriStokMenipis =>
      daftarKategori.where((k) => (stok[k] ?? 0) <= 8.0).toList();

  double get totalPiutangTempo => pesanan
      .where((o) => !o.isLunas)
      .fold(0, (sum, o) => sum + o.totalHarga);

  int get jumlahOrderTempo => pesanan.where((o) => !o.isLunas).length;

  double get rasioPelunasan {
    if (totalPenjualan <= 0) return 1.0;
    final sudahLunas = totalPenjualan - totalPiutangTempo;
    return (sudahLunas / totalPenjualan).clamp(0.0, 1.0);
  }

  Map<String, dynamic> analitikPetani(String namaPetani) {
    final milik = cariPasokan(hanyaPetani: namaPetani);
    final diterima = milik.where((p) => p.status == 'Diterima').toList();
    final menunggu = milik.where((p) => p.status == 'Menunggu').toList();

    final double totalKgDiterima =
        diterima.fold(0, (sum, p) => sum + p.beratDiterima);
    final double totalPendapatan =
        diterima.fold(0, (sum, p) => sum + p.totalBayar);
    final double danaSudahCair = diterima
        .where((p) => p.danaDicairkan)
        .fold(0, (sum, p) => sum + p.totalBayar);
    final double danaMenungguCair = diterima
        .where((p) => !p.danaDicairkan)
        .fold(0, (sum, p) => sum + p.totalBayar);

    final Map<String, double> perKategori = {
      for (final k in daftarKategori) k: 0,
    };
    for (final p in diterima) {
      perKategori[p.kategori] = (perKategori[p.kategori] ?? 0) + p.beratDiterima;
    }

    return {
      'totalSetoran': milik.length,
      'jumlahDiterima': diterima.length,
      'jumlahMenunggu': menunggu.length,
      'totalKgDiterima': totalKgDiterima,
      'totalPendapatan': totalPendapatan,
      'danaSudahCair': danaSudahCair,
      'danaMenungguCair': danaMenungguCair,
      'perKategori': perKategori,
    };
  }

  double kualitasLolosSortirPetani(String namaPetani) {
    final diterima = cariPasokan(hanyaPetani: namaPetani)
        .where((p) => p.status == 'Diterima')
        .toList();
    if (diterima.isEmpty) return 100.0;
    final totalDiajukan = diterima.fold(0.0, (s, p) => s + p.jumlah);
    final totalDiterima = diterima.fold(0.0, (s, p) => s + p.beratDiterima);
    if (totalDiajukan <= 0) return 100.0;
    return ((totalDiterima / totalDiajukan) * 100).clamp(0.0, 100.0);
  }

  double estimasiPendingPetani(String namaPetani) {
    return cariPasokan(hanyaPetani: namaPetani)
        .where((p) => p.status == 'Menunggu')
        .fold(0.0, (s, p) => s + (p.jumlah * (hargaBeli[p.kategori] ?? 0)));
  }

  Map<String, dynamic> analitikRestoran(String namaRestoran) {
    final milik = cariPesanan(hanyaRestoran: namaRestoran);
    final aktif = milik.where((o) => o.statusKirim != 'Selesai').toList();
    final selesai = milik.where((o) => o.statusKirim == 'Selesai').toList();
    final tempo = milik.where((o) => !o.isLunas).toList();

    final double totalBelanja =
        milik.fold(0, (sum, o) => sum + o.totalHarga);
    final double totalKg = milik.fold(0, (sum, o) => sum + o.beratKg);
    final double totalTempo =
        tempo.fold(0, (sum, o) => sum + o.totalHarga);

    final Map<String, double> perKategori = {
      for (final k in daftarKategori) k: 0,
    };
    for (final o in milik) {
      perKategori[o.kategori] = (perKategori[o.kategori] ?? 0) + o.beratKg;
    }

    return {
      'totalOrder': milik.length,
      'jumlahAktif': aktif.length,
      'jumlahSelesai': selesai.length,
      'totalBelanja': totalBelanja,
      'totalKg': totalKg,
      'totalTempo': totalTempo,
      'perKategori': perKategori,
    };
  }

  PesananRestoran? pesananAktifTerbaruResto(String namaRestoran) {
    for (final o in cariPesanan(hanyaRestoran: namaRestoran)) {
      if (o.statusKirim != 'Selesai') return o;
    }
    return null;
  }

  PesananRestoran? pesananTerakhirResto(String namaRestoran) {
    final daftar = cariPesanan(hanyaRestoran: namaRestoran);
    return daftar.isEmpty ? null : daftar.first;
  }

  // =====================================================
  // 6. FORMATTER & NOTA WHATSAPP
  // =====================================================
  String buatNotaPasokan(Pasokan p) {
    final infoCatatan = (p.catatan != null && p.catatan!.trim().isNotEmpty)
        ? p.catatan!
        : 'Tidak ada catatan';
    final beratTampil = p.status == 'Diterima' ? p.beratDiterima : p.jumlah;
    final infoWadah =
        p.siapkanWadah ? (p.jenisWadah ?? 'Disiapkan') : 'Dibawa kurir gudang';
    final jarak = jarakDariGudang(p.latitude, p.longitude).toStringAsFixed(1);
    final statusDana = p.status != 'Diterima'
        ? '-'
        : (p.danaDicairkan ? 'SUDAH DICAIRKAN' : 'MENUNGGU PENCAIRAN');

    return '''
=== NOTA SETORAN SAUNG LOBSTER ===
ID Setoran   : #PSK-${p.id}
Tanggal      : ${p.tanggal}
Mitra Panen  : ${p.namaPetani}
Lokasi       : ${p.lokasiPetani} (~$jarak km)
----------------------------------
Ukuran       : ${p.kategori}
Kondisi      : ${p.kondisi}
Wadah Panen  : $infoWadah
Berat        : ${beratTampil.toStringAsFixed(1)} kg
Harga / kg   : ${formatRupiah(p.hargaBeliSaatTerima)}
Total Bayar  : ${formatRupiah(p.totalBayar)}
----------------------------------
Pencairan    : ${p.metodePencairan}
Tujuan Dana  : ${p.rekeningTujuan ?? '-'}
Status Dana  : $statusDana
Catatan      : $infoCatatan
''';
  }

  String buatNotaPesanan(PesananRestoran o) {
    final infoCatatan = (o.catatan != null && o.catatan!.trim().isNotEmpty)
        ? o.catatan!
        : 'Tidak ada catatan';
    final statusBayar = o.isLunas ? 'LUNAS' : 'BELUM LUNAS / TEMPO';
    final infoKemasan = o.biayaKemasan <= 0
        ? '${o.jenisKemasan} (GRATIS)'
        : '${o.jenisKemasan} (${formatRupiah(o.biayaKemasan)})';
    final infoGaransi = o.garansiHidup
        ? 'Garansi 100% Lobster Hidup sampai tujuan'
        : 'Standar Segar Dingin';

    return '''
=== INVOICE SAUNG LOBSTER ===
No. Order    : #ORD-${o.id}
Tanggal      : ${o.tanggal}
Pelanggan    : ${o.namaRestoran}
Alamat       : ${o.alamat}
-----------------------------
Produk       : ${o.kategori} (${o.kondisiOrder})
Berat        : ${o.beratKg.toStringAsFixed(1)} kg
Harga / kg   : ${formatRupiah(o.hargaJualPerKg)}
Subtotal     : ${formatRupiah(o.subtotalProduk)}
Kemasan      : $infoKemasan
Jaminan      : $infoGaransi
Total Tagihan: ${formatRupiah(o.totalHarga)}
-----------------------------
Pembayaran   : ${o.metodePembayaran} ($statusBayar)
Status Kirim : ${o.statusKirim.toUpperCase()}
Catatan      : $infoCatatan
''';
  }

  static String formatRupiah(double angka) {
    final negatif = angka < 0;
    final nilai = angka.abs().toStringAsFixed(0);
    final hasil = nilai.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '${negatif ? '-' : ''}Rp$hasil';
  }
}