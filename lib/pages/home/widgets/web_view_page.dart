import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.youtube.com/'));

    return Column(
      children: [
        Expanded(
          child: WebViewWidget(controller: webViewController),
        ),
        Container(
          color: Colors.grey,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  if (await webViewController.canGoBack()) {
                    webViewController.goBack();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  webViewController.reload();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.refresh),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () async {
                  if (await webViewController.canGoForward()) {
                    webViewController.goForward();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
