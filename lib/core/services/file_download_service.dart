import 'package:background_downloader/background_downloader.dart';
import 'package:lms/core/api_end_point.dart';

class FileDownloadService {
  static final FileDownloader _downloader = FileDownloader();

  /// Initialize background downloader once when the app starts.
  static Future<void> initialize() async {
    await _downloader.start(doTrackTasks: true);
  }

  /// Download file in background.
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    String? token,
    void Function(double progress)? onProgress,
    void Function(TaskStatus status)? onStatus,
  }) async {
    try {
      final completeUrl = _buildCompleteUrl(url);

      print('================================');
      print('DOWNLOAD START');
      print('Original URL: $url');
      print('Complete URL: $completeUrl');
      print('File name: $fileName');
      print('================================');

      final task = DownloadTask(
        url: completeUrl,
        filename: fileName,
        directory: 'lms_resources',
        updates: Updates.statusAndProgress,
        allowPause: true,
        retries: 5,
        headers:
            token != null && token.isNotEmpty
                ? {'Authorization': 'Bearer $token'}
                : null,
      );

      final result = await _downloader.download(
        task,
        onProgress: (progress) {
          print(
            'Download ${task.taskId}: '
            '${(progress * 100).toStringAsFixed(0)}%',
          );

          onProgress?.call(progress);
        },
        onStatus: (status) {
          print('Download ${task.taskId}: $status');

          onStatus?.call(status);
        },
      );

      print('Final download status: ${result.status}');

      if (result.status != TaskStatus.complete) {
        print('Download failed: ${result.status}');

        return null;
      }

      /// Move the completed file to Android Downloads folder.
      final downloadPath = await _downloader.moveToSharedStorage(
        task,
        SharedStorage.downloads,
      );

      if (downloadPath == null) {
        print('Could not move file to Downloads');

        return null;
      }

      print('File saved to: $downloadPath');

      return downloadPath;
    } catch (e, stackTrace) {
      print('Download error: $e');
      print(stackTrace);

      return null;
    }
  }

  /// Creates a valid URL.
  ///
  /// Example:
  ///
  /// base:
  /// https://example.com/api
  ///
  /// path:
  /// /resources/test.pdf
  ///
  /// result:
  /// https://example.com/api/resources/test.pdf
  static String _buildCompleteUrl(String url) {
    String cleanUrl = url.trim();

    /// Already a complete URL.
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    /// Remove leading `/`
    cleanUrl = cleanUrl.replaceFirst(RegExp(r'^/+'), '');

    /// Remove trailing `/` from base URL.
    final baseUrl = ApiEndPoint.serverUrl.replaceFirst(RegExp(r'/+$'), '');

    return '$baseUrl/$cleanUrl';
  }
}
