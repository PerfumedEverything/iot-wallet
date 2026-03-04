import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_wallet/screens/create/create_screen.dart';
import 'package:iot_wallet/screens/create/success_screen.dart';
import 'package:iot_wallet/screens/home/history/history_screen.dart';
import 'package:iot_wallet/screens/home/main_screen.dart';
import 'package:iot_wallet/screens/home/menu/edit_wallet_screen.dart';
import 'package:iot_wallet/screens/home/receive/receive_screen.dart';
import 'package:iot_wallet/screens/home/send/send_screen.dart';
import 'package:iot_wallet/screens/login_screen.dart';
import 'package:iot_wallet/screens/registration_screen.dart';
import 'package:iot_wallet/screens/restore/restore_screen.dart';
import 'package:iot_wallet/screens/restore/success_restore.dart';
import 'package:iot_wallet/screens/splash_screen.dart';
import 'package:iot_wallet/services/wallet_service.dart';
import 'screens/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<bool> showBottomNav = ValueNotifier(true);
final ValueNotifier<int> bottomTabIndex = ValueNotifier<int>(0);

const MethodChannel _bgChannel = MethodChannel('com.iot.iott/background');

Future<void> _moveToBackground() async {
  if (Platform.isAndroid) {
    try {
      await _bgChannel.invokeMethod('moveToBackground');
    } catch (e) {
      debugPrint('Failed to move to background: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF1E2235), 
      systemNavigationBarIconBrightness: Brightness.light, 
      systemNavigationBarDividerColor: Color(0xFF1E2235),
    ),
  );

  await WalletService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BackHandlerNavigator(),
    );
  }
}

class BackHandlerNavigator extends StatefulWidget {
  const BackHandlerNavigator({super.key});

  @override
  State<BackHandlerNavigator> createState() => _BackHandlerNavigatorState();
}

class _BackHandlerNavigatorState extends State<BackHandlerNavigator> {
  // Future<bool> _onWillPop() async {
  //   final nav = navigatorKey.currentState!;
  //   if (nav.canPop()) {
  //     nav.pop();
  //     debugPrint('➡ Navigator pop');
  //     return false;
  //   } else {
  //     // На root маршруте - закрыть приложение
  //     debugPrint('⬇ MoveToBackground()');
  //     await _moveToBackground();
  //     return false;
  //   }
  // }

  Future<bool> _onWillPop() async {
  final nav = navigatorKey.currentState!;

  // Якщо можемо pop — значить ми НЕ на /home
  if (nav.canPop()) {
    nav.pop();
    debugPrint('➡ Navigator pop');
    return false;
  }

  // Якщо ми на root (/home)
  // І таб НЕ Home
  if (bottomTabIndex.value != 0) {
    bottomTabIndex.value = 0;
    debugPrint('🏠 Switch to Home tab instead of closing');
    return false;
  }

  // Якщо вже на Home табі — згортати
  debugPrint('⬇ MoveToBackground()');
  await _moveToBackground();
  return false;
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Navigator(
        key: navigatorKey,
        initialRoute: '/splash',
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/splash':
              page = const SplashScreen();
              break;
            case '/welcome':
              page = const WelcomeScreen();
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/registration':
              page = const RegistrationScreen();
              break;
            case '/create':
              page = const CreateWalletScreen();
              break;
            case '/success_create':
              page = const SuccessCreateScreen();
              break;
            case '/restore':
              page = const RestoreWalletScreen();
              break;
            case '/success_restore':
              page = const SuccessRestoreScreen();
              break;
            case '/receive':
              page = const ReceiveScreen();
              break;
            case '/send':
              page = const SendScreen();
              break;
            case '/history':
              page = const HistoryScreen();
              break;
            case '/home':
              page = const MainScreen();
              break;
            case '/edit_wallet':
              page = const EditWalletScreen();
              break;
            default:
              page = const SplashScreen();
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
    );
  }
}


