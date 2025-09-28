import 'package:moje_ocjene/models/predmet_model.dart';


double izracunajProsjekPredmeta1(Predmet predmet){
  if(predmet.prvoPolOcjene.isEmpty) return 0;
  int suma = predmet.prvoPolOcjene.map((o) => o.vrijednost).reduce((a,b) => a+b);
  double prosjek = suma / predmet.prvoPolOcjene.length;

  if(prosjek<1.5) prosjek=1;
  else if(prosjek>=1.5 && prosjek<2.5) prosjek=2;
  else if(prosjek>=2.5 && prosjek<3.5) prosjek=3;
  else if(prosjek>=3.5 && prosjek<4.5) prosjek=4;
  else if(prosjek>=4.5) prosjek=5;

  return prosjek;
}

double izracunajProsjekPredmeta2(Predmet predmet){
  if(predmet.drugoPolOcjene.isEmpty) return 0;
  int suma = predmet.drugoPolOcjene.map((o) => o.vrijednost).reduce((a,b) => a+b);
  double prosjek = suma / predmet.drugoPolOcjene.length;
  if(prosjek<1.5) prosjek=1;
  else if(prosjek>=1.5 && prosjek<2.5) prosjek=2;
  else if(prosjek>=2.5 && prosjek<3.5) prosjek=3;
  else if(prosjek>=3.5 && prosjek<4.5) prosjek=4;
  else if(prosjek>=4.5) prosjek=5;

  return prosjek;
}

double izracunajProsjekPredmetaKraj(Predmet predmet){
  double prosjek1 = izracunajProsjekPredmeta1(predmet);
  double prosjek2 = izracunajProsjekPredmeta2(predmet);

  double prosjekK;
  if(prosjek1 == 0 && prosjek2 == 0 ) return 0;
  else if(prosjek1 == 0 || prosjek2 == 0)
   prosjekK = (prosjek2 + prosjek1);
  else  prosjekK = (prosjek1 + prosjek2) / 2;

  if(prosjekK<1.5) prosjekK=1;
  else if(prosjekK>=2.5 && prosjekK<3.5) prosjekK=3;
  else if(prosjekK>=4.5) prosjekK=5;
  else if(prosjekK>=1.5 && prosjekK<2.5) prosjekK=2;
  else if(prosjekK>=3.5 && prosjekK<4.5) prosjekK=4;

  return prosjekK;
}

double izracunajPrvoPolProsjek(List<Predmet> predmeti){
  double suma= 0;
  int brojPredmeta = 0;
  for(var predmet in predmeti){
    if(izracunajProsjekPredmeta1(predmet) != 0) {
      suma += izracunajProsjekPredmeta1(predmet);
      brojPredmeta++;
    }
  }
  if (brojPredmeta == 0) return 0;
  double prosjek = suma / brojPredmeta;
  return prosjek;
}

double izracunajDrugoPolProsjek(List<Predmet> predmeti){
  double suma= 0;
  int brojPredmeta = 0;
  for(var predmet in predmeti){
    if(izracunajProsjekPredmeta2(predmet) != 0) {
      suma += izracunajProsjekPredmeta2(predmet);
      brojPredmeta++;
    }
  }
  if (brojPredmeta == 0) return 0;
  double prosjek = suma / brojPredmeta;
  return prosjek;
}

double izracunajKrajGodine(List<Predmet> predmeti){
  double suma = 0;
  int brojPredmeta = 0;
  for(var predmet in predmeti){
    if(izracunajProsjekPredmetaKraj(predmet) != 0.0) {
      suma += izracunajProsjekPredmetaKraj(predmet);
      brojPredmeta++;
    }
  }
  if (brojPredmeta == 0) return 0;
  double prosjek = suma / brojPredmeta;
  return prosjek;
}

