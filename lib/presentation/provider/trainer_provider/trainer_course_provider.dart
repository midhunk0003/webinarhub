import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:background_downloader/background_downloader.dart';
import 'package:lms/data/model/trainer_all_webinar_participents_model/trainer_all_webinar_participents_model.dart';
import 'package:lms/data/model/trainer_webinar_recordings_model/trainer_webinar_recordings_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lms/core/failure.dart';
import 'package:lms/core/services/file_download_service.dart';
import 'package:lms/core/success.dart';

import 'package:lms/data/model/trainer_course_detail_page/trainer_course_detail_page.dart';
import 'package:lms/data/model/trainer_course_meterial_list_model/trainer_course_meterial_list_model.dart';

import 'package:lms/domain/repository/trainer_repo/trainer_course_repository.dart';

enum DownloadResult { success, failed, alreadyDownloading }

class TrainerCourseProvider extends ChangeNotifier {
  final TrainerCourseRepository trainerCourseRepository;

  TrainerCourseProvider({required this.trainerCourseRepository});

  // ============================================================
  // COURSE STATES
  // ============================================================

  bool _isLoading = false;

  bool _isLoadingListOfresource = false;

  bool _isUploadingResource = false;

  bool _isLoadingListOfParticipents = false;

  bool _isLoadingListOfRecordings = false;

  int? _deletingIndex;

  Failure? _failure;

  Success? _success;

  TrainerCourseDetailModel? _trainerCourseDetail;

  TrainerCourseMeterialListModel? _trainerCourseMeterialListModel;

  TrainerAllWebinarParticipentsModel? _trainerAllWebinarParticipentsModel;

  TrainerWebinarRecordingsModel? _trainerWebinarRecordingsModel;

  // ============================================================
  // DOWNLOAD STATES
  // ============================================================

  /// Resource currently downloading.
  String? _downloadingFileName;

  /// Download progress from 0.0 to 1.0.
  double _downloadProgress = 0.0;

  /// Current download status.
  // TaskStatus? _downloadStatus;

  PlatformFile? _selectedFile;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoading => _isLoading;

  bool get isLoadingListOfresource => _isLoadingListOfresource;

  bool get isUploadingResource => _isUploadingResource;

  bool get isLoadingListOfParticipents => _isLoadingListOfParticipents;

  bool get isLoadingListOfRecordings => _isLoadingListOfRecordings;

  int? get deletingIndex => _deletingIndex;

  Failure? get failure => _failure;

  Success? get success => _success;

  TrainerCourseDetailModel? get trainerCourseDetail => _trainerCourseDetail;

  TrainerCourseMeterialListModel? get trainerCourseMeterialListModel =>
      _trainerCourseMeterialListModel;

  TrainerAllWebinarParticipentsModel? get trainerAllWebinarParticipentsModel =>
      _trainerAllWebinarParticipentsModel;

  TrainerWebinarRecordingsModel? get trainerWebinarRecordingsModel =>
      _trainerWebinarRecordingsModel;

  // ============================================================
  // DOWNLOAD GETTERS
  // ============================================================

  String? get downloadingFileName => _downloadingFileName;

  double get downloadProgress => _downloadProgress;

  // TaskStatus? get downloadStatus => _downloadStatus;

  bool get isDownloading => _downloadingFileName != null;

  PlatformFile? get selectedFile => _selectedFile;

  bool get hasSelectedFile => _selectedFile != null;

  // ============================================================
  // FAILURE / SUCCESS
  // ============================================================

  void clearSelectedFile() {
    _selectedFile = null;
    notifyListeners();
  }

  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  void clearSuccess() {
    _success = null;
    notifyListeners();
  }

  // ============================================================
  // COURSE DETAIL
  // ============================================================

