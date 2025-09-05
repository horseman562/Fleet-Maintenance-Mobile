class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://192.168.0.5:8000/api/mobile';
  
  // Development credentials (should be moved to environment variables)
  static const String devEmail = 'deathreaper754@gmail.com';
  static const String devPassword = 'babi123456';
  
  // Environment flags
  static const bool isDevelopment = true;
  static const bool enableAutoLogin = true;
  
  // App Information
  static const String appName = 'Fleet Mobile';
  static const String appVersion = '1.0.0';
}