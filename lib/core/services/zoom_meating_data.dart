// class ZoomMeetingData {
//   final String meetingNumber;
//   final String password;

//   ZoomMeetingData({required this.meetingNumber, required this.password});
// }

// ZoomMeetingData parseZoomUrl(String zoomUrl) {
//   final uri = Uri.parse(zoomUrl);

//   final segments = uri.pathSegments;

//   String meetingNumber = '';

//   final wcIndex = segments.indexOf('wc');

//   if (wcIndex != -1 && wcIndex + 1 < segments.length) {
//     meetingNumber = segments[wcIndex + 1];
//   }

//   final password = uri.queryParameters['pwd'] ?? '';

//   return ZoomMeetingData(meetingNumber: meetingNumber, password: password);
// }

class ZoomMeetingData {
  final String meetingNumber;
  final String password;

  ZoomMeetingData({required this.meetingNumber, required this.password});
}

ZoomMeetingData parseZoomUrl(String zoomUrl) {
  final uri = Uri.parse(zoomUrl);

  final segments = uri.pathSegments;

  String meetingNumber = '';

  // Zoom meeting link: /j/{meetingId}
  final jIndex = segments.indexOf('j');

  if (jIndex != -1 && jIndex + 1 < segments.length) {
    meetingNumber = segments[jIndex + 1];
  }

  final password = uri.queryParameters['pwd'] ?? '';

  return ZoomMeetingData(meetingNumber: meetingNumber, password: password);
}
