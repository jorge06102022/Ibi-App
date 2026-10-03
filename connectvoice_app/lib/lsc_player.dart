import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LscPlayer extends StatefulWidget {
  final String textToSign;

  const LscPlayer({super.key, required this.textToSign});

  @override
  State<LscPlayer> createState() => LscPlayerState();
}

class LscPlayerState extends State<LscPlayer> {
  String _currentImageAsset = '';
  List<String> _sequence = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _processText(widget.textToSign);
  }

  @override
  void didUpdateWidget(LscPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textToSign != widget.textToSign) {
      _processText(widget.textToSign);
    }
  }

  void signSentence(String text) {
    _processText(text);
  }

  Future<void> _processText(String text) async {
    _timer?.cancel();
    if (text.isEmpty) {
      if (mounted) setState(() { _currentImageAsset = ''; });
      return;
    }

    String clean = text.toUpperCase().replaceAll(RegExp(r'[^\w\sÁÉÍÓÚÜÑ]'), '').trim();
    List<String> words = clean.split(RegExp(r'\s+'));
    _sequence = [];

    for (var word in words) {
      if (word.isEmpty) continue;
      String noAccents = _removeAccents(word);
      bool wordExists = await _assetExists('assets/lsc/${noAccents.toLowerCase()}.png');
      if (wordExists) {
        _sequence.add('assets/lsc/${noAccents.toLowerCase()}.png');
        _sequence.add(''); // brief pause
      }
    }

    _playSequence();
  }

  String _removeAccents(String s) {
    const accents = 'ÁÉÍÓÚÜÑ';
    const noAccents = 'AEIOUUN';
    String res = s;
    for (int i = 0; i < accents.length; i++) {
      res = res.replaceAll(accents[i], noAccents[i]);
    }
    return res;
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _playSequence() {
    if (_sequence.isEmpty) {
      if (mounted) setState(() { _currentImageAsset = ''; });
      return;
    }
    
    int index = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index >= _sequence.length) {
        timer.cancel();
        setState(() { _currentImageAsset = ''; });
        return;
      }
      setState(() {
        _currentImageAsset = _sequence[index];
      });
      index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentImageAsset.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "Avatar LSC\n(Esperando...)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          _currentImageAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
