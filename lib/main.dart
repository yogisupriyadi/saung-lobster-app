
import 'package:flutter/material.dart';

void main() {
  runApp(const SaungLobsterApp());
}

const merah = Color(0xFFD62828);
const latar = Color(0xFFFFF9F5);
const hijau = Color(0xFF238653);

const kategoriLobster = [
  'Lobster Bibit',
  'Lobster 4 Inch',
  'Lobster 5 Inch',
];

// =====================================================
// MODEL DATA
// =====================================================

class Pasokan {
  final int id;
  final String namaPetani;
  final String kategori;
  final double jumlah;
  final String kondisi;
  final String tanggal;
  String status;
  double beratDiterima;

  Pasokan({
    required this.id,
    required this.namaPetani,
    required this.kategori,
    required this.jumlah,
    required this.kondisi,
    required this.tanggal,
    this.status = 'Menunggu',
    this.beratDiterima = 0,
  });
}

// =====================================================
// PENYIMPANAN DATA SEMENTARA
// =====================================================

class DataSaungLobster extends ChangeNotifier {
  static final DataSaungLobster instance = DataSaungLobster._();

  DataSaungLobster._();

  final List<Pasokan> pasokan = [];

  final Map<String, double> hargaBeli = {
    'Lobster Bibit': 0,
    'Lobster 4 Inch': 0,
    'Lobster 5 Inch': 0,
  };

  final Map<String, double> hargaJual = {
    'Lobster Bibit': 0,
    'Lobster 4 Inch': 0,
    'Lobster 5 Inch': 0,
  };

  final Map<String, double> stok = {
    'Lobster Bibit': 0,
    'Lobster 4 Inch': 0,
    'Lobster 5 Inch': 0,
  };

  final List<String> namaPetani = [];

  void tambahPasokan(Pasokan data) {
    pasokan.add(data);

    if (!namaPetani.contains(data.namaPetani)) {
      namaPetani.add(data.namaPetani);
    }

    notifyListeners();
  }

  void ubahHarga(
      String kategori,
      double beli,
      double jual,
      ) {
    hargaBeli[kategori] = beli;
    hargaJual[kategori] = jual;
    notifyListeners();
  }

  void terimaPasokan(Pasokan data, double berat) {
    if (data.status != 'Menunggu' || berat <= 0) return;

    data.beratDiterima = berat;
    data.status = 'Diterima';

    stok[data.kategori] =
        (stok[data.kategori] ?? 0) + berat;

    notifyListeners();
  }

  void tolakPasokan(Pasokan data) {
    if (data.status != 'Menunggu') return;

    data.status = 'Ditolak';
    notifyListeners();
  }

  double get totalStok =>
      stok.values.fold(0, (a, b) => a + b);

  double get totalNilaiStok {
    double total = 0;

    for (final kategori in kategoriLobster) {
      total += (stok[kategori] ?? 0) *
          (hargaBeli[kategori] ?? 0);
    }

    return total;
  }

  int get jumlahMenunggu =>
      pasokan.where((p) => p.status == 'Menunggu').length;
}

// =====================================================
// APLIKASI UTAMA
// =====================================================

class SaungLobsterApp extends StatelessWidget {
  const SaungLobsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaungLobster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: merah),
        scaffoldBackgroundColor: latar,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: latar,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// =====================================================
