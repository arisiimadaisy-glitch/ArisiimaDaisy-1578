import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../core/constants/app_constants.dart';

/// Widget for displaying individual chat messages in the PesaTrack AI chat interface
class ChatMessageBubble extends StatelessWidget {
  final AIMessage message;

  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeString = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? AppConstants.ugandaGreen
                  : const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.message,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              timeString,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
