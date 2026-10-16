enum AppEnvironment { development, staging, production }

enum ProviderAuthority { local, remote }

/// Remote adapters must be supplied explicitly before a production entrypoint.
/// This guard is also enforced by the real application composition root.
class AppProviders {
  AppProviders({required this.environment, required this.authority}) {
    if (environment == AppEnvironment.production &&
        authority != ProviderAuthority.remote) {
      throw StateError('Production requires authenticated remote providers.');
    }
  }
  final AppEnvironment environment;
  final ProviderAuthority authority;
  static void validateCurrentEntrypoint() {
    const environment = String.fromEnvironment(
      'DAVOCHAIN_ENV',
      defaultValue: 'development',
    );
    if (environment == 'production') {
      // No live adapter has been delivered. Do not silently fall back to fixtures.
      AppProviders(
        environment: AppEnvironment.production,
        authority: ProviderAuthority.local,
      );
    }
  }
}
