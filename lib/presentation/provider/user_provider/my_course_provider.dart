import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContinueLearningModel {
  final String title;
  final String image;
  final double progress;

  ContinueLearningModel({
    required this.title,
    required this.image,
    required this.progress,
  });
}

class CourseModel {
  final String id;
  final String title;
  final String thumbnail;
  final List<ModuleModel> modules;

  CourseModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.modules,
  });
}

class ModuleModel {
  final String id;
  final String title;
  final bool isCompleted;
  final List<ModuleContentModel> contents;

  ModuleModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.contents,
  });
}

enum ContentType { video, liveClass, resource, quiz, assignment, unknown }

class ModuleContentModel {
  final String id;
  final String title;
  final ContentType type;

  // Recorded Video
  final String? videoId; // YouTube Video ID

  final String? instructor;
  final String? duration;

  final DateTime? liveDate;
  final String? meetingUrl;

  final String? fileUrl;

  final bool isCompleted;
  final bool isLocked;

  ModuleContentModel({
    required this.id,
    required this.title,
    required this.type,
    this.videoId,
    this.instructor,
    this.duration,
    this.liveDate,
    this.meetingUrl,
    this.fileUrl,
    this.isCompleted = false,
    this.isLocked = false,
  });
}

class ResourceModel {
  final String id;
  final String title;
  final List<ResourceContentModel> resourceContents;

  ResourceModel({
    required this.id,
    required this.title,
    required this.resourceContents,
  });
}

class ResourceContentModel {
  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final ContentType type;
  final String fileSize;

  ResourceContentModel({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.type,
    required this.fileSize,
  });
}

class MyCourseProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<ContinueLearningModel> _continueLearningList = [];
  List<ResourceModel> _resources = [];
  CourseModel? _courseModule;
  int? _indexShowModuleContent;
  int? _indexShowResourceContent;
  // getter
  bool get isLoading => _isLoading;
  List<ResourceModel> get resources => _resources;
  List<ContinueLearningModel> get continueLearningList => _continueLearningList;
  CourseModel? get courseModule => _courseModule;
  int? get indexShowModuleContent => _indexShowModuleContent;
  int? get indexShowResourceContent => _indexShowResourceContent;

  void showModuleContent(index) {
    if (_indexShowModuleContent == index) {
      _indexShowModuleContent = null;
      notifyListeners();
    } else {
      _indexShowModuleContent = index;
      notifyListeners();
    }
  }

  void showResourceContent(int index) {
    if (_indexShowResourceContent == index) {
      _indexShowResourceContent = null;
    } else {
      _indexShowResourceContent = index;
    }
    notifyListeners();
  }

  Future<void> getMyCoursesPro() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2));
    _continueLearningList = [
      ContinueLearningModel(
        title: 'The Psychology of Relationships',
        image: 'assets/images/imgclearn.png',
        progress: 0.7,
      ),

      ContinueLearningModel(
        title: 'Flutter UI Masterclass',
        image: 'assets/images/imgclearn.png',
        progress: 0.5,
      ),

      ContinueLearningModel(
        title: 'Business Management Basics',
        image: 'assets/images/imgclearn.png',
        progress: 0.9,
      ),

      ContinueLearningModel(
        title: 'Digital Marketing Strategy',
        image: 'assets/images/imgclearn.png',
        progress: 0.3,
      ),

      ContinueLearningModel(
        title: 'Complete Web Development',
        image: 'assets/images/imgclearn.png',
        progress: 0.8,
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  // lecture recorded class
  Future<void> getCourseModule(String courseId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _courseModule = CourseModel(
      id: '001',
      title: "Psychology of Relationships",
      thumbnail: "assets/images/imgclearn.png",
      modules: [
        ModuleModel(
          id: "1",
          title: "Module 1: Foundations of Human Connection",
          isCompleted: true,
          contents: [
            ModuleContentModel(
              id: "1",
              title: "1.1 The Evolutionary Roots of Bonding",
              instructor: "Dr. Arya Sharma",
              duration: "15 min",
              type: ContentType.video,
              videoId: "https://youtu.be/CV_J-otoEpI?si=-a_MVI1xI4XQ07zl",
            ),

            ModuleContentModel(
              id: "2",
              title: "1.2 Attachment Theory: Understanding Your Style",
              instructor: "Prof. John Lee",
              duration: "20 min",
              type: ContentType.video,
              videoId: "https://youtu.be/uM1OIP3ag7M",
            ),

            ModuleContentModel(
              id: "3",
              title: "1.3 The Role of Empathy in Connection",
              instructor: "Dr. Lisa Wong",
              duration: "25 min",
              type: ContentType.video,
              videoId: "https://youtu.be/jmyxWcnJ4zs",
            ),

            ModuleContentModel(
              id: "4",
              title: "Weekly Live Class",
              type: ContentType.liveClass,
              liveDate: DateTime.now().add(const Duration(days: 1)),
              meetingUrl:
                  "https://us05web.zoom.us/j/83058407196?pwd=6wDaFgj8mtxNnZ6HJot7IzIab9WU1d.1",
            ),

            ModuleContentModel(
              id: "5",
              title: "Module Notes",
              type: ContentType.resource,
              fileUrl: "assets/files/module1.pdf",
            ),

            ModuleContentModel(
              id: "6",
              title: "Quiz 1",
              type: ContentType.quiz,
            ),

            ModuleContentModel(
              id: "7",
              title: "Assignment 1",
              type: ContentType.assignment,
            ),
          ],
        ),

        ModuleModel(
          id: "2",
          title: "Module 2: Building Healthy Relationships",
          contents: [
            ModuleContentModel(
              id: "8",
              title: "2.1 Communication Skills",
              instructor: "Dr. Arya Sharma",
              duration: "18 min",
              type: ContentType.video,
              videoId: "dQw4w9WgXcQ",
            ),

            ModuleContentModel(
              id: "9",
              title: "2.2 Active Listening",
              instructor: "Dr. Arya Sharma",
              duration: "22 min",
              type: ContentType.video,
              videoId: "https://youtu.be/example1",
            ),

            ModuleContentModel(
              id: "10",
              title: "Module 2 Live Session",
              type: ContentType.liveClass,
              liveDate: DateTime.now().add(const Duration(days: 3)),
              meetingUrl: "https://zoom.us/j/example",
            ),

            ModuleContentModel(
              id: "11",
              title: "Module 2 Notes",
              type: ContentType.resource,
              fileUrl: "assets/files/module2.pdf",
            ),

            ModuleContentModel(
              id: "12",
              title: "Quiz 2",
              type: ContentType.quiz,
            ),

            ModuleContentModel(
              id: "13",
              title: "Assignment 2",
              type: ContentType.assignment,
            ),
          ],
        ),
      ],
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCourseResources(String courseId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _resources = [
      ResourceModel(
        id: "1",
        title: "Module 1: Foundations of Human Connection",
        resourceContents: [
          ResourceContentModel(
            id: "1",
            title: "Module 1 Notes",
            description: "Complete lecture notes",
            fileUrl: "https://example.com/module1_notes.pdf",
            type: ContentType.resource,
            fileSize: "2.4 MB",
          ),
          ResourceContentModel(
            id: "2",
            title: "Student Workbook",
            description: "Practice exercises",
            fileUrl: "https://example.com/workbook.docx",
            type: ContentType.resource,
            fileSize: "5.8 MB",
          ),
          ResourceContentModel(
            id: "3",
            title: "Lecture Presentation",
            description: "PowerPoint slides",
            fileUrl: "https://example.com/module1_slides.pptx",
            type: ContentType.resource,
            fileSize: "8.2 MB",
          ),
          ResourceContentModel(
            id: "4",
            title: "Reference Sheet",
            description: "Quick revision guide",
            fileUrl: "https://example.com/reference.pdf",
            type: ContentType.resource,
            fileSize: "1.3 MB",
          ),
        ],
      ),

      ResourceModel(
        id: "2",
        title: "Module 2: Healthy Relationships",
        resourceContents: [
          ResourceContentModel(
            id: "5",
            title: "Communication Guide",
            description: "Reference material",
            fileUrl: "https://example.com/communication.pdf",
            type: ContentType.resource,
            fileSize: "1.8 MB",
          ),
          ResourceContentModel(
            id: "6",
            title: "Role Play Workbook",
            description: "Exercises and activities",
            fileUrl: "https://example.com/roleplay.docx",
            type: ContentType.resource,
            fileSize: "3.9 MB",
          ),
          ResourceContentModel(
            id: "7",
            title: "Class Presentation",
            description: "Slides used during class",
            fileUrl: "https://example.com/module2.pptx",
            type: ContentType.resource,
            fileSize: "7.4 MB",
          ),
        ],
      ),

      ResourceModel(
        id: "3",
        title: "Assignments & Templates",
        resourceContents: [
          ResourceContentModel(
            id: "8",
            title: "Assignment Template",
            description: "Submission template",
            fileUrl: "https://example.com/assignment_template.docx",
            type: ContentType.resource,
            fileSize: "550 KB",
          ),
          ResourceContentModel(
            id: "9",
            title: "Assessment Rubric",
            description: "Marking criteria",
            fileUrl: "https://example.com/rubric.pdf",
            type: ContentType.resource,
            fileSize: "750 KB",
          ),
          ResourceContentModel(
            id: "10",
            title: "Sample Assignment",
            description: "Example submission",
            fileUrl: "https://example.com/sample_assignment.pdf",
            type: ContentType.resource,
            fileSize: "2.1 MB",
          ),
        ],
      ),

      ResourceModel(
        id: "4",
        title: "Downloads",
        resourceContents: [
          ResourceContentModel(
            id: "11",
            title: "Course Data",
            description: "Excel workbook",
            fileUrl: "https://example.com/course_data.xlsx",
            type: ContentType.resource,
            fileSize: "4.7 MB",
          ),
          ResourceContentModel(
            id: "12",
            title: "Course Assets",
            description: "Images and documents",
            fileUrl: "https://example.com/course_assets.zip",
            type: ContentType.resource,
            fileSize: "15.6 MB",
          ),
        ],
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}

extension ContentTypeExtension on String {
  ContentType toContentType() {
    final value = trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');

    switch (value) {
      case 'video':
        return ContentType.video;

      case 'liveclass':
        return ContentType.liveClass;

      case 'resource':
        return ContentType.resource;

      case 'quiz':
        return ContentType.quiz;

      case 'assignment':
        return ContentType.assignment;

      default:
        return ContentType.unknown;
    }
  }
}

extension ContentTypeValue on ContentType {
  String get value {
    switch (this) {
      case ContentType.video:
        return 'video';

      case ContentType.liveClass:
        return 'liveclass';

      case ContentType.resource:
        return 'resource';

      case ContentType.quiz:
        return 'quiz';

      case ContentType.assignment:
        return 'assignment';

      case ContentType.unknown:
        return 'unknown';
    }
  }
}
