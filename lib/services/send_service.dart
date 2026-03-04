import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tonutils/tonutils.dart';
import 'package:iot_wallet/services/fast_mnemonic.dart';

class SendService {
  static const String _rpcUrl = 'https://toncenter.com/api/v2/jsonRPC';

  // ── Step 1: Validation ──────────────────────────────────────────────────────

  /// Returns error string or null if address format is valid.
  static String? validateAddressFormat(String address) {
    if (address.trim().isEmpty) return 'Enter recipient address';
    try {
      InternalAddress.parse(address.trim());
      return null;
    } catch (_) {
      return 'Invalid TON address';
    }
  }

  /// Returns error string or null if amount is valid given the balance.
  static String? validateAmount(String amountStr, double balance) {
    if (amountStr.trim().isEmpty) return 'Enter amount';
    final amount = double.tryParse(amountStr.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return 'Invalid amount';
    if (amount < 0.01) return 'Minimum is 0.01 TON';
    if (amount > balance) return 'Insufficient balance';
    return null;
  }

  // ── Step 2: Key derivation ──────────────────────────────────────────────────

  /// Derives KeyPair (publicKey 32 bytes, privateKey 64 bytes NaCl) from seed.
  static Future<KeyPair> deriveKeyPair(String seedPhrase) async {
    final words = seedPhrase.trim().split(RegExp(r'\s+'));
    print('[SendService] deriving keys from ${words.length}-word mnemonic');
    final kp = await FastMnemonic.toKeyPair(words);
    print('[SendService] publicKey=${kp.publicKey.length}B  privateKey=${kp.privateKey.length}B');
    return kp;
  }

  // ── Step 3: Fee estimation ──────────────────────────────────────────────────

  /// Returns estimated fee in TON (0.0 on any error).
  static Future<double> estimateFee({
    required String fromAddress,
    required Uint8List boc,
  }) async {
    final bocBase64 = base64.encode(boc);
    final url = Uri.parse('https://toncenter.com/api/v3/estimateFee');
    final body = jsonEncode({
      'address': fromAddress,
      'body': bocBase64,
      'ignore_chksig': true,
      'init_code': '',
      'init_data': '',
    });
    try {
      final resp = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      }, body: body);
      print('[SendService] estimateFee status=${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final fees = data['source_fees'] as Map<String, dynamic>? ?? {};
        final totalNano = (fees['in_fwd_fee'] as num? ?? 0) +
            (fees['storage_fee'] as num? ?? 0) +
            (fees['gas_fee'] as num? ?? 0) +
            (fees['fwd_fee'] as num? ?? 0);
        final feeTon = totalNano / 1e9;
        print('[SendService] estimated fee=$feeTon TON');
        return feeTon;
      }
    } catch (e) {
      print('[SendService] estimateFee error: $e');
    }
    return 0.0;
  }

  // ── Step 4: Build + send ────────────────────────────────────────────────────

  /// Builds the signed transfer, estimates fee, checks balance, broadcasts.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> send({
    required String seedPhrase,
    required String fromAddress,
    required String toAddress,
    required double amountTon,
    required double balance,
  }) async {
    try {
      // — key derivation —
      print('[Send] step 2 — deriving key pair');
      final keyPair = await deriveKeyPair(seedPhrase);

      // — open contract —
      print('[Send] step 2 — opening wallet contract');
      final walletContract =
          WalletContractV4R2.create(publicKey: keyPair.publicKey);
      final client = TonJsonRpc(_rpcUrl);
      final openedContract = client.open(walletContract);

      // — seqno —
      print('[Send] step 2 — fetching seqno');
      final seqno = await openedContract.getSeqno();
      print('[Send] seqno=$seqno');

      // — parse destination —
      final toInternal = InternalAddress.parse(toAddress.trim());
      print('[Send] to=${toInternal.toRawString()}');

      // — build transfer —
      print('[Send] step 2 — building transfer');
      final transfer = openedContract.createTransfer(
        seqno: seqno,
        privateKey: keyPair.privateKey,
        messages: [
          internal(
            to: SiaString(toInternal.toRawString()),
            value: SbiString(amountTon.toString()),
            bounce: false,
            body: ScString(''),
          ),
        ],
      );
      final bocBytes = transfer.toBoc();
      print('[Send] step 2 — BOC built, ${bocBytes.length} bytes');

      // — fee estimation —
      print('[Send] step 3 — estimating fee');
      final fee = await estimateFee(fromAddress: fromAddress, boc: bocBytes);
      print('[Send] fee=$fee TON  balance=$balance TON  amount=$amountTon TON');

      if (amountTon + fee > balance) {
        return 'Insufficient balance to cover amount + fee ($fee TON)';
      }

      // — wait before broadcast to recover from API rate limit —
      print('[Send] step 3 — waiting 1s before broadcast...');
      await Future.delayed(const Duration(seconds: 1));

      // — broadcast with retry (up to 3 attempts) —
      print('[Send] step 3 — broadcasting transaction');
      String? lastError;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          print('[Send] broadcast attempt ${attempt + 1}/3');
          await openedContract.send(transfer);
          print('[Send] step 3 — SUCCESS');
          return null; // success!
        } catch (e) {
          lastError = e.toString();
          print('[Send] broadcast attempt ${attempt + 1} failed: $e');

          // Only retry if not the last attempt
          if (attempt < 2) {
            final delayMs = (attempt + 1) * 1500; // 1.5s, 3s
            print('[Send] waiting ${delayMs}ms before retry...');
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        }
      }

      // All retries failed
      return 'Transaction failed after 3 broadcast attempts: $lastError';
    } catch (e, st) {
      print('[Send] ERROR: $e\n$st');
      return 'Transaction failed: $e';
    }
  }
}
