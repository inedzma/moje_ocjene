import 'package:flutter/material.dart';
import 'package:moje_ocjene/screens/home_screen.dart';
import 'package:moje_ocjene/screens/predmeti_detalji/predmeti_screen.dart';
import 'package:moje_ocjene/screens/raspored_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onTap(int index, BuildContext context) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PredmetiScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RasporedScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index, context),
        backgroundColor: const Color(0xFF02124A).withOpacity(0.95),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book,
              size: currentIndex == 0 ?  thirty : 24,
            ),
            label: 'Predmeti',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: currentIndex == 1 ?  thirty : 24,
            ),
            label: 'Početna',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schedule,
              size: currentIndex == 2 ?  thirty : 24,
            ),
            label: 'Raspored',
          ),
        ],
      ),
    );
  }
}

const double thirty = 37.0;
