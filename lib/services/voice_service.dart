import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// VoiceService provides speech-to-text and voice command capabilities.
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  /// Initialize the speech recognizer
  Future<bool> initializeSpeechRecognizer() async {
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech recognizer: $e');
      return false;
    }
  }

  /// Check if microphone permission is available
  Future<bool> get hasPermission async {
    try {
      return await _speechToText.hasPermission;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }

  /// Record and transcribe voice to text
  Future<String?> recordAndTranscribe({
    required void Function(String partial) onPartialResult,
    required void Function() onDone,
  }) async {
    if (!_isInitialized) {
      final ok = await initializeSpeechRecognizer();
      if (!ok) return null;
    }
    if (!await _speechToText.hasPermission) return null;

    _lastWords = '';
    _isListening = true;

    try {
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          onPartialResult(_lastWords);
          if (result.finalResult) {
            _isListening = false;
            onDone();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      debugPrint('Error during recording: $e');
      _isListening = false;
      rethrow;
    }

    return _lastWords.isEmpty ? null : _lastWords;
  }

  /// Stop listening to voice input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Check if voice recognition is available on the device
  Future<bool> isVoiceRecognitionAvailable() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      return false;
    }
  }

  /// Start listening for voice input (legacy method, kept for compatibility)
  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      try {
        bool available = await _speechToText.initialize();
        if (available) {
          _isListening = true;
          _lastWords = '';

          _speechToText.listen(
            onResult: (result) {
              _lastWords = result.recognizedWords;
              onResult(_lastWords);

              if (result.finalResult) {
                _isListening = false;
              }
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
            localeId: 'en_US',
            listenOptions: SpeechListenOptions(
              partialResults: true,
              listenMode: ListenMode.confirmation,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error starting speech recognition: $e');
        _isListening = false;
      }
    }
  }

  /// Parse a voice command and extract action and parameters.
  Map<String, dynamic> parseVoiceCommand(String command) {
    return {
      'action': 'transcription',
      'params': {},
      'originalCommand': command,
      'confidence': 1.0,
      'message': command,
    };
  }
}
