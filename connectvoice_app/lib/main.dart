import 'package:flutter/material.dart';
import 'server_gate.dart';
import 'theme.dart';

void main() {
  runApp(const ConnectVoiceApp());
}

class ConnectVoiceApp extends StatelessWidget {
  const ConnectVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IBI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ServerGate(),
    );
  }
}