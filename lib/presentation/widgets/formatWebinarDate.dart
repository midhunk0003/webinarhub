// methods
import 'package:intl/intl.dart';

String formatWebinarDate(String? startDateTime, String? endDateTime) {
  if (startDateTime == null) return "";

  final start = DateTime.parse(startDateTime).toLocal();
  final end =
      endDateTime != null ? DateTime.parse(endDateTime).toLocal() : null;

  final now = DateTime.now();

  final isToday =
      start.year == now.year &&
      start.month == now.month &&
      start.day == now.day;

  final isTomorrow =
      start.year == now.year &&
      start.month == now.month &&
      start.day == now.day + 1;

  final startTime = DateFormat('h:mm a').format(start);
  final endTime = DateFormat('h:mm a').format(end!);

  if (isToday) {
    return "Today • $startTime - $endTime";
  }

  if (isTomorrow) {
    return "Tomorrow • $startTime - $endTime";
  }

  return "${DateFormat('dd MMM').format(start)} • $startTime To $endTime";
}

String formatWebinarDuration(String? startDateTime, String? endDateTime) {
  if (startDateTime == null || endDateTime == null) {
    return "";
  }

  final start = DateTime.parse(startDateTime).toLocal();
  final end = DateTime.parse(endDateTime).toLocal();

  final difference = end.difference(start);

  final hours = difference.inHours;
  final minutes = difference.inMinutes.remainder(60);

  if (hours > 0 && minutes > 0) {
    return "${hours}h ${minutes}m";
  } else if (hours > 0) {
    return "${hours}h";
  } else {
    return "${minutes}m";
  }
}
