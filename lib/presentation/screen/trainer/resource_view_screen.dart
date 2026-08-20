import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/core/api_end_point.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResourceViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String? fileType;

  const ResourceViewerScreen({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.fileType,
  });

  @override
  State<ResourceViewerScreen> createState() => _ResourceViewerScreenState();
}

class _ResourceViewerScreenState extends State<ResourceViewerScreen> {
  WebViewController? _webViewController;

  String get resolvedFileUrl {
    final url = widget.fileUrl.trim();

    if (url.isEmpty) {
      return '';
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/')) {
      return '${ApiEndPoint.serverUrl}$url';
    }

    return '${ApiEndPoint.serverUrl}/$url';
  }

  @override
  void initState() {
    super.initState();

    final extension = _getExtension();

    if (_isOfficeFile(extension)) {
      _initializeOfficeViewer();
    }
  }

  void _initializeOfficeViewer() {
    final officeUrl =
        'https://view.officeapps.live.com/op/embed.aspx?src='
        '${Uri.encodeComponent(resolvedFileUrl)}';

    debugPrint('Original file URL: $resolvedFileUrl');
    debugPrint('Office viewer URL: $officeUrl');

    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                debugPrint('WebView progress: $progress%');
              },
              onPageStarted: (url) {
                debugPrint('Page started: $url');
              },
              onPageFinished: (url) {
                debugPrint('Page finished: $url');
              },
              onHttpError: (error) {
                debugPrint('HTTP error: ${error.response?.statusCode}');
              },
              onWebResourceError: (error) {
                debugPrint(
                  'WebView error: '
                  '${error.errorCode} - ${error.description}',
                );
              },
            ),
          )
          ..loadRequest(Uri.parse('${officeUrl}'));
  }

  String _getExtension() {
    final name = widget.fileName.toLowerCase();

    if (name.contains('.')) {
      return name.split('.').last;
    }

    return widget.fileType?.toLowerCase().replaceAll('.', '') ?? '';
  }

  bool _isOfficeFile(String extension) {
    return ['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].contains(extension);
  }

  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  bool _isSvg(String extension) {
    return extension == 'svg';
  }

  @override
  Widget build(BuildContext context) {
    final extension = _getExtension();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildViewer(extension),
    );
  }

  Widget _buildViewer(String extension) {
    // PDF
    if (extension == 'pdf') {
      return SfPdfViewer.network(resolvedFileUrl);
    }

    // JPG / JPEG / PNG / WEBP
    if (_isImageFile(extension)) {
      return InteractiveViewer(
        child: Center(
          child: Image.network(
            resolvedFileUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Center(child: Text('Unable to load image'));
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
    }

    // SVG
    if (_isSvg(extension)) {
      return Center(
        child: SvgPicture.network(
          resolvedFileUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (_) {
            return const CircularProgressIndicator();
          },
        ),
      );
    }

    // DOC / DOCX / PPT / PPTX / XLS / XLSX
    if (_isOfficeFile(extension)) {
      if (_webViewController == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return WebViewWidget(controller: _webViewController!);
    }

    return const Center(
      child: Text('This file type is not supported for in-app viewing.'),
    );
  }
}
