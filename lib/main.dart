import 'dart:io';
import 'dart:math';
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
import 'package:iot_wallet/services/price_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final config = PostHogConfig(
    'phc_GJAepTnJLXjwraTO3ZpAxHahld4H3m81IaZW6NmvTDS',
  );

  config.debug = true;
  config.captureApplicationLifecycleEvents = true;
  config.host = 'https://eu.i.posthog.com/';

  await Posthog().setup(config);

  final uid = await getOrCreateUserId();

  await Posthog().identify(userId: uid);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF1E2235), 
      systemNavigationBarIconBrightness: Brightness.light, 
      systemNavigationBarDividerColor: Color(0xFF1E2235),
    ),
  );

  await WalletService.init();
  PriceService().startPriceTimer();
  runApp(const MyApp());
}

Future<String> getOrCreateUserId() async {
  final prefs = await SharedPreferences.getInstance();

  String? uid = prefs.getString('posthog_uid');

  if (uid != null) return uid;

  final random = Random();
  uid = List.generate(32, (_) => random.nextInt(16).toRadixString(16)).join();

  await prefs.setString('posthog_uid', uid);

  return uid;
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
          final fromMenu = settings.arguments as bool? ?? false;
          switch (settings.name) {
            case '/splash':
              page = const SplashScreen();
              break;
            case '/welcome':
              page = WelcomeScreen(fromMenu: fromMenu);
              break;
            case '/login':
              page = LoginScreen(fromMenu: fromMenu);
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


