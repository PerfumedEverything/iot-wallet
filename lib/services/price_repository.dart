import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PriceData {
  final String price;
  final String percentChange;

  PriceData(this.price, this.percentChange);
}

class PriceRepository {
  final client = http.Client();

  Future<PriceData?> fetchPriceData(String priceApiUrl) async {
    try {
      final response = await client.get(Uri.parse(priceApiUrl));
      if (response.statusCode == 200) {
        final responseData = response.body;
        final tonPrice = parsePriceResponse(responseData);
        final tonChangePercent = parseChangePercentResponse(responseData);

        final priceFormat = NumberFormat("0.00");
        final formattedPrice = priceFormat.format(tonPrice);

        final percentFormat = NumberFormat("0.00");
        final formattedPercent = percentFormat.format(tonChangePercent);

        return PriceData(formattedPrice, formattedPercent);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching price: $e');
      return null;
    }
  }

  double parsePriceResponse(String responseData) {
    try {
      final jsonResponse = json.decode(responseData);
      final tonData = jsonResponse['the-open-network'];
      return tonData['usd'].toDouble();
    } catch (e) {
      print('Error parsing price: $e');
      return 0.0;
    }
  }

  double parseChangePercentResponse(String responseData) {
    try {
      final jsonResponse = json.decode(responseData);
      final tonData = jsonResponse['the-open-network'];
      return tonData['usd_24h_change'].toDouble();
    } catch (e) {
      print('Error parsing change percent: $e');
      return 0.0;
    }
  }
}
