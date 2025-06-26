import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TikTokEmbed extends StatefulWidget {
  final String videoUrl;

  TikTokEmbed({required this.videoUrl});

  @override
  _TikTokEmbedState createState() => _TikTokEmbedState();
}

class _TikTokEmbedState extends State<TikTokEmbed> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0">
  <blockquote class="tiktok-embed" cite="${widget.videoUrl}"
    data-embed-from="oembed" style="max-width: 605px; min-width: 300px; margin:auto">
     <section><a href="${widget.videoUrl}">TikTok Video</a></section>
  </blockquote>
  <script async src="https://www.tiktok.com/embed.js"></script>
</body></html>
''');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 400, child: WebViewWidget(controller: _controller));
  }
}
