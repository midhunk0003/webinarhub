import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleDriveVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const GoogleDriveVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<GoogleDriveVideoPlayer> createState() => _GoogleDriveVideoPlayerState();
}

class _GoogleDriveVideoPlayerState extends State<GoogleDriveVideoPlayer> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                debugPrint('Page started: $url');

                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              onPageFinished: (url) {
                debugPrint('Page finished: $url');

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onWebResourceError: (error) {
                debugPrint(
                  'WebView error: ${error.errorCode} '
                  '${error.description}',
                );
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
