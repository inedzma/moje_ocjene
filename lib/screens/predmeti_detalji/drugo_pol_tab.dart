import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/predmeti_lista.dart';
import 'package:moje_ocjene/utils/prosjek.dart';

import '../../models/predmet_model.dart';

class DrugoPolTab extends StatelessWidget{
  final List<Predmet> predmeti;
  const DrugoPolTab({super.key, required this.predmeti});

  @override
  Widget build(BuildContext context) {
    final prosjek = izracunajDrugoPolProsjek(predmeti);
    return Column(
      children: [
        Expanded(
          child: PredmetiLista(
            prikazZa: 'drugo',
            predmeti: predmeti,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
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
          child: Text(
            'Prosjek: ${prosjek == 0 ? '-' : prosjek.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02124A),
            ),
          ),
        ),
      ],
    );
  }
}