import 'package:flutter/material.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/foundation.dart';

class DerivWebViewScreen extends StatefulWidget {
  const DerivWebViewScreen({super.key});

  @override
  State<DerivWebViewScreen> createState() => _DerivWebViewScreenState();
}

class _DerivWebViewScreenState extends State<DerivWebViewScreen> {
  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Scaffold(
      appBar: AppBar(
        title: const Text('derv', style: josefineStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFBA8858)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: EasyWebView(
        src: 'https://app.deriv.com',
        //isHtml: (e) => false,
        isMarkdown: false,
        onLoaded:   (e) {
          if (kDebugMode) {
            debugPrint('Deriv Portal Loaded');
          }
        },
      ),
    );
  }
}
