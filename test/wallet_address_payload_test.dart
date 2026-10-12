import 'package:davochain/features/crypto/presentation/wallet_address_payload.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const btc = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
  const evm = '0x0123456789012345678901234567890123456789';
  test('scanned BTC URI returns only its address', () {
    expect(
        walletAddressFromPayload('bitcoin:$btc?amount=1',
            asset: BuyCryptoAsset.bitcoin, network: 'Bitcoin (BTC)'),
        btc);
  });
  test('wrong-chain URLs and contract instructions cannot become recipients',
      () {
    expect(
        () => walletAddressFromPayload('ethereum:$evm@56',
            asset: BuyCryptoAsset.ethereum),
        throwsFormatException);
    expect(
        () => walletAddressFromPayload('ethereum:$evm/transfer?address=$evm',
            asset: BuyCryptoAsset.ethereum),
        throwsFormatException);
    expect(
        () => walletAddressFromPayload('https://example.com/$btc',
            asset: BuyCryptoAsset.bitcoin),
        throwsFormatException);
  });
  test('selected network controls allowed address formats', () {
    expect(
        walletAddressFromPayload(evm,
            asset: BuyCryptoAsset.bitcoin, network: 'BNB Smart Chain (BEP20)'),
        evm);
    expect(
        () => walletAddressFromPayload(evm,
            asset: BuyCryptoAsset.bitcoin, network: 'Bitcoin (BTC)'),
        throwsFormatException);
    expect(
        () => walletAddressFromPayload('not an address',
            asset: BuyCryptoAsset.ethereum),
        throwsFormatException);
  });
}
