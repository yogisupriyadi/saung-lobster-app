class AkunPengguna {
  final String id;
  String nama;
  String username;
  final String email;
  String password;
  final String peran; // role
  String noHp;
  String alamat;
  String? photoUrl;
  int avatarColorIndex;
  String titikLokasi;
  double latitude;
  double longitude;

  AkunPengguna({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.password,
    required this.peran,
    required this.noHp,
    required this.alamat,
    this.photoUrl,
    this.avatarColorIndex = 0,
    this.titikLokasi = 'Bandung, Jawa Barat',
    this.latitude = -6.9175,
    this.longitude = 107.6191,
  });

  String get inisial {
    final bagian = nama.trim().split(RegExp(r'\s+'));
    if (bagian.isEmpty || bagian.first.isEmpty) return 'SL';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian[0][0] + bagian[1][0]).toUpperCase();
  }

  void perbaruiProfil({
    required String namaBaru,
    required String usernameBaru,
    required String noHpBaru,
    required String alamatBaru,
    required String titikLokasiBaru,
    required double latBaru,
    required double lngBaru,
    required int avatarColorBaru,
    String? photoUrlBaru,
    String? passwordBaru,
  }) {
    nama = namaBaru;
    username = usernameBaru;
    noHp = noHpBaru;
    alamat = alamatBaru;
    titikLokasi = titikLokasiBaru;
    latitude = latBaru;
    longitude = lngBaru;
    avatarColorIndex = avatarColorBaru;
    photoUrl = (photoUrlBaru != null && photoUrlBaru.trim().isNotEmpty)
        ? photoUrlBaru.trim()
        : null;
    if (passwordBaru != null && passwordBaru.trim().isNotEmpty) {
      password = passwordBaru.trim();
    }
  }
}