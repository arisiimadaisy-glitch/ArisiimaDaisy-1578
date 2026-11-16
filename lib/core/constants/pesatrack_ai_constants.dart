/// Constants for PesaTrack AI chat interface and features
class PesaTrackAIConstants {
  PesaTrackAIConstants._();

  // Hive box name for chat history
  static const String hiveChatBoxName = 'pesatrack_ai_messages';

  // Quick action labels
  static const List<String> quickActionLabels = [
    'Add an expense',
    'Analyse spending',
    'Savings advice',
    'My financial health',
  ];

  // Default greeting message
  static const String greetingMessage =
      'Hello, Daisy! 👋 How can I help you manage your money today?';

  // Chat input placeholder
  static const String chatInputPlaceholder =
      'Ask anything about your finances...';

  // Voice input unavailable message
  static const String voiceNotAvailableMessage =
      'Voice input not available on this device';

  // Error messages
  static const String networkErrorMessage = 'Network error. Please try again.';
  static const String dataNotFoundMessage =
      'Unable to load financial data. Please try again.';
  static const String microphonePermissionDenied =
      'Microphone permission denied. Cannot use voice input.';

  // Max chat history messages to display
  static const int maxChatHistoryDisplay = 100;

  // Default user ID for MVP
  // Deprecated: Use setUserId() from AuthProvider to set user-specific ID
  // static const String defaultUserId = 'user_001';

  // Colors for chat bubbles
  static const String userBubbleColor = '#11BD2E'; // Primary green
  static const String aiBubbleBackgroundColor = '#F5F5F3'; // Light background
  static const String aiBubbleTextColor = '#111111'; // Dark text
}
