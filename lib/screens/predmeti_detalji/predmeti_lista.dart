import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moje_ocjene/models/ocjena_model.dart';
import 'package:moje_ocjene/providers/predmeti_provider.dart';
import 'package:moje_ocjene/models/predmet_model.dart';
import 'package:provider/provider.dart';

import '../../services/local_storage_service.dart';

String IzracunajProsjek(List<Ocjena> ocjene){
  if(ocjene.isEmpty) return '-';
  int suma = ocjene.map((o) => o.vrijednost).reduce((a,b) => a+b);
  double prosjek = suma / ocjene.length;
  return prosjek.toStringAsFixed(2);
}

String IzracunajKrajnjiProsjek(Predmet predmet) {
  if (predmet.prvoPolOcjene.isEmpty && predmet.drugoPolOcjene.isEmpty) return '-';

  int finalno1 = 0;
  int finalno2 = 0;

  if (predmet.prvoPolOcjene.isNotEmpty) {
    int suma1 = predmet.prvoPolOcjene.map((o) => o.vrijednost).reduce((a, b) => a + b);
    double prosjek1 = suma1 / predmet.prvoPolOcjene.length;

    if (prosjek1 < 1.5) finalno1 = 1;
    else if (prosjek1 < 2.5) finalno1 = 2;
    else if (prosjek1 < 3.5) finalno1 = 3;
    else if (prosjek1 < 4.5) finalno1 = 4;
    else finalno1 = 5;
  }

  if (predmet.drugoPolOcjene.isNotEmpty) {
    int suma2 = predmet.drugoPolOcjene.map((o) => o.vrijednost).reduce((a, b) => a + b);
    double prosjek2 = suma2 / predmet.drugoPolOcjene.length;

    if (prosjek2 < 1.5) finalno2 = 1;
    else if (prosjek2 < 2.5) finalno2 = 2;
    else if (prosjek2 < 3.5) finalno2 = 3;
    else if (prosjek2 < 4.5) finalno2 = 4;
    else finalno2 = 5;
  }

  // Ako postoji samo jedno polugodiste
  if (predmet.prvoPolOcjene.isEmpty) return finalno2.toStringAsFixed(2);
  if (predmet.drugoPolOcjene.isEmpty) return finalno1.toStringAsFixed(2);

  double krajnji = (finalno1 + finalno2) / 2;
  return krajnji.toStringAsFixed(2);
}

class PredmetiLista extends StatelessWidget{
  final String prikazZa;
  final List<Predmet> predmeti;

  const PredmetiLista({super.key, required this.prikazZa, required this.predmeti});

