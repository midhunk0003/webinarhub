import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:lms/data/local_data_source/local_data_sourse.dart';
import 'package:lms/data/repository_implimentation/auth_repo_implimentation.dart';
import 'package:lms/data/repository_implimentation/permission_repo_implimentation.dart';
import 'package:lms/data/repository_implimentation/profile_repo_implimenttation.dart';
import 'package:lms/data/repository_implimentation/trainer_repo_impli/trainer_all_webinar_implomentation.dart';
import 'package:lms/data/repository_implimentation/trainer_repo_impli/trainer_course_implimentation.dart';
import 'package:lms/data/repository_implimentation/trainer_repo_impli/trainer_dashboard_implimentation.dart';
import 'package:lms/data/repository_implimentation/user_repo_impli/user_all_webinar_implimentation.dart';
import 'package:lms/data/repository_implimentation/user_repo_impli/user_course_implimentation.dart';
import 'package:lms/data/repository_implimentation/user_repo_impli/user_dashboard_implimentation.dart';
import 'package:lms/domain/repository/permission_repository.dart';
import 'package:lms/domain/repository/profile_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_course_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_webinar_repository.dart';
import 'package:lms/domain/repository/user_repo/user_course_repository.dart';
import 'package:lms/domain/repository/user_repo/user_dashboard_repository.dart';
import 'package:lms/domain/repository/user_repo/user_webinar_repository.dart';
import 'package:lms/firebasemessagingservice.dart';
import 'package:lms/presentation/provider/permission_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_all_webinar_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_course_provider.dart';
import 'package:lms/presentation/provider/trainer_provider/trainer_dashboard_provider.dart';
import 'package:lms/presentation/provider/user_provider/profile_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_all_wbinar_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_course_provider.dart';
import 'package:lms/presentation/provider/user_provider/user_dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:lms/data/network/api_client.dart';

import 'package:lms/domain/repository/auth_repository.dart';

import 'package:lms/presentation/provider/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ================= FCM =================
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );

  /// ================= HTTP CLIENT =================
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  /// ================= SHARED PREFS =================
  final prefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  /// ================= SECURE STORAGE =================
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  /// ================= API CLIENT =================
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: getIt<http.Client>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  /// ================= LOCAL DATASOURCE =================
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      secureStorage: getIt<FlutterSecureStorage>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  /// ================= REPOSITORY and implimentation register =================

  // auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplimentation(
      apiClient: getIt<ApiClient>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // trainer dashboard
  getIt.registerLazySingleton<TrainerDashboardRepository>(
    () => TrainerDashboardImplimentation(apiClient: getIt<ApiClient>()),
  );

  // trainer course detail
  getIt.registerLazySingleton<TrainerCourseRepository>(
    () => TrainerCourseImplimentation(apiClient: getIt<ApiClient>()),
  );

  // trainer all webinar
  getIt.registerLazySingleton<TrainerWebinarRepository>(
    () => TrainerAllWebinarImplomentation(apiClient: getIt<ApiClient>()),
  );

  // Permissiom
  getIt.registerLazySingleton<PermissionRepository>(
    () => PermissionRepoImplimentation(apiClient: getIt<ApiClient>()),
  );

  // user dash repo
  getIt.registerLazySingleton<UserDashboardRepository>(
    () => UserDashboardImplimentation(apiClient: getIt<ApiClient>()),
  );

  // user all webinar repo
  getIt.registerLazySingleton<UserWebinarRepository>(
    () => UserAllWebinarImplimentation(apiClient: getIt<ApiClient>()),
  );

  // user course webinar repo
  getIt.registerLazySingleton<UserCourseRepository>(
    () => UserCourseImplimentation(apiClient: getIt<ApiClient>()),
  );

  // user course webinar repo
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepoImplimenttation(apiClient: getIt<ApiClient>()),
  );

  /// ================= PROVIDER Register=================
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      authRepository: getIt<AuthRepository>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      firebaseMessagingService: getIt<FirebaseMessagingService>(),
    ),
  );

  // trainer dashboard
  getIt.registerFactory<TrainerDashboardProvider>(
    () => TrainerDashboardProvider(
      trainerDashboardRepository: getIt<TrainerDashboardRepository>(),
    ),
  );

  // trainer course
  getIt.registerFactory<TrainerCourseProvider>(
    () => TrainerCourseProvider(
      trainerCourseRepository: getIt<TrainerCourseRepository>(),
    ),
  );

  // trainer webinar provider
  getIt.registerFactory<TrainerAllWebinarProvider>(
    () => TrainerAllWebinarProvider(
      trainerWebinarRepository: getIt<TrainerWebinarRepository>(),
    ),
  );

  // Permission provider
  getIt.registerFactory<PermissionProvider>(
    () =>
        PermissionProvider(permissionRepository: getIt<PermissionRepository>()),
  );

  // user Dash provider
  getIt.registerFactory<UserDashboardProvider>(
    () => UserDashboardProvider(
      userDashboardRepository: getIt<UserDashboardRepository>(),
      userCourseRepository: getIt<UserCourseRepository>(),
      profileRepository: getIt<ProfileRepository>(),
    ),
  );

  // user all webinar provider
  getIt.registerFactory<UserAllWbinarProvider>(
    () => UserAllWbinarProvider(
      userWebinarRepository: getIt<UserWebinarRepository>(),
    ),
  );

  // user course  webinar provider
  getIt.registerFactory<UserCourseProvider>(
    () =>
        UserCourseProvider(userCourseRepository: getIt<UserCourseRepository>()),
  );

  // user course  webinar provider
  getIt.registerFactory<ProfileProvider>(
    () => ProfileProvider(profileRepository: getIt<ProfileRepository>()),
  );
}
