import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Avatar 3D de medio cuerpo (Three.js dentro de un WebView) que realiza
/// señas LSC por palabra y deletrea como fallback.
/// Es una aproximación visual educativa.
class SignAvatar3D extends StatefulWidget {
  const SignAvatar3D({super.key});

  @override
  State<SignAvatar3D> createState() => SignAvatar3DState();
}

class SignAvatar3DState extends State<SignAvatar3D> {
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
      ..loadFlutterAsset('assets/html/avatar3d.html');
  }

  void signSentence(String text) {
    final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    _controller.runJavaScript("try { signSentence('$escaped'); } catch(e) {}");
  }

  void signWord(String text) {
    final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    _controller.runJavaScript("try { signWord('$escaped'); } catch(e) {}");
  }

  void spell(String text) {
    final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    _controller.runJavaScript("try { spellWord('$escaped'); } catch(e) {}");
  }

  void setAvatarAppearance({int? skinColor, int? shirtColor}) {
    if (skinColor != null) {
      _controller.runJavaScript("try { setAvatarSkin($skinColor); } catch(e) {}");
    }
    if (shirtColor != null) {
      _controller.runJavaScript("try { setAvatarShirt($shirtColor); } catch(e) {}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}