  Future<void> getCourseDetailPro(String? courseId) async {
    _isLoading = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await trainerCourseRepository.getCourseDetail(courseId);

    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;

        notifyListeners();
      },
      (success) {
        _trainerCourseDetail = success;
        _isLoading = false;

        notifyListeners();
      },
    );
  }

  // ============================================================
  // RESOURCE LIST
  // ============================================================
  Future<void> getCourseResourceListPro(String? courseId) async {
    _isLoadingListOfresource = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await trainerCourseRepository.getResourceList(courseId);

    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingListOfresource = false;

        notifyListeners();
      },
      (success) {
        _trainerCourseMeterialListModel = success;
        _isLoadingListOfresource = false;

        notifyListeners();
      },
    );
  }

  // ============================================================
  // RECORDINGS LIST
  // ============================================================
  Future<void> getRecordingsListPro(String? courseId) async {
    _isLoadingListOfRecordings = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await trainerCourseRepository.getTrainerWebunarRecordings(
      courseId,
    );

    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingListOfRecordings = false;

        notifyListeners();
      },
      (success) {
        _trainerWebinarRecordingsModel = success;
        _isLoadingListOfRecordings = false;

        notifyListeners();
      },
    );
  }

  // ============================================================
  // UPLOAD RESOURCE
  // ============================================================
  Future<void> uploadResourcePro({
    required String courseId,
    required String file,
  }) async {
    _isUploadingResource = true;
    _failure = null;
    _success = null;
    notifyListeners();

    final result = await trainerCourseRepository.uploadResource(courseId, file);

    result.fold(
      (failure) {
        _failure = failure;
        _isUploadingResource = false;
        notifyListeners();
      },
      (success) async {
        _success = Success(
          message: success.message ?? 'Resource uploaded successfully',
        );

        _isUploadingResource = false;
        notifyListeners();
      },
    );
  }

  // ============================================================
  // DELETE RESOURCE
  // ============================================================
  Future<void> deleteResourcePro({
    required String courseId,
    required index,
  }) async {
    _deletingIndex = index;
    _failure = null;
    _success = null;
    notifyListeners();

    final result = await trainerCourseRepository.deleteResource(courseId);

    result.fold(
      (failure) {
        _failure = failure;
        _deletingIndex = null;
        notifyListeners();
      },
      (success) async {
        _success = Success(
          message: success.message ?? 'Resource delete successfully',
        );
        _deletingIndex = null;
        notifyListeners();
      },
    );
  }

  // ============================================================
  //pic file function
  // ============================================================
  Future<void> pickAndUploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          // Documents
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',

          // Images
          'jpg',
          'jpeg',
          'png',
          'webp',
          'svg',

          // Videos
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
        ],
      );

      if (result == null) {
        return;
      }

      final file = result.files.single;

      log('file picked in:${file}');
      _selectedFile = file;
      notifyListeners();
      if (file.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access selected file')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File selection failed: $e')));
    }
  }

  // Get selected file extension
  String get selectedFileExtension {
    return _selectedFile?.extension?.toLowerCase() ?? '';
  }

  // Get file name
  String get selectedFileName {
    return _selectedFile?.name ?? 'Upload File';
  }

  String extensionLabel(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';

      case 'doc':
      case 'docx':
        return 'Word Document';

      case 'ppt':
      case 'pptx':
        return 'Presentation';

      case 'xls':
      case 'xlsx':
        return 'Excel File';

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'svg':
        return 'Image';

      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return 'Video';

      default:
        return 'File';
    }
  }

  // Get file icon based on extension
  IconData get selectedFileIcon {
    switch (selectedFileExtension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;

      case 'doc':
      case 'docx':
        return Icons.description_rounded;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'svg':
        return Icons.image_rounded;

      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return Icons.video_file_rounded;

      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  // Get file color based on extension
  Color get selectedFileColor {
    switch (selectedFileExtension) {
      case 'pdf':
        return const Color(0xFFE53935);

      case 'doc':
      case 'docx':
        return const Color(0xFF1976D2);

      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7043);

      case 'xls':
      case 'xlsx':
        return const Color(0xFF2E7D32);

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'svg':
        return const Color(0xFF8E44AD);

      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return const Color(0xFF00897B);

      default:
        return const Color(0xFF757575);
    }
  }

  // Get display text
  String get selectedFileLabel {
    if (_selectedFile == null) {
      return 'Upload File';
    }

    return selectedFileName;
  }

  // ============================================================
  // DOWNLOAD RESOURCE
  // ============================================================
  // Future<DownloadResult> downloadResource({
  //   required String url,
  //   required String fileName,
  //   String? token,
  // }) async {
  //   // Prevent multiple simultaneous downloads.
  //   if (isDownloading) {
  //     print(
  //       'Another file is already downloading: '
  //       '$_downloadingFileName',
  //     );

  //     return DownloadResult.alreadyDownloading;
  //   }

  //   _downloadingFileName = fileName;
  //   _downloadProgress = 0.0;
  //   _downloadStatus = TaskStatus.enqueued;

  //   notifyListeners();

  //   try {
  //     final path = await FileDownloadService.downloadFile(
  //       url: url,
  //       fileName: fileName,
  //       token: token,

  //       // Progress
  //       onProgress: (progress) {
  //         _downloadProgress = progress;
  //         notifyListeners();
  //       },

  //       // Status
  //       onStatus: (status) {
  //         _downloadStatus = status;
  //         notifyListeners();
  //       },
  //     );

  //     if (path != null) {
  //       print('Resource downloaded successfully');
  //       print('Path: $path');

  //       _downloadProgress = 1.0;
  //       _downloadStatus = TaskStatus.complete;

  //       notifyListeners();

  //       // Let UI show 100%.
  //       await Future.delayed(const Duration(milliseconds: 500));

  //       return DownloadResult.success;
  //     }

  //     print('Resource download failed');

  //     _downloadStatus = TaskStatus.failed;

  //     notifyListeners();

  //     return DownloadResult.failed;
  //   } catch (e) {
  //     print('Download error: $e');

  //     _downloadStatus = TaskStatus.failed;

  //     notifyListeners();

  //     return DownloadResult.failed;
  //   } finally {
  //     // Clear download state.
  //     _downloadingFileName = null;
  //     _downloadProgress = 0.0;
  //     _downloadStatus = null;

  //     notifyListeners();
  //   }
  // }

  // ============================================================
  // Participants LIST
  // ============================================================
  Future<void> getParticipantsListPro(String? courseId, String? search) async {
    _isLoadingListOfParticipents = true;
    _failure = null;
    _success = null;

    notifyListeners();

    final result = await trainerCourseRepository.getAllParticipants(
      courseId,
      search ?? '',
    );

    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingListOfParticipents = false;

        notifyListeners();
      },
      (success) {
        _trainerAllWebinarParticipentsModel = success;
        _isLoadingListOfParticipents = false;

        notifyListeners();
      },
    );
  }

  // ============================================================
  // ZOOM
  // ============================================================

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('Zoom URL: $meetingUrl');

    final Uri uri = Uri.parse(meetingUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}
