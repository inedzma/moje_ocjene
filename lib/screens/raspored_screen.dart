import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:moje_ocjene/providers/predmeti_provider.dart';
import 'package:moje_ocjene/screens/components/button_nav_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


import 'home_screen.dart';

class RasporedScreen extends StatefulWidget {
  const RasporedScreen({super.key});

  @override
  State<RasporedScreen> createState() => _RasporedScreenState();
}

class _RasporedScreenState extends State<RasporedScreen> with SingleTickerProviderStateMixin {
  final List<String> dani = ['Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 'Petak', 'Subota'];
  final int brojCasova = 7;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _ucitajRaspored();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _ucitajRaspored() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('raspored_json');
    if (raw == null) return;
    final decoded = json.decode(raw) as Map<String, dynamic>;
    setState(() {
      raspored = decoded.map((k, v) => MapEntry(
        int.parse(k),
        (v as Map).map((ck, cv) => MapEntry(int.parse(ck), cv as String)),
      ));
    });
  }

  Future<void> _snimiRaspored() async {
    final prefs = await SharedPreferences.getInstance();
    final encodable = raspored.map((k, v) => MapEntry(
      k.toString(),
      v.map((ck, cv) => MapEntry(ck.toString(), cv)),
    ));
    await prefs.setString('raspored_json', json.encode(encodable));
  }


  int _inicijalniTab() {
    final wd = DateTime.now().weekday; // 1=Mon..7=Sun
    if (wd == DateTime.sunday) return 0; // nedjelja -> ponedjeljak
    final idx = wd - 1; // 1->0, 2->1, ...
    return idx.clamp(0, dani.length - 1);
  }


  String _nazivPrikaza() => dani[_tabController.index];

  // Map<dan, Map<cas, predmetNaziv>>  // 1..6 (pon..sub)
  Map<int, Map<int, String>> raspored = {
    for (int dan = 1; dan <= 6; dan++) dan: {},
  };

