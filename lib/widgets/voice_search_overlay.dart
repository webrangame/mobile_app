import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceSearchOverlay extends StatefulWidget {
  final Function(String) onResult;

  const VoiceSearchOverlay({super.key, required this.onResult});

  @override
  State<VoiceSearchOverlay> createState() => _VoiceSearchOverlayState();
}

class _VoiceSearchOverlayState extends State<VoiceSearchOverlay> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _status = 'Listening...';
  late AnimationController _pulseController;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechToText.stop();
    _silenceTimer?.cancel();
    super.dispose();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() => _status = 'Microphone permission permanently denied.');
      }
      return;
    }

    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            if (status == 'notListening') {
              _status = 'Finished';
            } else if (status == 'listening') {
              _status = 'Listening...';
            }
          });
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() => _status = 'Error: ${errorNotification.errorMsg}');
        }
      },
    );
    if (_speechEnabled) {
      _startListening();
    } else {
      if (mounted) {
        setState(() => _status = 'Speech recognition not available');
      }
    }
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    if (mounted) setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _lastWords = result.recognizedWords;
      });
    }

    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (result.finalResult || _lastWords.isNotEmpty) {
        _handleFinalResult();
      }
    });
  }

  void _handleFinalResult() {
    if (_lastWords.isNotEmpty) {
      Navigator.of(context).pop();
      widget.onResult(_lastWords);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voice Search',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1B25),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFF717171),
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 100 + (20 * _pulseController.value),
                        height: 100 + (20 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4A6CF7).withOpacity(0.1 * (1 - _pulseController.value)),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A6CF7), Color(0xFF2D58E1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 35),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                child: Text(
                  _lastWords.isEmpty ? 'Say something...' : _lastWords,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _lastWords.isEmpty ? Colors.grey : const Color(0xFF1B1B25),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
