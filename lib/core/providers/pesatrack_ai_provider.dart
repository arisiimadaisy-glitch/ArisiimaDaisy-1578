import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/ai_message_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/savings_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../services/ai_service.dart';
import '../constants/pesatrack_ai_constants.dart';

import 'package:uuid/uuid.dart';

/// Provider for managing PesaTrack AI chat state and history
class PesaTrackAIProvider extends ChangeNotifier {
  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _userId = '';

  // Dependencies
  final AIService _aiService = AIService();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final BudgetRepository _budgetRepository = BudgetRepository();
  final SavingsRepository _savingsRepository = SavingsRepository();

  // Getters
  List<AIMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userId => _userId;

  PesaTrackAIProvider() {
    _initializeAsync();
  }

  /// Initialize the provider by loading chat history from Hive
  Future<void> _initializeAsync() async {
    await loadHistory(_userId);
  }

  /// Load chat history from Hive for the given user
  Future<void> loadHistory(String userId) async {
    try {
      _userId = userId;
      final box = Hive.box<String>(PesaTrackAIConstants.hiveChatBoxName);

      _messages.clear();

      // Load all messages and deserialize
      for (final key in box.keys) {
        final jsonString = box.get(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final message = AIMessage.fromJson(json);
            if (message.userId == userId) {
              _messages.add(message);
            }
          } catch (e) {
            // Skip malformed messages
            debugPrint('Error deserializing message: $e');
          }
        }
      }

      // Sort by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = PesaTrackAIConstants.dataNotFoundMessage;
      notifyListeners();
    }
  }

  /// Send a message and get AI response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    try {
      _errorMessage = null;

      // Create user message
      final userMessage = AIMessage(
        id: const Uuid().v4(),
        userId: _userId,
        message: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Add user message to list and persist
      _messages.add(userMessage);
      try {
        await _persistMessage(userMessage);
      } catch (e) {
        _errorMessage = 'Failed to save your message. Please try again.';
        notifyListeners();
        return;
      }
      notifyListeners();

      // Set loading state
      _isLoading = true;
      notifyListeners();

      // Fetch financial data
      List<Transaction> transactions = [];
      List<Budget> budgets = [];
      List<SavingsGoal> goals = [];

      try {
        transactions = await _transactionRepository.getByUserId(_userId);
        budgets = await _budgetRepository.getByUserId(_userId);
        goals = await _savingsRepository.getByUserId(_userId);
      } catch (e) {
        _isLoading = false;
        _errorMessage = 'Failed to load your financial data. Please check your connection and try again.';
        notifyListeners();
        return;
      }

      // Process message with AI service
      late final String responseText;
      try {
        responseText = _aiService.processMessage(
          text.trim(),
          transactions,
          budgets,
          goals,
        );
      } catch (e) {
        _isLoading = false;
        _errorMessage = 'Unable to process your request. Please try again.';
        notifyListeners();
        return;
      }

      // Create AI message
      final aiMessage = AIMessage(
        id: const Uuid().v4(),
        userId: _userId,
        message: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Add AI message to list and persist
      _messages.add(aiMessage);
      try {
        await _persistMessage(aiMessage);
      } catch (e) {
        _errorMessage =
            'Response received but failed to save. Please try again.';
        notifyListeners();
        return;
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
    }
  }

  /// Persist a message to Hive storage
  Future<void> _persistMessage(AIMessage message) async {
    try {
      final box = Hive.box<String>(PesaTrackAIConstants.hiveChatBoxName);
      final jsonString = jsonEncode(message.toJson());
      await box.put(message.id, jsonString);
    } catch (e) {
      debugPrint('Error persisting message: $e');
      rethrow;
    }
  }

  /// Set the user ID and load their chat history
  Future<void> setUserId(String userId) async {
    _userId = userId;
    _messages.clear();
    await loadHistory(userId);
  }

  /// Clear the user session
  void clearUserSession() {
    _messages.clear();
    _userId = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear chat history for the given user
  Future<void> clearHistory(String userId) async {
    try {
      final box = Hive.box<String>(PesaTrackAIConstants.hiveChatBoxName);

      // Get all keys for messages belonging to this user
      final keysToDelete = <String>[];
      for (final key in box.keys) {
        final jsonString = box.get(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final message = AIMessage.fromJson(json);
            if (message.userId == userId) {
              keysToDelete.add(key);
            }
          } catch (e) {
            // Skip malformed messages
          }
        }
      }

      // Delete all messages for this user
      for (final key in keysToDelete) {
        await box.delete(key);
      }

      _messages.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history';
      notifyListeners();
    }
  }
}
