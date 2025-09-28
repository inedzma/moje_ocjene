class Ocjena {
  final int vrijednost;
  final DateTime datum;

  Ocjena({required this.vrijednost, required this.datum});

  Map<String, dynamic> toJson() => {
    'vrijednost' :  vrijednost,
    'datum' : datum.toIso8601String()
  };

  factory Ocjena.fromJson(Map<String, dynamic> json) => Ocjena(
    vrijednost: json['vrijednost'],
    datum: DateTime.parse(json['datum'])
  );

}
