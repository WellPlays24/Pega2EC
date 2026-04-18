class AppConfig {
  static const appName = 'Pega2EC';
  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
