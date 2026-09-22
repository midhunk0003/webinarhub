import 'package:flutter/services.dart';

class ZoomService {
  static const MethodChannel _channel = MethodChannel('lms.zoom');

  static Future<bool> joinMeeting({
    required String meetingNumber,
    required String meetingPassword,
    required String userName,
  }) async {
    final result = await _channel.invokeMethod('joinZoomMeeting', {
      'meetingNumber': meetingNumber,
      'meetingPassword': meetingPassword,
      'userName': userName,
    });

    return result == true;
  }
}
