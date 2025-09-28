import 'package:flutter/material.dart';
import 'package:moje_ocjene/providers/predmeti_provider.dart';
import 'package:moje_ocjene/screens/components/button_nav_bar.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/drugo_pol_tab.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/prvo_pol_tab.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/zakljucne_tab.dart';
import 'package:provider/provider.dart';
import 'package:moje_ocjene/models/predmet_model.dart';

import '../home_screen.dart';

class PredmetiScreen extends StatefulWidget {
  const PredmetiScreen({super.key});

  @override
  State<PredmetiScreen> createState() => _PredmetiScreenState();
}

class _PredmetiScreenState extends State<PredmetiScreen> {
  final List<String> prikazi = ['prvo', 'drugo', 'zakljucna'];
  late int currentIndex;
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    currentIndex = _inicijalniTab();
  }

  int _inicijalniTab() {
    final mjesec = DateTime.now().month;
    if (mjesec >= 9 && mjesec <= 12) return 0;
    if (mjesec >= 1 && mjesec < 6) return 1;
    return 2;
  }

  Widget _tabWidget(List<Predmet> predmeti) {
    switch (prikazi[currentIndex]) {
      case 'prvo':
        return  PrvoPolTab(predmeti: predmeti,);
      case 'drugo':
        return  DrugoPolTab(predmeti: predmeti);
      case 'zakljucna':
        return  ZakljucneTab(predmeti: predmeti);
      default:
        return Center(child: Text("Nepoznat prikaz"));
    }
  }

  String get _nazivPrikaza {
    switch (prikazi[currentIndex]) {
      case 'prvo':
        return '1. polugodište';
      case 'drugo':
        return '2. polugodište';
      case 'zakljucna':
        return 'Kraj godine';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final predmeti = Provider.of<PredmetiProvider>(context).predmeti;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF77B9FF),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          child: Image.asset('lib/assets/mojeOcjene.png', height: 50),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/pozadina.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                        color: const Color(0xFFC0EDFD).withOpacity(0.5), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: currentIndex > 0 ? Color(0xFF02124A) : Colors.grey),
                        onPressed: currentIndex > 0
                            ? () => setState(() => currentIndex--)
                            : null,
                      ),
                      Text(
                        _nazivPrikaza,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02124A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded,
                            color: currentIndex < prikazi.length - 1
                                ? Color(0xFF02124A)
                                : Colors.grey),
                        onPressed: currentIndex < prikazi.length - 1
                            ? () => setState(() => currentIndex++)
                            : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey(currentIndex),
                      child: _tabWidget(predmeti),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          onPressed: () {
            _controller.clear();
            _showError = false;

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              isScrollControlled: true,
              builder: (context) => StatefulBuilder(
                builder: (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Dodaj novi predmet',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF02124A)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _controller,
                            cursorColor: Color(0xFF02124A),
                            decoration: InputDecoration(
                              labelText: 'Naziv predmeta',
                              border: const OutlineInputBorder(),
                              labelStyle: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                              floatingLabelStyle: TextStyle(
                                color: Color(0xFF02124A),
                                fontWeight: FontWeight.w500,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF02124A)),
                              ),
                              errorText: _showError ? 'Unesi naziv predmeta' : null,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                  final naziv = _controller.text.trim();
                                  if (naziv.isNotEmpty) {
                                    final noviPredmet = Predmet(
                                      naziv: naziv,
                                      prvoPolOcjene: [],
                                      drugoPolOcjene: [],
                                    );
                                    final provider = Provider.of<PredmetiProvider>(context, listen: false);
                                    provider.dodajPredmet(noviPredmet);
                                    Navigator.pop(context);
                                  } else {
                                    setModalState(() {
                                      _showError = true;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF77B9FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text('Spremi', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF77B9FF),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
          elevation: 8,
          shape: const CircleBorder(),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
