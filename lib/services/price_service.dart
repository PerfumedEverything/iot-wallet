import 'dart:async';
import 'package:flutter/foundation.dart';
import 'price_repository.dart';

class PriceService {
  static final PriceService _instance = PriceService._internal();
  
  late final PriceRepository _priceRepository;
  Timer? _priceTimer;
  
  ValueNotifier<String> priceNotifier = ValueNotifier<String>('0.00');
  
  static const String priceUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=the-open-network&vs_currencies=usd&include_24hr_change=true';

  factory PriceService() {
    return _instance;
  }

  PriceService._internal() {
    _priceRepository = PriceRepository();
  }

  void startPriceTimer() {
    // Якщо таймер вже запущений, не робимо нічого
    if (_priceTimer != null) {
      return;
    }

    // Завантажуємо ціну відразу при запуску
    _loadPrice();

    // Таймер для оновлення ціни кожну хвилину
    _priceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadPrice();
    });
  }

  Future<void> _loadPrice() async {
    try {
      final priceData = await _priceRepository.fetchPriceData(priceUrl);
      if (priceData != null) {
        priceNotifier.value = priceData.price;
      }
    } catch (e) {
      print('Error loading price in PriceService: $e');
    }
  }

  void stopPriceTimer() {
    _priceTimer?.cancel();
    _priceTimer = null;
  }

  void dispose() {
    stopPriceTimer();
    priceNotifier.dispose();
  }

  String getPrice() => priceNotifier.value;
}
