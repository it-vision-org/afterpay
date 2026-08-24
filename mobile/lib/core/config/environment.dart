abstract final class Environment {
  /// Defaults to a locally-running backend. Override with e.g.
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:8080/api` (Android emulator),
  /// `http://localhost:8080/api` (iOS simulator), or the deployed AfterPay
  /// API's URL once one exists — a plain `flutter build` without a
  /// dart-define is only meant for local development against this default.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
}
