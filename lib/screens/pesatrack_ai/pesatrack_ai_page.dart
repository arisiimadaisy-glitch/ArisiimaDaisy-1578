import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/pesatrack_ai_constants.dart';
import '../../services/voice_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/pesatrack_ai_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/chat_input_area.dart';

/// Main PesaTrack AI chat page
class PesaTrackAIPage extends StatefulWidget {
  const PesaTrackAIPage({super.key});

  @override
  State<PesaTrackAIPage> createState() => _PesaTrackAIPageState();
}

class _PesaTrackAIPageState extends State<PesaTrackAIPage> {
  late ScrollController _scrollController;
  late VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _voiceService = VoiceService();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PesaTrack AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF111111)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Your Smart Money Companion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Chat area and quick actions
          Expanded(
            child: Consumer<PesaTrackAIProvider>(
              builder: (context, aiProvider, _) {
                if (aiProvider.messages.isEmpty) {
                  // Welcome screen with quick actions
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 40,
                      ),
                      child: Column(
                        children: [
                          // Greeting
                          Text(
                            PesaTrackAIConstants.greetingMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Quick action cards
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              QuickActionCard(
                                label:
                                    PesaTrackAIConstants.quickActionLabels[0],
                                icon: Icons.add_rounded,
                                onTap: () {
                                  context
                                      .read<PesaTrackAIProvider>()
                                      .sendMessage(
                                        PesaTrackAIConstants
                                            .quickActionLabels[0],
                                      );
                                },
                              ),
                              QuickActionCard(
                                label:
                                    PesaTrackAIConstants.quickActionLabels[1],
                                icon: Icons.analytics_outlined,
                                onTap: () {
                                  context
                                      .read<PesaTrackAIProvider>()
                                      .sendMessage(
                                        PesaTrackAIConstants
                                            .quickActionLabels[1],
                                      );
                                },
                              ),
                              QuickActionCard(
                                label:
                                    PesaTrackAIConstants.quickActionLabels[2],
                                icon: Icons.trending_up_rounded,
                                onTap: () {
                                  context
                                      .read<PesaTrackAIProvider>()
                                      .sendMessage(
                                        PesaTrackAIConstants
                                            .quickActionLabels[2],
                                      );
                                },
                              ),
                              QuickActionCard(
                                label:
                                    PesaTrackAIConstants.quickActionLabels[3],
                                icon: Icons.favorite_outline_rounded,
                                onTap: () {
                                  context
                                      .read<PesaTrackAIProvider>()
                                      .sendMessage(
                                        PesaTrackAIConstants
                                            .quickActionLabels[3],
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Chat messages view
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: aiProvider.messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageBubble(
                        message: aiProvider.messages[index],
                      );
                    },
                  );
                }
              },
            ),
          ),

          // Error message display
          Consumer<PesaTrackAIProvider>(
            builder: (context, aiProvider, _) {
              if (aiProvider.errorMessage != null) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.ugandaRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppConstants.ugandaRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    aiProvider.errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.ugandaRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area
          Consumer<PesaTrackAIProvider>(
            builder: (context, aiProvider, _) {
              return ChatInputArea(
                voiceService: _voiceService,
                onSendMessage: (text) {
                  aiProvider.sendMessage(text);
                  _scrollToBottom();
                },
                isLoading: aiProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}
