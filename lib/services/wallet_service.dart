import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet.dart';

class WalletService {
  static const String _walletsKey = 'wallets';
  static const String _activeWalletIdKey = 'active_wallet_id';

  static late SharedPreferences _prefs;

  /// Инициализация сервиса
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Получить все гаманцы
  static Future<List<Wallet>> getAllWallets() async {
    final jsonString = _prefs.getString(_walletsKey) ?? '[]';
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Wallet.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Получить активный гаманец
  static Future<Wallet?> getActiveWallet() async {
    final activeId = _prefs.getString(_activeWalletIdKey);
    if (activeId == null) return null;

    final wallets = await getAllWallets();
    try {
      return wallets.firstWhere((w) => w.id == activeId);
    } catch (e) {
      return null;
    }
  }

  /// Сохранить активный гаманец
  static Future<void> setActiveWallet(String walletId) async {
    await _prefs.setString(_activeWalletIdKey, walletId);
  }

  /// Создать новый гаманец
  static Future<Wallet> createWallet({
    required String seed,
    String? customName,
  }) async {
    final wallets = await getAllWallets();

    // Генерируем ID (wallet + количество существующих гаманцев + 1)
    final walletCount = wallets.length + 1;
    // Генерируем случайный адрес
    final address = _generateRandomAddress();

    final wallet = Wallet(
      id: 'wallet_$walletCount',
      name: customName ?? 'Wallet $walletCount',
      address: address,
      seed: seed,
    );

    wallets.add(wallet);
    await _saveWallets(wallets);
    await setActiveWallet(wallet.id);

    return wallet;
  }

  /// Восстановить гаманец по seed
  static Future<Wallet> restoreWallet({
    required String seed,
    required String address,
    String? customName,
  }) async {
    final wallets = await getAllWallets();
    
    try {
      wallets.firstWhere((w) => w.seed == seed);
      throw Exception('Wallet with this seed already exists');
    } catch (e) {
      if (e.toString().contains('already exists')) rethrow;
    }

    final walletCount = wallets.length + 1;

    final wallet = Wallet(
      id: 'wallet_$walletCount',
      name: customName ?? 'Wallet $walletCount',
      address: address,
      seed: seed,
    );

    wallets.add(wallet);
    await _saveWallets(wallets);
    await setActiveWallet(wallet.id);

    return wallet;
  }

  /// Обновить имя гаманца
  static Future<void> updateWalletName(String walletId, String newName) async {
    final wallets = await getAllWallets();
    final index = wallets.indexWhere((w) => w.id == walletId);

    if (index != -1) {
      wallets[index] = wallets[index].copyWith(name: newName);
      await _saveWallets(wallets);
    }
  }

  /// Удалить гаманец
  static Future<void> deleteWallet(String walletId) async {
    final wallets = await getAllWallets();
    wallets.removeWhere((w) => w.id == walletId);

    await _saveWallets(wallets);

    // Если удален активный гаманец, устанавливаем первый доступный
    final activeId = _prefs.getString(_activeWalletIdKey);
    if (activeId == walletId) {
      if (wallets.isNotEmpty) {
        await setActiveWallet(wallets.first.id);
      } else {
        await _prefs.remove(_activeWalletIdKey);
      }
    }
  }

  /// Получить гаманец по ID
  static Future<Wallet?> getWalletById(String id) async {
    final wallets = await getAllWallets();
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Проверить, существуют ли гаманцы
  static Future<bool> hasWallets() async {
    final wallets = await getAllWallets();
    return wallets.isNotEmpty;
  }

  /// Сохранить список гаманцев
  static Future<void> _saveWallets(List<Wallet> wallets) async {
    final jsonList = wallets.map((w) => w.toJson()).toList();
    await _prefs.setString(_walletsKey, jsonEncode(jsonList));
  }

  /// Генерировать случайный адрес кошелька
  static String _generateRandomAddress() {
    const String chars = '0123456789ABCDEFabcdef';
    final Random random = Random();
    final StringBuffer buffer = StringBuffer();
    
    // Generate EVM-like address (42 chars: 0x + 40 hex chars)
    buffer.write('0x');
    for (int i = 0; i < 40; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    
    return buffer.toString();
  }

  static String _balanceCacheKey(String address) => 'balance_cache_$address';

  /// Returns last cached balance or null if none
  static String? getCachedBalance(String address) {
    return _prefs.getString(_balanceCacheKey(address));
  }

  /// Fetches live balance; on success saves to cache; on failure returns cache
  static Future<String> getBalance(String address) async {
    final url = Uri.parse(
      'https://toncenter.com/api/v3/addressInformation?address=$address&use_v2=false',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final balanceStr = data['balance']?.toString() ?? '0';
        final balance = double.parse(balanceStr) / 1e9;
        final result = balance.toStringAsFixed(2);
        await _prefs.setString(_balanceCacheKey(address), result);
        return result;
      } else {
        print('Error fetching balance: ${response.statusCode}');
        return getCachedBalance(address) ?? '0.00';
      }
    } catch (e) {
      print('Error occurred while fetching balance: $e');
      return getCachedBalance(address) ?? '0.00';
    }
  }

  /// Очистить все данные (для тестирования)
  static Future<void> clearAll() async {
    await _prefs.remove(_walletsKey);
    await _prefs.remove(_activeWalletIdKey);
  }
}
