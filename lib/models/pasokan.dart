class Pasokan {
  final int id;
  String namaPetani;
  String kategori;
  double jumlah;
  String kondisi;
  final String tanggal;
  String status; // 'Menunggu', 'Diterima', 'Ditolak'
  double beratDiterima;
  double hargaBeliSaatTerima;
  String? catatan;
  String? fotoProdukUrl;
  bool siapkanWadah;
  String? jenisWadah; // 'Kardus', 'Boks Styrofoam', 'Keranjang Plastik'
  String lokasiPetani;
  double latitude;
  double longitude;
  String metodePencairan; // 'Transfer Bank', 'E-Wallet (DANA/GoPay)', 'Tunai di Lokasi'
  String? rekeningTujuan;
  bool danaDicairkan;

  Pasokan({
    required this.id,
    required this.namaPetani,
    required this.kategori,
    required this.jumlah,
    required this.kondisi,
    required this.tanggal,
    this.status = 'Menunggu',
    this.beratDiterima = 0,
    this.hargaBeliSaatTerima = 0,
    this.catatan,
    this.fotoProdukUrl,
    this.siapkanWadah = false,
    this.jenisWadah,
    this.lokasiPetani = 'Kota Baru Parahyangan, Padalarang',
    this.latitude = -6.8542,
    this.longitude = 107.4685,
    this.metodePencairan = 'Transfer Bank',
    this.rekeningTujuan,
    this.danaDicairkan = false,
  });

  double get totalBayar => beratDiterima * hargaBeliSaatTerima;

  void perbaruiData({
    required String namaPetaniBaru,
    required String kategoriBaru,
    required double jumlahBaru,
    required String kondisiBaru,
    String? catatanBaru,
    String? fotoBaru,
    bool? siapkanWadahBaru,
    String? jenisWadahBaru,
    String? metodePencairanBaru,
    String? rekeningTujuanBaru,
  }) {
    namaPetani = namaPetaniBaru;
    kategori = kategoriBaru;
    jumlah = jumlahBaru;
    kondisi = kondisiBaru;
    catatan = catatanBaru;
    fotoProdukUrl = (fotoBaru != null && fotoBaru.trim().isNotEmpty)
        ? fotoBaru.trim()
        : null;
    if (siapkanWadahBaru != null) {
      siapkanWadah = siapkanWadahBaru;
      jenisWadah = siapkanWadahBaru ? jenisWadahBaru : null;
    }
    if (metodePencairanBaru != null) {
      metodePencairan = metodePencairanBaru;
    }
    if (rekeningTujuanBaru != null) {
      rekeningTujuan = rekeningTujuanBaru.trim().isEmpty
          ? null
          : rekeningTujuanBaru.trim();
    }
  }
}