/// Fixed, non-custodial UI fixtures. Never use these to receive real funds.
/// Replace with account-scoped, backend-issued destinations before live deposits.
class SimulationCryptoAddress {
  const SimulationCryptoAddress(
    this.address,
    this.network, {
    this.destinationTag,
  });
  final String address, network;
  final String? destinationTag;
  static const bySymbol = <String, SimulationCryptoAddress>{
    'BTC': SimulationCryptoAddress(
      'mrKLfM4JTqSKkM66ujaUXMzpcC24KEegAC',
      'Bitcoin Testnet',
    ),
    'ETH': SimulationCryptoAddress(
      '0x85c6340b692461ab38cb507f6a47634b9b22ce6e',
      'Ethereum Sepolia',
    ),
    'SOL': SimulationCryptoAddress(
      'AaEkjmNjED44huKBJBwfobYG6hLJBqSuMfpfhTcPBadi',
      'Solana Devnet',
    ),
    'USDT': SimulationCryptoAddress(
      '0x7295dfacab7fecdb4d0f4f7fbff54d947d185995',
      'Ethereum Sepolia (ERC20 test token)',
    ),
    'USDC': SimulationCryptoAddress(
      '0x0dd98fbf3c75695809d7fe3e0e64a52a48873bf4',
      'Ethereum Sepolia (ERC20 test token)',
    ),
    'XRP': SimulationCryptoAddress(
      'r9EHiviyPNjK5q9Tw9DFfvnFp4ZJFm5a2G',
      'XRP Ledger Testnet',
      destinationTag: '123456',
    ),
    'ADA': SimulationCryptoAddress(
      'addr_test1vzx0mmf5zc8xjxu35thagmgxqf6v629mqgt5wy9qzh90hac0w0fss',
      'Cardano Preview',
    ),
    'DOGE': SimulationCryptoAddress(
      'njk4T34zn1VF8ycLgwojCJGKBVNvxnr1Vm',
      'Dogecoin Testnet',
    ),
    'LTC': SimulationCryptoAddress(
      'mrJDjfjHMBpBEcM4vrdYu2ZD1nHpL1vm7y',
      'Litecoin Testnet',
    ),
    'BNB': SimulationCryptoAddress(
      '0xdb93d043633c3dd3fceb64b7081d58e4b8b70057',
      'BNB Smart Chain Testnet',
    ),
  };
}