// LOGIN
// =====================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String peran = 'Admin';

  final email = TextEditingController();
  final password = TextEditingController();

  bool tampilPassword = false;

  void masuk() {
    final admin = peran == 'Admin' &&
        email.text.trim() == 'admin@saunglobster.com' &&
        password.text == 'admin123';

    final petani = peran == 'Petani' &&
        email.text.trim() == 'petani@saunglobster.com' &&
        password.text == 'petani123';

    if (admin || petani) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(peran: peran),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password tidak sesuai.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: merah, width: 2),
                  ),
                  child: const Icon(
                    Icons.cruelty_free,
                    color: merah,
                    size: 75,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'SAUNG LOBSTER',
                  style: TextStyle(
                    color: merah,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Supplier Lobster Air Tawar',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 38),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Silakan masuk ke akun Anda.'),
                ),
                const SizedBox(height: 25),

                DropdownButtonFormField<String>(
                  value: peran,
                  decoration: const InputDecoration(
                    labelText: 'Masuk sebagai',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Admin', 'Petani'].map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      peran = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: password,
                  obscureText: !tampilPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          tampilPassword = !tampilPassword;
                        });
                      },
                      icon: Icon(
                        tampilPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: masuk,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: merah,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'MASUK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SaungLobster • EST 2021',
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// DASHBOARD UTAMA
// =====================================================

class DashboardPage extends StatefulWidget {
  final String peran;

  const DashboardPage({super.key, required this.peran});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int halaman = 0;

  bool get admin => widget.peran == 'Admin';

  final judulAdmin = [
    'Dashboard',
    'Penerimaan Pasokan',
    'Pengaturan Harga',
    'Manajemen Stok',
    'Pesanan Restoran',
  ];

  final judulPetani = [
    'Dashboard Petani',
    'Ajukan Pasokan',
    'Riwayat Pasokan',
    'Profil Petani',
  ];

  @override
  Widget build(BuildContext context) {
    final judul = admin ? judulAdmin : judulPetani;

    final halamanAdmin = [
      const BerandaAdmin(),
      const PenerimaanPage(),
      const HargaPage(),
      const StokPage(),
      const PesananPage(),
    ];

    final halamanPetani = [
      const BerandaPetani(),
      const FormPasokanPage(),
      const RiwayatPetaniPage(),
      const ProfilPetaniPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          judul[halaman],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: merah),
          ),
        ],
      ),
      body: IndexedStack(
        index: halaman,
        children: admin ? halamanAdmin : halamanPetani,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: halaman,
        onDestinationSelected: (index) {
          setState(() {
            halaman = index;
          });
        },
        destinations: admin
            ? const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            label: 'Pasokan',
          ),
          NavigationDestination(
            icon: Icon(Icons.price_change_outlined),
            label: 'Harga',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            label: 'Stok',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Pesanan',
          ),
        ]
            : const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'Ajukan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// KOMPONEN BANTUAN
// =====================================================

Widget kartuMenu({
  required IconData ikon,
  required String judul,
  required String keterangan,
  Color warna = merah,
}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFFFE0D8)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: warna.withOpacity(0.10),
          child: Icon(ikon, color: warna),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                keterangan,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget judulBagian(String teks) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(
      teks,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String rupiah(double angka) {
  final nilai = angka.toStringAsFixed(0);
  final hasil = nilai.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
  );
  return 'Rp$hasil';
}

// =====================================================
// BERANDA ADMIN
// =====================================================