  Widget _buildListaZaDan(int dan, List<String> sviPredmeti) {
    return ListView.separated(
      key: PageStorageKey('lista_dan_$dan'), // zadrži scroll po tabu
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: brojCasova,
      separatorBuilder: (_, __) => const SizedBox(height: 3),
      itemBuilder: (context, index) {
        final cas = index + 1;
        final naziv = raspored[dan]?[cas];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), // lijevo/desno i malo gore/dole
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              onTap: () => _odaberiPredmet(context, dan, cas, sviPredmeti),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF77B9FF),
                child: Text(
                  '$cas',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                naziv ?? 'Dodaj predmet',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: naziv == null ? Colors.grey : const Color(0xFF02124A),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
        );
      },
    );
  }


  void _odaberiPredmet(BuildContext context, int dan, int cas, List<String> sviPredmeti) {
    String? izabraniPredmet = raspored[dan]?[cas];


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // napravi listu za meni: tvoji predmeti + (trenutni custom ako postoji) + DRUGO
            final basePredmeti = sviPredmeti;
            final trenutno = izabraniPredmet;
            final List<String> stavke = [...basePredmeti];

            if (trenutno != null && trenutno.isNotEmpty && !basePredmeti.contains(trenutno)) {
              // ako u ćeliji već stoji neki custom tekst (npr. "Odmor"),
              // dodaj ga da Dropdown ne izbaci grešku (value mora biti u items)
              stavke.add(trenutno);
            }
            stavke.add(_DRUGO_TOKEN);
            return AlertDialog(
              backgroundColor: const Color(0xFFF7FAFF),
              // ↓ smanji praznine dijaloga
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),

              title: Text('${dani[dan - 1]} - $cas. čas',
                style: const TextStyle(color: Color(0xFF02124A)),
              ),

              content: Theme( // ↓ spriječi automatsko “debljanje” touch targeta
                data: Theme.of(context).copyWith(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: SizedBox(
                  height: 48, // ukupna visina polja

                  child: DropdownButtonFormField2<String>(
                    value: (izabraniPredmet == null || izabraniPredmet!.isEmpty)
                    ? null
                      : izabraniPredmet,
                    isExpanded: true,
                    hint: Text(
                      'Odaberi predmet',
                      style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                    // —— izgled polja (kompaktno)
                    decoration: InputDecoration(
                      isDense: true,
                      //floatingLabelBehavior: FloatingLabelBehavior.never;
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF02124A)),
                      ),
                    ),

                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF02124A)),
                      iconSize: 22,
                    ),

                    // —— visina samog “dugmeta”
                    buttonStyleData: const ButtonStyleData(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 0),
                    ),

                    // —— meni: max visina + radius + lagani offset
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 260,
                      offset: const Offset(0, 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7FAFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFB0BEC5)),
                      ),
                      elevation: 4,
                    ),

                    // —— kompaktnije stavke
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    ),

                    items: [
                      for (int i = 0; i < stavke.length; i++) ...[
                        if (stavke[i] == _DRUGO_TOKEN)
                          const DropdownMenuItem<String>(
                            value: _DRUGO_TOKEN,
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Drugo…'),
                              ],
                            ),
                          )
                        else
                          DropdownMenuItem<String>(
                            value: stavke[i],
                            child: Text(
                              stavke[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF02124A)),
                            ),
                          ),
                        if (i != stavke.length - 1)
                          const DropdownMenuItem<String>(
                            enabled: false,
                            child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                          ),
                      ]
                    ],

                    onChanged: (value) async {
                      if (value == _DRUGO_TOKEN) {
                        final unos = await _unesiDrugoDialog(context);
                        if (unos != null && unos.trim().isNotEmpty) {
                          setStateDialog(() {
                            izabraniPredmet = unos.trim(); // ⬅︎ samo u ovoj ćeliji
                          });
                        }
                        // ostani u istom dijalogu; korisnik klikne "Spremi" kao i inače
                      } else {
                        setStateDialog(() {
                          izabraniPredmet = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      child: const Text('Otkaži', style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (izabraniPredmet != null && izabraniPredmet!.isNotEmpty) {
                          setState(() {
                            raspored[dan]?[cas] = izabraniPredmet!;
                          });
                          _snimiRaspored();
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        backgroundColor: const Color(0xFF77B9FF),
                      ),
                      child: const Text('Spremi',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const String _DRUGO_TOKEN = '__DRUGO__';

  Future<String?> _unesiDrugoDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unesi naziv'),
        content: TextField(
          controller: ctrl,
          cursorColor: Color(0xFF02124A),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hint: const Text(
              'npr. Odmor, Odjeljenska zajednica',
              style: TextStyle(
                  color: Color(0xFFB0BEC5),
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF02124A)),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Otkaži', style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              backgroundColor: const Color(0xFF77B9FF),
            ),
            child: const Text('Dodaj', style: TextStyle(color: Colors.white),),
          ),
    ],
          ),
        ],
      ),
    );
  }


  // Kompletna sedmica
  Widget _buildTabelaSedmica(List<String> sviPredmeti) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6EEF7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [ Table(
            // lakše linije između ćelija, bez debelog vanjskog okvira
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder.symmetric(
              inside: BorderSide(color: Color(0xFFEAF1F8), width: 1),
            ),
            // šire ime dana, uže časovi
            defaultColumnWidth: const FixedColumnWidth(96),
            columnWidths: const { 0: FixedColumnWidth(140) },
            children: [
              // HEADER
              TableRow(
                children: [
                  _headerCell('Dan', isFirst: true),
                  for (int cas = 1; cas <= brojCasova; cas++)
                    _headerCell('$cas.', isLast: cas == brojCasova),
                ],
              ),

              // REDOVI  (1=pon .. 6=sub)
              for (int dan = 1; dan <= 6; dan++)
                TableRow(
                  decoration: BoxDecoration(
                    color: dan.isOdd ? Colors.white : const Color(0xFFF7FAFF),
                  ),
                  children: [
                    TableCell( // ⬅️ ovo je ključ
                      verticalAlignment: TableCellVerticalAlignment.fill,
                      child: _dayCell(dani[dan - 1]),
                    ),
                    for (int cas = 1; cas <= brojCasova; cas++)
                      _scheduleCell(dan, cas, sviPredmeti),
                  ],
                ),
            ],
            ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

// ===== helpers =====

  Widget _headerCell(String text, {bool isFirst = false, bool isLast = false}) {
    return Container(
      alignment: Alignment.center, // <—
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FF),
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
          topRight: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center, // <—
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF02124A),
        ),
      ),
    );
  }

  Widget _dayCell(String text) {
    return Container(
      alignment: Alignment.center, // <—
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F6FA), // cijela ćelija obojena
      ),
      child: Text(
        text,
        textAlign: TextAlign.center, // <—
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF02124A),
        ),
      ),
    );
  }

  Widget _scheduleCell(int dan, int cas, List<String> sviPredmeti) {
    final value = raspored[dan]?[cas];

    return InkWell(
      onTap: () => _odaberiPredmet(context, dan, cas, sviPredmeti),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        constraints: const BoxConstraints(minHeight: 56), // malo više
        alignment: Alignment.center, // <—
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: value == null
            ? const Icon(Icons.add, size: 20, color: Colors.black26)
            : Text(
          value,
          textAlign: TextAlign.center,     // <— centrira i višeredni
          softWrap: true,                  // <—
          overflow: TextOverflow.visible,  // <—
          style: const TextStyle(
            color: Color(0xFF02124A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _idiNaPrethodniTab() {
    final i = _tabController.index;
    if (i > 0) _tabController.animateTo(i - 1);
  }

  void _idiNaSljedeciTab() {
    final i = _tabController.index;
    if (i < dani.length - 1) _tabController.animateTo(i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final predmetiProvider = Provider.of<PredmetiProvider>(context);
    final sviPredmeti = predmetiProvider.predmeti.map((p) => p.naziv).toList();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

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
            child: DefaultTabController(
              length: dani.length,
              initialIndex: _inicijalniTab(), // 0..5
              child: Builder( // VAŽNO: novi context ispod DefaultTabController-a
                builder: (innerCtx) {
                  final controller = DefaultTabController.of(innerCtx)!;

                  // Osvježi header kad se swipe-a
                  return AnimatedBuilder(
                    animation: controller.animation!,
                    builder: (_, __) {
                      final currentIndex = controller.index;
                      return Column(
                        children: [
                         if(!isLandscape) Container(
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
                                color: const Color(0xFFC0EDFD).withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                                      color: currentIndex > 0 ? const Color(0xFF02124A) : Colors.grey),
                                  onPressed: currentIndex > 0
                                      ? () => controller.animateTo(currentIndex - 1)
                                      : null,
                                ),
                                Text(
                                  dani[currentIndex],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF02124A),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios_rounded,
                                      color: currentIndex < dani.length - 1
                                          ? const Color(0xFF02124A)
                                          : Colors.grey),
                                  onPressed: currentIndex < dani.length - 1
                                      ? () => controller.animateTo(currentIndex + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          // SADRŽAJ
                          Expanded(
                            child: isLandscape
                                ? _buildTabelaSedmica(sviPredmeti) // cijela sedmica
                                : TabBarView( // jedan dan po tabu
                              children: [
                                for (int d = 1; d <= dani.length; d++)
                                  _buildListaZaDan(d, sviPredmeti),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
