import 'package:flutter/material.dart';
import '../state/data_saung_lobster.dart';
import '../widgets/komponen_ui.dart';
import 'admin_pages.dart';
import 'petani_pages.dart';
import 'profil_page.dart';
import 'restoran_pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _pageController;
  int _halaman = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _pindahHalaman(int index) {
    if (_halaman == index) return;
    setState(() => _halaman = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final akun = DataSaungLobster.instance.akunAktif;
        final peran = akun?.peran ?? 'Admin';

        final List<String> judul;
        final List<Widget> daftarHalaman;
        final List<GlassNavItem> navItems;
        final IconData actionIcon;
        final String actionTooltip;
        final List<GlassQuickAction> quickActions;

        if (peran == 'Admin') {
          judul = const [
            'SaungLobster',
            'Penerimaan Panen',
            'Stok & Harga',
            'Pesanan',
          ];
          daftarHalaman = [
            BerandaAdmin(onPindahTab: _pindahHalaman),
            const PenerimaanPage(),
            const KatalogAdminPage(),
            const PesananPage(),
          ];
          navItems = const [
            GlassNavItem(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view_rounded,
              label: 'Beranda',
            ),
            GlassNavItem(
              icon: Icons.move_to_inbox_outlined,
              selectedIcon: Icons.move_to_inbox_rounded,
              label: 'Panen',
            ),
            GlassNavItem(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2_rounded,
              label: 'Katalog',
            ),
            GlassNavItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              label: 'Order',
            ),
          ];
          actionIcon = Icons.add_rounded;
          actionTooltip = 'Aksi Cepat';
          quickActions = [
            GlassQuickAction(
              icon: Icons.receipt_long_rounded,
              label: 'Catat Order',
              onTap: () => bukaFormPesananAdmin(context),
            ),
            GlassQuickAction(
              icon: Icons.add_box_rounded,
              label: 'Tambah Stok',
              onTap: () => bukaDialogKategoriAdmin(context),
            ),
            GlassQuickAction(
              icon: Icons.person_pin_circle_rounded,
              label: 'Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilPenggunaPage(tampilAppBar: true),
                  ),
                );
              },
            ),
          ];
        } else if (peran == 'Petani') {
          judul = const [
            'Mitra Panen',
            'Riwayat Setoran',
            'Profil Mitra',
          ];
          daftarHalaman = const [
            BerandaPetani(),
            RiwayatPetaniPage(),
            ProfilPenggunaPage(),
          ];
          navItems = const [
            GlassNavItem(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics_rounded,
              label: 'Analitik',
            ),
            GlassNavItem(
              icon: Icons.history_rounded,
              selectedIcon: Icons.history_rounded,
              label: 'Riwayat',
            ),
            GlassNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ];
          actionIcon = Icons.add_rounded;
          actionTooltip = 'Aksi Mitra';
          quickActions = [
            GlassQuickAction(
              icon: Icons.send_rounded,
              label: 'Setor Panen',
              onTap: () => bukaFormSetorPanen(context),
            ),
            GlassQuickAction(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              onTap: () => _pindahHalaman(1),
            ),
            GlassQuickAction(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              onTap: () => _pindahHalaman(2),
            ),
          ];
        } else {
          judul = const [
            'SaungLobster',
            'Flash Stock',
            'Pesanan Saya',
            'Profil Akun',
          ];
          daftarHalaman = [
            BerandaRestoranPage(onPindahTab: _pindahHalaman),
            const KatalogRestoranPage(),
            const PesananRestoranSayaPage(),
            const ProfilPenggunaPage(),
          ];
          navItems = const [
            GlassNavItem(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics_rounded,
              label: 'Analitik',
            ),
            GlassNavItem(
              icon: Icons.flash_on_outlined,
              selectedIcon: Icons.flash_on_rounded,
              label: 'Katalog',
            ),
            GlassNavItem(
              icon: Icons.shopping_bag_outlined,
              selectedIcon: Icons.shopping_bag_rounded,
              label: 'Pesanan',
            ),
            GlassNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ];
          actionIcon = Icons.shopping_cart_checkout_rounded;
          actionTooltip = 'Checkout Cepat';
          quickActions = [
            GlassQuickAction(
              icon: Icons.add_shopping_cart_rounded,
              label: 'Checkout',
              onTap: () => bukaCheckoutRestoran(context),
            ),
            GlassQuickAction(
              icon: Icons.flash_on_rounded,
              label: 'Flash Stock',
              onTap: () => _pindahHalaman(1),
            ),
            GlassQuickAction(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              onTap: () => _pindahHalaman(3),
            ),
          ];
        }

        final safeIndex = _halaman >= daftarHalaman.length ? 0 : _halaman;

        return Stack(
          children: [
            Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  judul[safeIndex],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                actions: [
                  const ThemeToggleButton(size: 34),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GlassAvatar(
                      akun: akun,
                      radius: 18,
                      onTap: () {
                        if (peran == 'Admin') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProfilPenggunaPage(tampilAppBar: true),
                            ),
                          );
                        } else {
                          _pindahHalaman(daftarHalaman.length - 1);
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: LiquidBackground(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: topPad),
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() => _halaman = index);
                        },
                        children: daftarHalaman,
                      ),
                    ),
                    TopHeaderFade(height: topPad),
                  ],
                ),
              ),
            ),

            // Navigasi Split Glass + Speed Dial Vertikal + Full-Screen Blur
            Positioned.fill(
              child: LiquidGlassNavOverlay(
                pageController: _pageController,
                selectedIndex: safeIndex,
                items: navItems,
                onTap: _pindahHalaman,
                actionIcon: actionIcon,
                actionTooltip: actionTooltip,
                quickActions: quickActions,
              ),
            ),
          ],
        );
      },
    );
  }
}