class BerandaAdmin extends StatelessWidget {
  const BerandaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: merah,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SAUNG LOBSTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pusat pengelolaan supplier lobster air tawar.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Icon(
                    Icons.cruelty_free,
                    size: 48,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            judulBagian('Ringkasan Usaha'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _kartuAngka(
                  'Total Stok',
                  '${data.totalStok.toStringAsFixed(1)} kg',
                  Icons.warehouse,
                  hijau,
                ),
                _kartuAngka(
                  'Menunggu',
                  '${data.jumlahMenunggu}',
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _kartuAngka(
                  'Mitra Petani',
                  '${data.namaPetani.length}',
                  Icons.people,
                  Colors.blue,
                ),
                _kartuAngka(
                  'Nilai Stok',
                  rupiah(data.totalNilaiStok),
                  Icons.payments,
                  merah,
                ),
              ],
            ),
            const SizedBox(height: 20),
            judulBagian('Alur Operasional'),
            kartuMenu(
              ikon: Icons.spa,
              judul: 'Penerimaan dari Petani',
              keterangan: 'Periksa dan setujui pasokan lobster.',
            ),
            const SizedBox(height: 10),
            kartuMenu(
              ikon: Icons.price_change,
              judul: 'Pengaturan Harga',
              keterangan: 'Tentukan harga beli dan harga jual.',
            ),
            const SizedBox(height: 10),
            kartuMenu(
              ikon: Icons.restaurant,
              judul: 'Distribusi Restoran',
              keterangan: 'Kelola pesanan dan pengiriman.',
            ),
          ],
        );
      },
    );
  }

  Widget _kartuAngka(
      String judul,
      String angka,
      IconData ikon,
      Color warna,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: warna, size: 27),
          const SizedBox(height: 8),
          Text(
            angka,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            judul,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// BERANDA PETANI
// =====================================================

class BerandaPetani extends StatelessWidget {
  const BerandaPetani({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: merah,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, Mitra Petani!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pasok lobster air tawar Anda ke SaungLobster.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            judulBagian('Informasi Pasokan'),
            kartuMenu(
              ikon: Icons.pending_actions,
              judul: 'Pengajuan Menunggu',
              keterangan:
              '${data.pasokan.where((p) => p.status == 'Menunggu').length} pengajuan sedang diperiksa.',
              warna: Colors.orange,
            ),
            const SizedBox(height: 10),
            kartuMenu(
              ikon: Icons.check_circle_outline,
              judul: 'Pasokan Diterima',
              keterangan:
              '${data.pasokan.where((p) => p.status == 'Diterima').length} pengajuan telah diterima.',
              warna: hijau,
            ),
            const SizedBox(height: 10),
            kartuMenu(
              ikon: Icons.history,
              judul: 'Total Pengajuan',
              keterangan: '${data.pasokan.length} pengajuan tercatat.',
              warna: Colors.blue,
            ),
            const SizedBox(height: 22),
            const Text(
              'Informasi Harga',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Harga pembelian ditentukan oleh Admin SaungLobster setelah pemeriksaan pasokan.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// FORM PENGAJUAN PASOKAN PETANI
// =====================================================

class FormPasokanPage extends StatefulWidget {
  const FormPasokanPage({super.key});

  @override
  State<FormPasokanPage> createState() => _FormPasokanPageState();
}

class _FormPasokanPageState extends State<FormPasokanPage> {
  final nama = TextEditingController();
  final jumlah = TextEditingController();

  String kategori = kategoriLobster[0];
  String kondisi = 'Segar / Hidup';

  @override
  void dispose() {
    nama.dispose();
    jumlah.dispose();
    super.dispose();
  }

  void kirim() {
    final berat = double.tryParse(
      jumlah.text.trim().replaceAll(',', '.'),
    );

    if (nama.text.trim().isEmpty ||
        berat == null ||
        berat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama petani dan jumlah kg harus diisi dengan benar.'),
        ),
      );
      return;
    }

    final data = Pasokan(
      id: DateTime.now().microsecondsSinceEpoch,
      namaPetani: nama.text.trim(),
      kategori: kategori,
      jumlah: berat,
      kondisi: kondisi,
      tanggal: DateTime.now().toString().substring(0, 10),
    );

    DataSaungLobster.instance.tambahPasokan(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan berhasil dikirim kepada Admin.'),
      ),
    );

    nama.clear();
    jumlah.clear();

    setState(() {
      kategori = kategoriLobster[0];
      kondisi = 'Segar / Hidup';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Form Pasokan Lobster Air Tawar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Isi data ketersediaan lobster yang ingin dipasok.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: nama,
          decoration: const InputDecoration(
            labelText: 'Nama Petani',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: kategori,
          decoration: const InputDecoration(
            labelText: 'Kategori Lobster',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items: kategoriLobster.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              kategori = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: jumlah,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Jumlah Pasokan (kg)',
            prefixIcon: Icon(Icons.scale_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: kondisi,
          decoration: const InputDecoration(
            labelText: 'Kondisi Lobster',
            prefixIcon: Icon(Icons.water_drop_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            'Segar / Hidup',
            'Dingin',
            'Lainnya',
          ].map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              kondisi = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5DD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: merah),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Harga beli ditentukan oleh Admin. Petani tidak perlu mengisi harga.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: kirim,
            icon: const Icon(Icons.send),
            label: const Text('Kirim Pengajuan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: merah,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// PENERIMAAN DAN VERIFIKASI PASOKAN OLEH ADMIN
// =====================================================

class PenerimaanPage extends StatelessWidget {
  const PenerimaanPage({super.key});

  void periksaPasokan(BuildContext context, Pasokan p) {
    final beratController = TextEditingController(
      text: p.jumlah.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verifikasi Pasokan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Petani: ${p.namaPetani}'),
              Text('Kategori: ${p.kategori}'),
              Text('Diajukan: ${p.jumlah} kg'),
              const SizedBox(height: 15),
              TextField(
                controller: beratController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Berat aktual diterima (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stok akan bertambah sesuai berat aktual yang diterima.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
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

                if (berat == null ||
                    berat <= 0 ||
                    berat > p.jumlah) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Berat harus lebih dari 0 dan tidak melebihi pengajuan.',
                      ),
                    ),
                  );
                  return;
                }

                DataSaungLobster.instance.terimaPasokan(p, berat);
                Navigator.pop(dialogContext);
              },
              child: const Text('Terima Pasokan'),
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
        final daftar = DataSaungLobster.instance.pasokan;

        if (daftar.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                'Belum ada pengajuan pasokan dari petani.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            judulBagian('Daftar Pengajuan Petani'),
            ...daftar.reversed.map((p) {
              final diterima = p.status == 'Diterima';
              final ditolak = p.status == 'Ditolak';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.namaPetani,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Kategori: ${p.kategori}'),
                      Text('Jumlah diajukan: ${p.jumlah} kg'),
                      Text('Kondisi: ${p.kondisi}'),
                      Text('Tanggal: ${p.tanggal}'),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(
                          p.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: diterima
                            ? hijau
                            : ditolak
                            ? Colors.redAccent
                            : Colors.orange,
                      ),
                      if (diterima)
                        Text(
                          'Berat diterima: ${p.beratDiterima} kg',
                        ),
                      if (p.status == 'Menunggu') ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: () => periksaPasokan(context, p),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hijau,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Periksa & Terima'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                DataSaungLobster.instance
                                    .tolakPasokan(p);
                              },
                              child: const Text('Tolak'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
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
// PENGATURAN HARGA ADMIN
// =====================================================

class HargaPage extends StatefulWidget {
  const HargaPage({super.key});

  @override
  State<HargaPage> createState() => _HargaPageState();
}

class _HargaPageState extends State<HargaPage> {
  String kategori = kategoriLobster[0];

  final beliController = TextEditingController();
  final jualController = TextEditingController();

  @override
  void dispose() {
    beliController.dispose();
    jualController.dispose();
    super.dispose();
  }

  void muatHarga() {
    final data = DataSaungLobster.instance;

    beliController.text =
        (data.hargaBeli[kategori] ?? 0).toStringAsFixed(0);

    jualController.text =
        (data.hargaJual[kategori] ?? 0).toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    muatHarga();
  }

  void simpanHarga() {
    final beli = double.tryParse(beliController.text);
    final jual = double.tryParse(jualController.text);

    if (beli == null || jual == null || beli < 0 || jual < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan harga yang benar.'),
        ),
      );
      return;
    }

    DataSaungLobster.instance.ubahHarga(
      kategori,
      beli,
      jual,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Harga berhasil diperbarui.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Pengaturan Harga Produk',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hanya Admin yang dapat menentukan harga beli dan harga jual.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 25),
        DropdownButtonFormField<String>(
          value: kategori,
          decoration: const InputDecoration(
            labelText: 'Kategori Lobster',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items: kategoriLobster.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              kategori = value!;
              muatHarga();
            });
          },
        ),
        const SizedBox(height: 20),
        TextField(
          controller: beliController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga Beli dari Petani (Rp/kg)',
            prefixIcon: Icon(Icons.shopping_basket_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: jualController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga Jual ke Restoran (Rp/kg)',
            prefixIcon: Icon(Icons.storefront_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Semua harga dihitung per kilogram, termasuk lobster bibit.',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: simpanHarga,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Harga'),
            style: ElevatedButton.styleFrom(
              backgroundColor: merah,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 25),
        judulBagian('Daftar Harga SaungLobster'),
        AnimatedBuilder(
          animation: DataSaungLobster.instance,
          builder: (context, _) {
            final data = DataSaungLobster.instance;

            return Column(
              children: kategoriLobster.map((item) {
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Beli: ${rupiah(data.hargaBeli[item]!)} / kg\n'
                          'Jual: ${rupiah(data.hargaJual[item]!)} / kg',
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// =====================================================
// MANAJEMEN STOK
// =====================================================

class StokPage extends StatelessWidget {
  const StokPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final data = DataSaungLobster.instance;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: merah,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Persediaan',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data.totalStok.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            judulBagian('Stok Berdasarkan Ukuran'),
            ...kategoriLobster.map((item) {
              final berat = data.stok[item] ?? 0;

              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE5DD),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: merah,
                    ),
                  ),
                  title: Text(
                    item,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Harga beli: ${rupiah(data.hargaBeli[item]!)} / kg',
                  ),
                  trailing: Text(
                    '${berat.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hijau,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            judulBagian('Nilai Persediaan'),
            Text(
              rupiah(data.totalNilaiStok),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: merah,
              ),
            ),
            const Text(
              'Perkiraan nilai stok berdasarkan harga beli yang ditetapkan Admin.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// DATA PETANI
// =====================================================

class ProfilPetaniPage extends StatelessWidget {
  const ProfilPetaniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFFFE5DD),
          child: Icon(Icons.person, color: merah, size: 55),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Petani Mitra',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Center(
          child: Text(
            'Mitra Pemasok SaungLobster',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        const SizedBox(height: 25),
        kartuMenu(
          ikon: Icons.info_outline,
          judul: 'Status Mitra',
          keterangan: 'Petani pemasok lobster air tawar.',
        ),
        const SizedBox(height: 10),
        kartuMenu(
          ikon: Icons.price_change_outlined,
          judul: 'Kebijakan Harga',
          keterangan: 'Harga ditentukan oleh Admin SaungLobster.',
        ),
      ],
    );
  }
}

// =====================================================
// RIWAYAT PASOKAN PETANI
// =====================================================

class RiwayatPetaniPage extends StatelessWidget {
  const RiwayatPetaniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final daftar = DataSaungLobster.instance.pasokan;

        if (daftar.isEmpty) {
          return const Center(
            child: Text('Belum ada riwayat pengajuan pasokan.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            judulBagian('Riwayat Pasokan'),
            ...daftar.reversed.map((p) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    p.kategori,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${p.jumlah} kg • ${p.tanggal}\n'
                        'Kondisi: ${p.kondisi}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(p.status),
                    backgroundColor: p.status == 'Diterima'
                        ? Colors.green.shade100
                        : p.status == 'Ditolak'
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                  ),
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
// PESANAN RESTORAN
// =====================================================

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.restaurant,
          color: merah,
          size: 65,
        ),
        const SizedBox(height: 15),
        const Text(
          'Pesanan Restoran',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Halaman ini disiapkan untuk pengelolaan pesanan restoran, jumlah lobster, harga jual, pembayaran, dan jadwal pengiriman.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 25),
        kartuMenu(
          ikon: Icons.storefront,
          judul: 'Data Restoran',
          keterangan: 'Data pelanggan restoran akan dikembangkan.',
        ),
        const SizedBox(height: 12),
        kartuMenu(
          ikon: Icons.local_shipping,
          judul: 'Pengiriman',
          keterangan: 'Pencatatan jadwal dan status pengiriman.',
        ),
      ],
    );
  }
}
