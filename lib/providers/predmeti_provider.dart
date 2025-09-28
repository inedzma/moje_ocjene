import 'package:flutter/cupertino.dart';
import 'package:moje_ocjene/models/predmet_model.dart';
import 'package:moje_ocjene/services/local_storage_service.dart';

class PredmetiProvider with ChangeNotifier {
  List<Predmet> _predmeti = [];

  List<Predmet> get predmeti => _predmeti;

  Future<void> ucitajPredmete() async {
    _predmeti = await LocalStorageService.loadPredmeti();
    notifyListeners();
  }

  void dodajPredmet(Predmet predmet) {
    _predmeti.add(predmet);
    LocalStorageService.savePredmeti(_predmeti);
    notifyListeners();
  }

  void obrisiSve() {
    _predmeti.clear();
    LocalStorageService.clearPredmeti();
    notifyListeners();
  }
}