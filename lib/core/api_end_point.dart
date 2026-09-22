class ApiEndPoint {
  // static const String baseUrl = "http://57.128.119.77:8080/api/";
  static const String baseUrl =
      "https://5c5f-2405-201-e018-b0-4477-a4f0-7177-fd95.ngrok-free.app/api/";

  // static const String serverUrl = 'http://57.128.119.77:8080/';
  static const String serverUrl =
      'https://5c5f-2405-201-e018-b0-4477-a4f0-7177-fd95.ngrok-free.app';

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

  static const String trainerWebinarRecordingsEndPoint =
      "WebinarRecordings/recordings";

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

  // change password
  static const String changePasswordEndPoint = "Auth/change-password";

  // profile image
  static const String profileImageEndPoint = "Users/profile-image";

  ///unread-count
  static const String unreadCountEndPoint = "Notifications/me/unread-count";

  // get contact

  static const String contactUsEndPoint = "ContactUs";

  // get policy

  static const String userPolicyEndPoint = "UserPolicies/active";

  //accept policy

  static const String userPolicyAcceptEndPoint = "UserPolicies/accept";

  // payment
  static const String paymentGateWayAvailableEndPoint =
      "payment-gateways/available";

  // create payment order
  static const String createPaymentOrderEndPoint = "Payments/orders";

  // verify payment
  static const String paymentsVerifyEndPoint = "Payments/verify";
}
