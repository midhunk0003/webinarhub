import 'package:flutter/material.dart';
import 'package:lms/core/failure.dart';
import 'package:lms/core/success.dart';
import 'package:lms/data/model/trainer_full_list_webinar_model/trainer_full_list_webinar_model.dart';
import 'package:lms/data/model/trainer_over_view_model/trainer_over_view_model.dart';
import 'package:lms/data/model/trainer_upcomming_and_assigned_model/trainer_upcomming_and_assigned_model.dart';
import 'package:lms/data/model/wbinar_permissions_model/wbinar_permissions_model.dart';
import 'package:lms/domain/repository/permission_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_dashboard_repository.dart';
import 'package:lms/domain/repository/trainer_repo/trainer_webinar_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionRepository permissionRepository;

  PermissionProvider({required this.permissionRepository});

  bool _isLoadingPermission = false;
  Failure? _failure;
  Success? _success;
  WbinarPermissionsModel? _permissionsModel;

  // getter

  bool get isLoadingPermission => _isLoadingPermission;
  Failure? get failure => _failure;
  Success? get success => _success;
  WbinarPermissionsModel? get permissionsModel => _permissionsModel;

  // ================= PERMISSION CHECK =================

  bool hasPermission(String permission) {
    final permissions = _permissionsModel?.data?.effectivePermissions ?? [];

    return permissions.contains(permission);
  }

  bool get canViewMaterials => hasPermission('WebinarMaterials.View');

  bool get canDeleteMaterials => hasPermission('WebinarMaterials.Delete');

  bool get canUploadMaterials => hasPermission('WebinarMaterials.Upload');

  bool get canViewParticipents => hasPermission('WebinarParticipants.View');

  bool get canViewWebinarRecordings => hasPermission('WebinarRecordings.View');

  // functions

  void clearFailure() {
    _failure = null;
    print('aaaaaaaaaaaa');
    notifyListeners();
  }

  void clearSuccess() {
    _success = null;
    notifyListeners();
  }

  Future<void> getPermissionPro() async {
    _isLoadingPermission = true;
    _failure = null;
    _success = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      _failure = ClientFailure('User ID not found');
      _isLoadingPermission = false;
      notifyListeners();
      return;
    }

    print('UseId : : :  ${userId}');
    final result = await permissionRepository.getPermisionData(userId);
    result.fold(
      (failure) {
        _failure = failure;
        _isLoadingPermission = false;
        notifyListeners();
      },
      (success) {
        _permissionsModel = success;
        _isLoadingPermission = false;
        notifyListeners();
      },
    );
  }

  Future<void> launchZoomMeeting(String meetingUrl) async {
    print('sssssssssssssss : ${meetingUrl}');
    final Uri uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Zoom meeting');
    }
  }
}