  void _prikaziOcjeneModal(BuildContext context, Predmet predmet) {
    final List<Ocjena> ocjene = prikazZa == 'prvo'
        ? predmet.prvoPolOcjene
        : prikazZa == 'drugo'
        ? predmet.drugoPolOcjene
        : [...predmet.prvoPolOcjene, ...predmet.drugoPolOcjene];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                  predmet.naziv,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF02124A), fontSize: 22),
                ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Izbriši predmet',
                onPressed: () {
                  Navigator.of(context).pop(); // prvo zatvori ovaj dialog
                  _izbrisiPredmet(context, predmet); // pa otvori modal za potvrdu
                },
              )
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ocjene.isEmpty)
                  const Text(
                    'Nema ocjena za ovaj period.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.285,
                    child: Scrollbar(
                      thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: ocjene.map((o) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.grade, color: Color(0xFF77B9FF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ocjena: ${o.vrijednost}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Datum: ${o.datum.toIso8601String().split('T').first}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xfff66f6f), size: 20),
                                tooltip: 'Izbriši ocjenu',
                                onPressed: () {
                                  _izbrisiOcjenu(context, predmet, o);
                                  Navigator.of(context).pop();
                                  _prikaziOcjeneModal(context, predmet);
                                },
                              ),
                            ],
                          ),
                        )).toList(), // <--- OVO JE FALILO
                      ),
                    ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Zatvori',
                style: TextStyle(color: Colors.red),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            if(prikazZa == 'prvo' || prikazZa == 'drugo')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _dodajOcjenu(context, predmet);
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Dodaj ocjenu',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  backgroundColor: const Color(0xFF77B9FF),
                ),
              ),
        ],
            ),
          ],
        );
      },
    );
  }

  void _izbrisiOcjenu(BuildContext context, Predmet predmet, Ocjena ocjena) async {
    final provider = Provider.of<PredmetiProvider>(context, listen: false);
    final index = provider.predmeti.indexOf(predmet);

    if (index == -1) return;

    if (prikazZa == 'prvo') {
      provider.predmeti[index].prvoPolOcjene.remove(ocjena);
    } else if (prikazZa == 'drugo') {
      provider.predmeti[index].drugoPolOcjene.remove(ocjena);
    } else {
      // Za "zakljucna" — pokušaj izbrisati iz obje ako postoji (opciono)
      provider.predmeti[index].prvoPolOcjene.remove(ocjena);
      provider.predmeti[index].drugoPolOcjene.remove(ocjena);
    }

    provider.notifyListeners();
    await LocalStorageService.savePredmeti(provider.predmeti);
  }



  void _izbrisiPredmet(BuildContext context, Predmet predmet){
    showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: EdgeInsets.only(top: 16, left: 24, right: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ Text(
                'Brisanje predmeta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF02124A),
                ),
              ),
                IconButton(onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close), color: Color(0xFF02124A),)
            ],
            ),
            content: Text.rich(
              TextSpan(
                text: 'Jeste li sigurni da želite izbrisati predmet  ',
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: predmet.naziv,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02124A), // ili bilo koja boja
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Otkaži',
                            style: TextStyle(
                              color: Color(0xFF02124A)
                            ),
                          ),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Color(0xFF02124A)),
                          overlayColor: MaterialStateProperty.all(Color(0x1A02124A)), // efekt kad klikneš
                          side: MaterialStateProperty.all(
                            BorderSide(color: Color(0xFF02124A), width: 1.5),
                          ),
                        ),
                      ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          final provider = Provider.of<PredmetiProvider>(context, listen: false);
                          provider.predmeti.remove(predmet);
                          provider.notifyListeners();

                          await LocalStorageService.savePredmeti(provider.predmeti);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                            'Izbriši',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  void _dodajOcjenu(BuildContext context, Predmet predmet) async{
    final TextEditingController _controller = TextEditingController();
    bool _showError = false;
    showDialog(
      context: context,
      builder: (context) {
        bool showError = false;
        final TextEditingController _controller = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Center(
                child: Text(
                  'Dodaj ocjenu:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF02124A)),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    cursorColor: Color(0xFF02124A),
                    decoration: InputDecoration(
                      labelText: 'Unesi ocjenu',
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      floatingLabelStyle: const TextStyle(
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
                      errorText: showError ? 'Unesi ocjenu od 1 do 5' : null,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final vrijednostText = _controller.text.trim();
                      final int? vrijednost = int.tryParse(vrijednostText);

                      if (vrijednost == null || vrijednost < 1 || vrijednost > 5) {
                        setModalState(() {
                          showError = true;
                        });
                        return;
                      }

                      final novaOcjena = Ocjena(vrijednost: vrijednost, datum: DateTime.now());
                      final provider = Provider.of<PredmetiProvider>(context, listen: false);
                      final index = provider.predmeti.indexOf(predmet);

                      if (index != -1) {
                        if (prikazZa == 'prvo') {
                          provider.predmeti[index].prvoPolOcjene.add(novaOcjena);
                        } else if (prikazZa == 'drugo') {
                          provider.predmeti[index].drugoPolOcjene.add(novaOcjena);
                        }

                        provider.notifyListeners();
                        await LocalStorageService.savePredmeti(provider.predmeti);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Spremi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF77B9FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){

    if(predmeti.isEmpty){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 64, color: Colors.grey,),
            SizedBox(height: 16),
            Text(
              'Nema unesenih predmeta',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: predmeti.length,
      itemBuilder: (context, index) {
        final predmet = predmeti[index];

        String prikazProsjeka = '-';
        if(prikazZa == 'prvo') prikazProsjeka = IzracunajProsjek(predmet.prvoPolOcjene);
        else if(prikazZa == 'drugo') prikazProsjeka = IzracunajProsjek(predmet.drugoPolOcjene);
        else if(prikazZa == 'zakljucna') prikazProsjeka = IzracunajKrajnjiProsjek(predmet);

        return GestureDetector(
          onTap: () => _prikaziOcjeneModal(context, predmet),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC0EDFD).withOpacity(0.4), // blagi plavi border
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    predmet.naziv,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF02124A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0EDFD),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    prikazProsjeka,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Color(0xFF02124A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}