class PesananRestoran {
  final int id;
  String namaRestoran;
  String noHp;
  String alamat;
  String kategori;
  double beratKg;
  double hargaJualPerKg;
  double hargaBeliModalPerKg; // HPP saat order dibuat untuk hitung laba akurat
  final String tanggal;
  String statusKirim; // 'Disortir', 'Dikirim', 'Selesai'
  bool isLunas;
  String? catatan;
  String kondisiOrder; // 'Lobster Hidup' atau 'Segar Dingin'
  String jenisKemasan; // 'Kardus', 'Boks Styrofoam', 'Keranjang Plastik'
  double biayaKemasan;
  bool garansiHidup;
  String metodePembayaran; // 'Transfer Bank', 'QRIS', 'COD (Tunai)', 'Tempo 7 Hari'
  double latitude;
  double longitude;

  PesananRestoran({
    required this.id,
    required this.namaRestoran,
    required this.noHp,
    required this.alamat,
    required this.kategori,
    required this.beratKg,
    required this.hargaJualPerKg,
    this.hargaBeliModalPerKg = 0,
    required this.tanggal,
    this.statusKirim = 'Disortir',
    this.isLunas = false,
    this.catatan,
    this.kondisiOrder = 'Lobster Hidup',
    this.jenisKemasan = 'Kardus',
    this.biayaKemasan = 0,
    this.garansiHidup = true,
    this.metodePembayaran = 'Transfer Bank',
    this.latitude = -6.8588,
    this.longitude = 107.4792,
  });

  double get subtotalProduk => beratKg * hargaJualPerKg;

  double get modalProduk => beratKg * hargaBeliModalPerKg;

  /// Keuntungan (margin jual - modal HPP) dari produk terjual
  double get labaOrder => subtotalProduk - modalProduk;

  double get totalHarga => subtotalProduk + biayaKemasan;

  void perbaruiData({
    required String namaRestoranBaru,
    required String noHpBaru,
    required String alamatBaru,
    required String kategoriBaru,
    required double beratKgBaru,
    required double hargaJualBaru,
    double? hargaBeliModalBaru,
    String? catatanBaru,
    String? kondisiBaru,
    String? kemasanBaru,
    double? biayaKemasanBaru,
    bool? garansiBaru,
    String? metodePembayaranBaru,
  }) {
    namaRestoran = namaRestoranBaru;
    noHp = noHpBaru;
    alamat = alamatBaru;
    kategori = kategoriBaru;
    beratKg = beratKgBaru;
    hargaJualPerKg = hargaJualBaru;
    if (hargaBeliModalBaru != null) hargaBeliModalPerKg = hargaBeliModalBaru;
    catatan = catatanBaru;
    if (kondisiBaru != null) kondisiOrder = kondisiBaru;
    if (kemasanBaru != null) jenisKemasan = kemasanBaru;
    if (biayaKemasanBaru != null) biayaKemasan = biayaKemasanBaru;
    if (garansiBaru != null) garansiHidup = garansiBaru;
    if (metodePembayaranBaru != null) metodePembayaran = metodePembayaranBaru;
  }
}