import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/presentation/provider/user_provider/my_course_provider.dart';

SvgPicture getIconBasedOnContentHelper({
  required ContentType type,
  String? fileUrl,
}) {
  switch (type) {
    case ContentType.video:
      return SvgPicture.asset(
        'assets/svg/playbutton.svg',
        width: 24,
        height: 24,
      );

    case ContentType.liveClass:
      return SvgPicture.asset('assets/svg/live.svg', width: 24, height: 24);

    case ContentType.quiz:
      return SvgPicture.asset('assets/svg/quiz.svg', width: 24, height: 24);

    case ContentType.assignment:
      return SvgPicture.asset(
        'assets/svg/assignment.svg',
        width: 24,
        height: 24,
      );

    case ContentType.resource:
      return _getResourceIcon(fileUrl);

    case ContentType.unknown:
      return SvgPicture.asset('assets/svg/file.svg', width: 24, height: 24);
  }
}

SvgPicture _getResourceIcon(String? url) {
  if (url == null || url.isEmpty) {
    return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);
  }

  final extension = Uri.parse(url).path.split('.').last.toLowerCase();

  switch (extension) {
    case 'pdf':
      return SvgPicture.asset('assets/svg/pdficon2.svg', width: 24, height: 24);

    case 'doc':
    case 'docx':
      return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);

    case 'ppt':
    case 'pptx':
      return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);

    case 'xls':
    case 'xlsx':
      return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);

    case 'zip':
    case 'rar':
      return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);

    default:
      return SvgPicture.asset('assets/svg/pdficon.svg', width: 24, height: 24);
  }
}
