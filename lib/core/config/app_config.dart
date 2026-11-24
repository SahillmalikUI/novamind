class AppConfig {
  AppConfig._();

  /// Supabase project URL
  static const String supabaseUrl =
      'https://jivonzaiipqwsgythvma.supabase.co';

  /// Supabase anon / publishable key
  static const String supabaseAnonKey =
      'sb_publishable_TSh9PpmoI-u8Z_7-D9DSig_26ku1WYz';

  /// Google Gemini API Key
  /// Set via `--dart-define=GEMINI_API_KEY=your_key` or configure for local development.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  /// Default Gemini Model (fast & intelligent)
  static const String geminiModel = 'gemini-flash-lite-latest';
}
