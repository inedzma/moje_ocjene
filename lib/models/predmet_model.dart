import 'package:moje_ocjene/models/ocjena_model.dart';

class Predmet{
  final String naziv;
  final List<Ocjena> prvoPolOcjene;
  final List<Ocjena> drugoPolOcjene;

  Predmet({required this.naziv, required this.prvoPolOcjene, required this.drugoPolOcjene});

  Map<String, dynamic> toJson() => {
    'naziv' : naziv,
    'prvo_ocjene' : prvoPolOcjene.map((o) => o.toJson()).toList(),
    'drugo_ocjene': drugoPolOcjene.map((o) => o.toJson()).toList()
  };

  factory Predmet.fromJson(Map<String, dynamic> json) => Predmet(
    naziv: json['naziv'],
    prvoPolOcjene: (json['prvo_ocjene'] as List)
      .map((item) => Ocjena.fromJson(item))
      .toList() ?? [],
    drugoPolOcjene: (json['drugo_ocjene'] as List)
      .map((item) => Ocjena.fromJson(item))
      .toList() ?? []
  );
}