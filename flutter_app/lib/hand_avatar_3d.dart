import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mano 3D articulada (Three.js dentro de un WebView) que forma cada
/// seña del abecedario y se anima letra por letra. Es una aproximación
/// geométrica de apoyo, no una traducción oficial ni certificada a LSC.
class HandAvatar3D extends StatefulWidget {
  const HandAvatar3D({super.key});

  @override
  State<HandAvatar3D> createState() => HandAvatar3DState();
}

class HandAvatar3DState extends State<HandAvatar3D> {
  late final WebViewController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) {
          if (mounted) setState(() => _ready = true);
        }),
      )
      ..loadFlutterAsset('assets/html/hand3d.html');
  }

  void spell(String text) {
    final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    _controller.runJavaScript("try { spellWord('$escaped'); } catch(e) {}");
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}