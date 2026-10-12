import '../../buy_crypto/presentation/buy_crypto_models.dart';

/// Address-format validation only; the transfer provider remains authoritative.
String walletAddressFromPayload(String payload,
    {required BuyCryptoAsset asset, String? network}) {
  var value = payload.trim();
  if (value.isEmpty || value.length > 512) {
    throw const FormatException('Enter a wallet address.');
  }
  final chain = network?.toLowerCase() ?? '';
  final evmNetwork = chain.contains('bep20') || chain.contains('erc20');
  String? scheme;
  if (value.contains(':')) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !['bitcoin', 'ethereum', 'solana', 'tron'].contains(uri.scheme)) {
      throw const FormatException(
          'This QR code does not contain a supported wallet address.');
    }
    scheme = uri.scheme;
    value = Uri.decodeComponent(uri.path);
    if (scheme == 'ethereum') {
      if (value.startsWith('pay-')) value = value.substring(4);
      if (value.contains('/')) {
        throw const FormatException(
            'Scan a receiving address, not a contract transaction request.');
      }
      final parts = value.split('@');
      if (parts.length > 2) {
        throw const FormatException('The address request is invalid.');
      }
      final expectedChain = chain.contains('bep20') ? '56' : '1';
      if (parts.length == 2 && parts[1] != expectedChain) {
        throw const FormatException('This QR code uses a different network.');
      }
      value = parts.first;
    }
  }
  final bitcoin =
      RegExp(r'^[13][1-9A-HJ-NP-Za-km-z]{25,34}$').hasMatch(value) ||
          (value == value.toLowerCase() &&
              RegExp(r'^bc1[qp][023456789acdefghjklmnpqrstuvwxyz]{38,58}$')
                  .hasMatch(value));
  final evm = RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(value);
  final tron = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$').hasMatch(value);
  final solana = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(value);
  final valid = switch (asset) {
    BuyCryptoAsset.bitcoin => evmNetwork
        ? evm && (scheme == null || scheme == 'ethereum')
        : chain.isEmpty
            ? (bitcoin && (scheme == null || scheme == 'bitcoin')) ||
                (evm && (scheme == null || scheme == 'ethereum'))
            : bitcoin && (scheme == null || scheme == 'bitcoin'),
    BuyCryptoAsset.ethereum => evm && (scheme == null || scheme == 'ethereum'),
    BuyCryptoAsset.solana => solana && (scheme == null || scheme == 'solana'),
    BuyCryptoAsset.tether => chain.contains('trc20')
        ? tron && (scheme == null || scheme == 'tron')
        : chain.isEmpty
            ? (tron && (scheme == null || scheme == 'tron')) ||
                (evm && (scheme == null || scheme == 'ethereum'))
            : evm && (scheme == null || scheme == 'ethereum'),
  };
  if (!valid) {
    throw FormatException(
        'Enter an address matching ${network ?? asset.name}.');
  }
  return value;
}
