import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Widget for voice input in the PesaTrack AI interface
class VoiceInputButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isRecording;

  const VoiceInputButton({this.onPressed, this.isRecording = false, super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isRecording) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isRecording && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.isRecording
              ? ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                )
              : Icon(
                  Icons.mic_rounded,
                  color: AppConstants.ugandaGreen,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
