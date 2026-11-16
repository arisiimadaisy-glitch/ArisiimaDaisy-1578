import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pesatrack_ai_constants.dart';
import '../../../services/voice_service.dart';
import 'voice_input_button.dart';

/// Widget for text input and message sending in the PesaTrack AI interface
class ChatInputArea extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final bool isLoading;
  final VoiceService voiceService;

  const ChatInputArea({
    required this.onSendMessage,
    required this.voiceService,
    this.isLoading = false,
    super.key,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  late final TextEditingController _controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    try {
      await widget.voiceService.initializeSpeechRecognizer();
    } catch (e) {
      debugPrint('Voice initialization failed: $e');
    }
  }

  void _handleVoiceInput() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (_isRecording) {
      // Stop recording
      try {
        await widget.voiceService.stopListening();
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
        }
      } catch (e) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to stop recording. Please try again or type manually.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Start recording
      final available = await widget.voiceService.isVoiceRecognitionAvailable();
      if (!available) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Microphone not available on this device'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (!await widget.voiceService.hasPermission) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Please grant microphone permission in Settings'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _isRecording = true;
      });

      try {
        final result = await widget.voiceService.recordAndTranscribe(
          onPartialResult: (text) {
            if (mounted) {
              setState(() {
                _controller.text = text;
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isRecording = false;
              });
            }
          },
        );

        if (result == null || result.isEmpty) {
          messenger?.showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to transcribe audio. Please try again or type manually.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
          messenger?.showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to transcribe audio. Please try again or type manually.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isLoading && !_isRecording,
              decoration: InputDecoration(
                hintText: PesaTrackAIConstants.chatInputPlaceholder,
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppConstants.ugandaGreen,
                    width: 2,
                  ),
                ),
                suffixIcon: VoiceInputButton(
                  isRecording: _isRecording,
                  onPressed: _handleVoiceInput,
                ),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : _sendMessage,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.send_rounded,
                  color: widget.isLoading
                      ? Colors.grey.shade400
                      : AppConstants.ugandaGreen,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
