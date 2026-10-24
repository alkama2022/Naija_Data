class AppConfig {
  // Update this to your production backend URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static String get apiUrl => '$baseUrl/api';
  
  // Set to false in production once backend is verified
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );
}
