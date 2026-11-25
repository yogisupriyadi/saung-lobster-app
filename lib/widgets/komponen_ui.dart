import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/akun_pengguna.dart';
import '../state/data_saung_lobster.dart';

const merah = Color(0xFFE63946);
const merahTua = Color(0xFF9E1B24);
const latarGelap = Color(0xFF0B0507);
const latarTerang = Color(0xFFFFF5F6);
const hijau = Color(0xFF22B573);
const emas = Color(0xFFF4A216);

const List<List<Color>> presetWarnaAvatar = [
  [Color(0xFFE63946), Color(0xFF8B1520)],
  [Color(0xFF22B573), Color(0xFF136F4A)],
  [Color(0xFFFF7B54), Color(0xFFB83B24)],
  [Color(0xFF3A86FF), Color(0xFF1D4E89)],
  [Color(0xFF9D4EDD), Color(0xFF5A189A)],
];

// Helper warna adaptif Gelap / Terang
bool isTemaGelap(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color warnaTeksUtama(BuildContext context) =>
    isTemaGelap(context) ? Colors.white : const Color(0xFF1F1215);

Color warnaTeksSekunder(BuildContext context) =>
    isTemaGelap(context) ? Colors.white70 : const Color(0xFF6B4F55);

Color warnaModalSheet(BuildContext context) =>
    isTemaGelap(context) ? const Color(0xFF190B0E) : const Color(0xFFFFF8F9);

Color warnaDropdownMenu(BuildContext context) =>
    isTemaGelap(context) ? const Color(0xFF230E12) : Colors.white;

/// Latar belakang adaptif Liquid Crimson (Dark & Light Mode)
class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = isTemaGelap(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xFF19070B),
                  Color(0xFF0C0507),
                  Color(0xFF1A080C),
                ]
              : const [
                  Color(0xFFFFF1F2),
                  Color(0xFFFFFBFB),
                  Color(0xFFFFECEF),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _bolaCahaya(
              270,
              const Color(0xFFFF4D5A).withValues(alpha: dark ? 0.38 : 0.24),
            ),
          ),
          Positioned(
            top: 290,
            left: -95,
            child: _bolaCahaya(
              250,
              const Color(0xFFD62828).withValues(alpha: dark ? 0.26 : 0.16),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: _bolaCahaya(
              240,
              const Color(0xFFFF758F).withValues(alpha: dark ? 0.22 : 0.22),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _bolaCahaya(double ukuran, Color warnaPusat) {
    return IgnorePointer(
      child: Container(
        width: ukuran,
        height: ukuran,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [warnaPusat, warnaPusat.withValues(alpha: 0.0)],
            stops: const [0.1, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Efek buram memudar natural di bagian atas layar (di balik AppBar seperti video referensi)
class TopHeaderFade extends StatelessWidget {
  final double height;

  const TopHeaderFade({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final dark = isTemaGelap(context);
    final base = dark ? const Color(0xFF0D0507) : const Color(0xFFFFF4F5);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height + 18,
      child: IgnorePointer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    base.withValues(alpha: 0.92),
                    base.withValues(alpha: 0.64),
                    base.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu Liquid Glass adaptif untuk Mode Gelap dan Mode Terang
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 22,
    this.blur = 16,
    this.tintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isTemaGelap(context);
    final radius = BorderRadius.circular(borderRadius);

    final List<Color> gradColors;
    final Color borderColor;
    final Color shadowColor;

    if (tintColor != null) {
      gradColors = dark
          ? [
              tintColor!.withValues(alpha: 0.34),
              tintColor!.withValues(alpha: 0.14),
            ]
          : [
              tintColor!.withValues(alpha: 0.88),
              Color.lerp(tintColor!, merahTua, 0.35)!.withValues(alpha: 0.82),
            ];
      borderColor = Colors.white.withValues(alpha: dark ? 0.24 : 0.45);
      shadowColor = tintColor!.withValues(alpha: dark ? 0.25 : 0.22);
    } else if (dark) {
      gradColors = [
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.04),
      ];
      borderColor = Colors.white.withValues(alpha: 0.18);
      shadowColor = Colors.black.withValues(alpha: 0.28);
    } else {
      gradColors = [
        Colors.white.withValues(alpha: 0.86),
        Colors.white.withValues(alpha: 0.62),
      ];
      borderColor = Colors.white.withValues(alpha: 0.95);
      shadowColor = merah.withValues(alpha: 0.08);
    }

    Widget panel = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradColors,
            ),
            border: Border.all(color: borderColor, width: 1.05),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      panel = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: merah.withValues(alpha: 0.16),
          highlightColor: merah.withValues(alpha: 0.06),
          child: panel,
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: panel);
    }
    return panel;
  }
}

/// Tombol utama merah berkilau
class GlassPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color warna;

  const GlassPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.warna = merah,
  });

  @override
  Widget build(BuildContext context) {
    final aktif = onPressed != null;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: aktif
              ? [warna, Color.lerp(warna, Colors.black, 0.25)!]
              : [Colors.grey.shade500, Colors.grey.shade600],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: aktif ? 0.34 : 0.14),
        ),
        boxShadow: aktif
            ? [
                BoxShadow(
                  color: warna.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 19),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol bulat toggle Tema Siang (Matahari) / Malam (Bulan) dengan animasi putar
class ThemeToggleButton extends StatelessWidget {
  final double size;

  const ThemeToggleButton({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DataSaungLobster.instance,
      builder: (context, _) {
        final dark = DataSaungLobster.instance.isDarkMode;

        return Tooltip(
          message: dark ? 'Ubah ke Mode Terang' : 'Ubah ke Mode Gelap',
          child: GestureDetector(
            onTap: DataSaungLobster.instance.toggleTheme,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          const Color(0xFF2D1920),
                          const Color(0xFF1A0D12),
                        ]
                      : [
                          const Color(0xFFFFE082),
                          const Color(0xFFFFB703),
                        ],
                ),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (dark ? merah : emas).withValues(alpha: 0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(
                  dark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  key: ValueKey(dark),
                  size: size * 0.52,
                  color: dark ? const Color(0xFFFFD166) : Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Avatar kaca profil
class GlassAvatar extends StatelessWidget {
  final AkunPengguna? akun;
  final double radius;
  final VoidCallback? onTap;

  const GlassAvatar({
    super.key,
    required this.akun,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idx = (akun?.avatarColorIndex ?? 0) % presetWarnaAvatar.length;
    final warna = presetWarnaAvatar[idx];
    final foto = akun?.photoUrl;

    final Widget isi = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: warna,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: warna.first.withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipOval(
        child: (foto != null && foto.isNotEmpty)
            ? Image.network(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _teksInisial(),
              )
            : _teksInisial(),
      ),
    );

    if (onTap != null) return GestureDetector(onTap: onTap, child: isi);
    return isi;
  }

  Widget _teksInisial() {
    return Center(
      child: Text(
        akun?.inisial ?? 'SL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }
}

/// Item navigasi bawah
class GlassNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Aksi cepat di dalam bar morphing tombol bulat kanan
class GlassQuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const GlassQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
class LiquidGlassNavOverlay extends StatefulWidget {
  final PageController pageController;
  final int selectedIndex;
  final List<GlassNavItem> items;
  final ValueChanged<int> onTap;
  final IconData actionIcon;
  final String actionTooltip;
  final List<GlassQuickAction> quickActions;

  const LiquidGlassNavOverlay({
    super.key,
    required this.pageController,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.actionIcon,
    required this.actionTooltip,
    required this.quickActions,
  });

  @override
  State<LiquidGlassNavOverlay> createState() => _LiquidGlassNavOverlayState();
}

class _LiquidGlassNavOverlayState extends State<LiquidGlassNavOverlay> {
  bool _isDragging = false;
  double? _dragPage;
  bool _menuTerbuka = false;
  bool _tombolDitekan = false;

  void _updateDrag(double localDx, double maxWidth) {
    final itemW = maxWidth / widget.items.length;
    final pos = ((localDx - itemW / 2) / itemW)
        .clamp(0.0, (widget.items.length - 1).toDouble());
    setState(() {
      _isDragging = true;
      _dragPage = pos;
    });
  }

  void _finishDrag() {
    if (!_isDragging) return;
    final target = (_dragPage ?? widget.selectedIndex.toDouble())
        .round()
        .clamp(0, widget.items.length - 1);
    setState(() {
      _isDragging = false;
      _dragPage = null;
    });
    widget.onTap(target);
  }

  @override
  Widget build(BuildContext context) {
    final dark = isTemaGelap(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final List<Color> pillColors = dark
        ? [
            const Color(0xFF28191D).withValues(alpha: 0.90),
            const Color(0xFF140B0E).withValues(alpha: 0.94),
          ]
        : [
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFFFFF1F2).withValues(alpha: 0.94),
          ];

    final Color pillBorder = dark
        ? Colors.white.withValues(alpha: 0.22)
        : merah.withValues(alpha: 0.20);

    final Color inactiveText =
        dark ? Colors.white60 : const Color(0xFF7B5A61);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 90, // 16 margin + 62 tombol bulat + 12 jarak
            bottom: 14 + bottomInset,
            height: 64,
            child: LayoutBuilder(
              builder: (context, c) {
                final totalW = c.maxWidth;
                final itemW = totalW / widget.items.length;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (d) =>
                      _updateDrag(d.localPosition.dx, totalW),
                  onHorizontalDragUpdate: (d) =>
                      _updateDrag(d.localPosition.dx, totalW),
                  onHorizontalDragEnd: (_) => _finishDrag(),
                  onHorizontalDragCancel: _finishDrag,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: pillColors,
                                ),
                                border: Border.all(
                                  color: pillBorder,
                                  width: 1.15,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: dark ? 0.45 : 0.14,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: widget.pageController,
                        builder: (context, _) {
                          double current = widget.selectedIndex.toDouble();
                          if (_isDragging && _dragPage != null) {
                            current = _dragPage!;
                          } else if (widget.pageController.hasClients &&
                              widget.pageController.position
                                  .hasContentDimensions) {
                            current = (widget.pageController.page ??
                                    widget.selectedIndex.toDouble())
                                .clamp(0.0, (widget.items.length - 1).toDouble());
                          }

                          final frac = current - current.floor();
                          final stretch = math.sin(frac * math.pi);
                          final extraDrag = _isDragging ? 10.0 : 0.0;
                          final lensW =
                              itemW + (itemW * 0.24 * stretch) + extraDrag;
                          final centerX = (current + 0.5) * itemW;
                          final left = (centerX - lensW / 2).clamp(
                            _isDragging ? -6.0 : 4.0,
                            totalW - lensW + (_isDragging ? 6.0 : -4.0),
                          );
                          final vOverflow =
                              _isDragging ? -7.0 : (4.0 + 1.5 * stretch);

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedPositioned(
                                duration: _isDragging
                                    ? const Duration(milliseconds: 45)
                                    : const Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                left: left,
                                top: vOverflow,
                                bottom: vOverflow,
                                width: lensW,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(34),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: _isDragging
                                          ? [
                                              merah.withValues(alpha: 0.44),
                                              Colors.white.withValues(
                                                alpha: dark ? 0.20 : 0.45,
                                              ),
                                            ]
                                          : [
                                              merah.withValues(alpha: 0.92),
                                              merahTua.withValues(alpha: 0.80),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: _isDragging ? 0.65 : 0.36,
                                      ),
                                      width: _isDragging ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: merah.withValues(
                                          alpha: _isDragging ? 0.48 : 0.36,
                                        ),
                                        blurRadius: _isDragging ? 20 : 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Row(
                                  children: List.generate(widget.items.length, (
                                    i,
                                  ) {
                                    final item = widget.items[i];
                                    final kedekatan = (1.0 - (current - i).abs())
                                        .clamp(0.0, 1.0);
                                    final aktif = kedekatan > 0.5;
                                    final warnaIkon = Color.lerp(
                                      inactiveText,
                                      _isDragging && !dark
                                          ? merahTua
                                          : Colors.white,
                                      kedekatan,
                                    );

                                    return Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => widget.onTap(i),
                                        child: Transform.scale(
                                          scale: 0.94 +
                                              (0.14 *
                                                  kedekatan *
                                                  (_isDragging ? 1.3 : 0.7)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                aktif
                                                    ? item.selectedIcon
                                                    : item.icon,
                                                size: 20,
                                                color: warnaIkon,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: aktif
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: warnaIkon,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _menuTerbuka ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              if (t <= 0.01) return const SizedBox.shrink();
              return Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _menuTerbuka = false),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 16 * t,
                        sigmaY: 16 * t,
                      ),
                      child: Container(
                        color: (dark ? Colors.black : const Color(0xFF280F14))
                            .withValues(alpha: (dark ? 0.56 : 0.34) * t),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            right: 16,
            bottom: 14 + bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _menuTerbuka ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  builder: (context, t, _) {
                    final clampedT = t.clamp(0.0, 1.0);
                    if (clampedT <= 0.01) return const SizedBox.shrink();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(widget.quickActions.length, (i) {
                        final act = widget.quickActions[i];
                        final reverseIdx = widget.quickActions.length - 1 - i;
                        final dy = (1.0 - t) * (18.0 + reverseIdx * 10.0);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: Transform.translate(
                            offset: Offset(0, dy),
                            child: Transform.scale(
                              scale: 0.84 + (0.16 * clampedT),
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: clampedT,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _menuTerbuka = false);
                                    act.onTap();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 20,
                                        sigmaY: 20,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          18,
                                          10,
                                          10,
                                          10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: pillColors,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: dark ? 0.28 : 0.9,
                                            ),
                                            width: 1.15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: dark ? 0.42 : 0.16,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              act.label,
                                              style: TextStyle(
                                                color: warnaTeksUtama(context),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [merah, merahTua],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: merah.withValues(
                                                      alpha: 0.35,
                                                    ),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                act.icon,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 2),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => setState(() => _tombolDitekan = true),
                  onTapCancel: () => setState(() => _tombolDitekan = false),
                  onTapUp: (_) {
                    setState(() {
                      _tombolDitekan = false;
                      _menuTerbuka = !_menuTerbuka;
                    });
                  },
                  child: AnimatedScale(
                    scale: _tombolDitekan ? 0.88 : (_menuTerbuka ? 1.05 : 1.0),
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    child: Tooltip(
                      message: _menuTerbuka ? 'Tutup' : widget.actionTooltip,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _menuTerbuka
                                    ? [
                                        const Color(0xFF2B161B),
                                        const Color(0xFF15090C),
                                      ]
                                    : [
                                        merah.withValues(alpha: 0.94),
                                        merahTua.withValues(alpha: 0.86),
                                      ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.38),
                                width: 1.25,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_menuTerbuka ? Colors.black : merah)
                                      .withValues(alpha: 0.42),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              transitionBuilder: (child, anim) =>
                                  RotationTransition(
                                turns: Tween(begin: 0.75, end: 1.0)
                                    .animate(anim),
                                child: ScaleTransition(scale: anim, child: child),
                              ),
                              child: Icon(
                                _menuTerbuka
                                    ? Icons.close_rounded
                                    : widget.actionIcon,
                                key: ValueKey(_menuTerbuka),
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/// Grafik Batang Analitik Kaca Adaptif
class GlassBarChart extends StatelessWidget {
  final String judul;
  final String subjudul;
  final Map<String, double> data;
  final String satuan;
  final Color warnaBar;

  const GlassBarChart({
    super.key,
    required this.judul,
    required this.subjudul,
    required this.data,
    this.satuan = 'kg',
    this.warnaBar = merah,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.isEmpty
        ? 1.0
        : data.values.reduce((a, b) => a > b ? a : b);
    final pembagi = maxVal <= 0 ? 1.0 : maxVal;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                judul,
                style: TextStyle(
                  color: warnaTeksUtama(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subjudul,
                style: TextStyle(
                  color: warnaTeksSekunder(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada data analitik.',
                  style: TextStyle(
                    color: warnaTeksSekunder(context),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 128,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((e) {
                  final rasio = (e.value / pembagi).clamp(0.06, 1.0);
                  final labelSingkat = e.key
                      .replaceAll('Lobster ', '')
                      .replaceAll('Inch', '"');
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${e.value.toStringAsFixed(1)} $satuan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: warnaTeksUtama(context),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                                width: double.infinity,
                                height: 78 * rasio,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      warnaBar,
                                      warnaBar.withValues(alpha: 0.28),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labelSingkat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: warnaTeksSekunder(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kartu KPI Mini Liquid Glass Adaptif (Bebas Overflow)
class GlassStatCard extends StatelessWidget {
  final String judul;
  final String nilai;
  final IconData ikon;
  final Color warna;

  const GlassStatCard({
    super.key,
    required this.judul,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      borderRadius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: warna.withValues(alpha: 0.42)),
            ),
            child: Icon(ikon, color: warna, size: 17),
          ),
          const SizedBox(height: 7),
          Text(
            nilai,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: warnaTeksUtama(context),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            judul,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: warnaTeksSekunder(context), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Dekorasi input kaca adaptif (Dark & Light)
InputDecoration glassInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  IconData? icon,
  Widget? suffixIcon,
}) {
  final dark = isTemaGelap(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(color: warnaTeksSekunder(context), fontSize: 13),
    hintStyle: TextStyle(
      color: warnaTeksSekunder(context).withValues(alpha: 0.55),
    ),
    prefixIcon: icon != null
        ? Icon(icon, color: warnaTeksSekunder(context), size: 19)
        : null,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: dark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.78),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: dark
            ? Colors.white.withValues(alpha: 0.18)
            : merah.withValues(alpha: 0.20),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: merah, width: 1.5),
    ),
  );
}

Widget kartuMenu(
  BuildContext context, {
  required IconData ikon,
  required String judul,
  required String keterangan,
  Color warna = merah,
  VoidCallback? onTap,
}) {
  return GlassCard(
    padding: const EdgeInsets.all(14),
    borderRadius: 18,
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: warna.withValues(alpha: 0.18),
            border: Border.all(color: warna.withValues(alpha: 0.42)),
          ),
          child: Icon(ikon, color: warna, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: warnaTeksUtama(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                keterangan,
                style: TextStyle(
                  color: warnaTeksSekunder(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right_rounded,
            color: warnaTeksSekunder(context),
          ),
      ],
    ),
  );
}

Widget judulBagian(BuildContext context, String teks) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 11, top: 8),
    child: Text(
      teks,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: warnaTeksUtama(context),
        letterSpacing: 0.2,
      ),
    ),
  );
}

Widget badgeStatus(BuildContext context, String teks, Color warna) {
  final dark = isTemaGelap(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: warna.withValues(alpha: dark ? 0.18 : 0.13),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: warna.withValues(alpha: 0.55)),
    ),
    child: Text(
      teks,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: dark
            ? Color.lerp(warna, Colors.white, 0.35)
            : Color.lerp(warna, Colors.black, 0.25),
      ),
    ),
  );
}

String rupiah(double angka) => DataSaungLobster.formatRupiah(angka);