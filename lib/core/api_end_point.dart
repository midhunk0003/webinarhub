class ApiEndPoint {
  static const String baseUrl =
      "https://1e1d-2405-201-e018-b0-e0b5-4327-fd35-6148.ngrok-free.app/api/";

  static const String serverUrl =
      'https://1e1d-2405-201-e018-b0-e0b5-4327-fd35-6148.ngrok-free.app/';

  // login and register
  static const String loginEndPoint = "Auth/login";
  static const String registerEndPoint = "register";

  // get trainer endpoint
  static const String trainerDashUpcommingAndAssignedEndPoint =
      "dashboard/trainer";
  static const String trainerDashOverViewEndPoint = "dashboard/trainer/kpis";
  static const String trainerCourseDetailEndPoint = "Webinars";
  static const String trainerGetListOfResourcesEndPoint =
      "WebinarMaterials/materials";
  static const String trainerUploadResourcesEndPoint =
      "WebinarMaterials/materials";
  static const String trainerdeleteResourcesEndPoint =
      "WebinarMaterials/materials";
  static const String traineAllWebinarEndPoint = "Webinars";

  static const String webinarParticipantsEndPoint =
      "WebinarParticipants/participants";

  // permission
  static const String permissionEndPoint = "Users/permissions";

  // notificationEndPoint
  static const String notificationEndPoint = "Notifications/me";
  static const String NotificationsReadEndPoint = "Notifications/read";

  /// user section
  static const String userDashUpcommingAndAssignedEndPoint = "dashboard/client";
  static const String UserDashOverViewEndPoint = "dashboard/client/kpis";
  static const String userAllWebinarEndPoint = "client/my-webinars";
  static const String userJoinWebinarEndPoint = "client/webinars/join";
  static const String userWebinarRecordingsEndPoint =
      "WebinarRecordings/recordings";

  // refresh token
  static const String refreshTokenEndPoint = "refreshtoken";

  // profile
  static const String profileEndPoint = "Users/me";
  static const String updateProfileEndPoint = "Users/me";
}
