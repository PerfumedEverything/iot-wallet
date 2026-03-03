import 'package:flutter/material.dart';
import 'package:iot_wallet/main.dart';
import 'package:iot_wallet/screens/home/history/history_screen.dart';
import 'package:iot_wallet/screens/home/home_screen.dart';
import 'package:iot_wallet/screens/home/menu/menu_screen.dart';
import 'package:iot_wallet/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> pages = const [
    HomeScreen(),
    HistoryScreen(),
    MenuScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Завжди починаємо з Home таба
    bottomTabIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232439),
      body: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF232439),
          body: ValueListenableBuilder<int>(
            valueListenable: bottomTabIndex,
            builder: (_, index, __) {
              return Stack(
                children: [
                  pages[index],
        
                  ValueListenableBuilder<bool>(
                    valueListenable: showBottomNav,
                    builder: (context, visible, child) {
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        bottom: visible ? 24 : -120,
                        left: 68,
                        right: 68,
                        child: child!,
                      );
                    },
                    child: BottomNav(
                      currentIndex: index,
                      onTap: (i) => bottomTabIndex.value = i,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}