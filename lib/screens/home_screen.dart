import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moje_ocjene/providers/predmeti_provider.dart';
import 'package:moje_ocjene/screens/components/button_nav_bar.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/predmeti_screen.dart';
import 'package:moje_ocjene/screens/raspored_screen.dart';
import 'package:provider/provider.dart';

import '../utils/prosjek.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PredmetiProvider>(context);
    final prosjek = izracunajKrajGodine(provider.predmeti);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF77B9FF),
        title: Image.asset('lib/assets/mojeOcjene.png', height: 50),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Pozadinska ilustracija
          Positioned.fill(
            child: Image.asset('lib/assets/pozadina.png', fit: BoxFit.cover),
          ),
          // Blagi overlay da sve bude čitljivo
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Kartica: Moj prosjek
                      _AverageDial(
                        title: 'Moj prosjek',
                        value: provider.predmeti.isEmpty ? null : prosjek,
                      ),

                      const SizedBox(height: 32),

                      // Akcije
                      _ActionTile(
                        asset: 'lib/assets/knjiga.png',
                        title: 'Moji predmeti',
                        subtitle: 'Dodaj/uredi predmete i ocjene',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PredmetiScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        asset: 'lib/assets/raspored.png',
                        title: 'Raspored časova',
                        subtitle: 'Pregled i izmjene rasporeda',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RasporedScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildButton(String imagePath, String label, {double iconSize = 80}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF77B9FF), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(imagePath, height: iconSize),
          const SizedBox(width: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Color(0xFF02124A),
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionTile extends StatelessWidget {
  final String asset;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.asset,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF02124A);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFA7D2FF), width: 2), // plavi border
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        customBorder: Border.all(
          color: Color(0xFF77B9FF)
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ikona u “pillu”
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              // tekst
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: navy.withOpacity(0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0x6602124A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AverageDial extends StatelessWidget {
  final String title;
  final double? value; // null = nema podataka

  const _AverageDial({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF02124A);
    final v = (value ?? 0).clamp(0, 5);

    // responsivno: veličina kruga ovisno o širini ekrana
    final diameter = (MediaQuery.of(context).size.width * 0.55).clamp(180.0, 240.0);
    final numberSize = diameter * 0.30; // npr. 54–72
    final col = _gradeColor(v.toDouble());

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: CircleBorder(
        side: BorderSide(color: col, width: 2), // plavi okvir
      ),
      child: Padding(
        // malo manji padding da broj stane veći
        padding: EdgeInsets.all(diameter * 0.20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF77B9FF),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
           const SizedBox(height: 25),

            // sam krug (kao “okvir”) + sadržaj unutra
            SizedBox(
              width: diameter,
              height: diameter * 0.65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // VEĆI broj
                      Text(
                        value == null ? '-' : v.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: navy,
                          fontSize: 90,   // ← veći broj
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: 0.5,
                        ),
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _GradeChip(v: v.toDouble(), big: true), // ← veći chip
            SizedBox(height: 15),
            if (value != null && v < 5.0 && v >= 4.5)
              Text(
                'Skoro savršeno ✨\nJoš ${(5.0 - v).clamp(0, 5).toStringAsFixed(2)} do 5.00',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (value != null && v<4.5 && v>= 3.5)
              Text(
                'Nema spavanja🎯\nJoš ${(4.5 - v).clamp(0, 5).toStringAsFixed(2)} do 4.50',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (value != null && v<3.5 && v>= 2.5)
                Text(
                  'Srednja žalost🥴\nJoš ${(3.5 - v).clamp(0, 5).toStringAsFixed(2)} do 3.50',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                )
            else if (value != null && v<2.5 && v>= 1.5)
                Text(
                  'Alarm ⏰ \nJoš ${(2.5 - v).clamp(0, 5).toStringAsFixed(2)} do 2.50',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                )
            else if (value != null && v<1.5)
                Text(
                  'SOS🆘 \nJoš ${(1.5 - v).clamp(0, 5).toStringAsFixed(2)} do 1.50',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                )
            else if (value != null && v==5.00)
                Text(
                  'Čestitke 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy.withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                )
          ],
        ),
      ),
    );
  }
}
class _GradeChip extends StatelessWidget {
  final double v;
  final bool big;
  const _GradeChip({required this.v, this.big = false});

  @override
  Widget build(BuildContext context) {
    final label = _gradeLabel(v);
    final col = _gradeColor(v);

    final fs = big ? 14.0 : 12.0;
    final hp = big ? 14.0 : 10.0;
    final vp = big ? 8.0  : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF02124A),
          fontWeight: FontWeight.w800,
          fontSize: fs,
        ),
      ),
    );
  }
}

// boja skale po prosjeku
Color _gradeColor(double v) {
  if (v >= 4.5) return const Color(0xFF4F86F7);    // odličan
  if (v >= 3.5) return const Color(0xFF66BB6A);    // vrlo dobar
  if (v >= 2.5) return const Color(0xFFF8D51E);    // dobar
  if(v >= 2.0) return const Color(0xFFF4781E);                  // dovoljan / slab
  return const Color(0xFFD61313);
}

// label skale po prosjeku
String _gradeLabel(double v) {
  if (v >= 4.5) return 'Odličan';
  if (v >= 3.5) return 'Vrlo dobar';
  if (v >= 2.5) return 'Dobar';
  if(v >= 2.0) return 'Dovoljan';
  return 'Nedovoljan';
}


