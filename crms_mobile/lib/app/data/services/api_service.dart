import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/case_detail.dart';
import '../models/case_summary.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/procedure.dart';
import '../models/referral_source.dart';
import '../models/user_session.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Thrown on a 401 response. Callers should catch this and log the user out
/// (mirrors the auto-redirect-to-login behavior of apiRequest in api.js).
class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Your session has expired. Please sign in again.');
}

class ApiService {
  Future<UserSession> login(String username, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
    } catch (_) {
      throw ApiException('Unable to reach the server. Please try again.');
    }

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (response.statusCode != 200) {
      throw ApiException(data?['message'] as String? ?? 'Invalid username or password.');
    }

    return UserSession.fromJson(data!);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final encodedBody = body != null ? jsonEncode(body) : null;

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: encodedBody);
          break;
        default:
          throw ArgumentError('Unsupported method $method');
      }
    } on ArgumentError {
      rethrow;
    } catch (_) {
      throw ApiException('Unable to reach the server. Please try again.');
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode == 204 || response.body.isEmpty) {
      return null;
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractErrorMessage(data));
    }

    return data;
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['errors'] is Map) {
        final messages = (data['errors'] as Map)
            .values
            .expand((v) => v is List ? v : [v])
            .map((e) => e.toString());
        if (messages.isNotEmpty) return messages.join(' ');
      }
    }
    return 'Something went wrong. Please try again.';
  }

  // ---------- Users ----------

  Future<List<AppUser>> getUsers(String token) async {
    final data = await _request('GET', '/users', token: token) as List;
    return data.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppUser> createUser(
    String token, {
    required String username,
    required String password,
    required String role,
  }) async {
    final data = await _request('POST', '/users', token: token, body: {
      'username': username,
      'password': password,
      'role': role,
    });
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  Future<AppUser> updateUser(
    String token,
    int id, {
    required String username,
    required String role,
    required bool notifyOnNewCase,
  }) async {
    final data = await _request('PUT', '/users/$id', token: token, body: {
      'username': username,
      'role': role,
      'notifyOnNewCase': notifyOnNewCase,
    });
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  Future<void> resetUserPassword(String token, int id, String newPassword) =>
      _request('PUT', '/users/$id/password', token: token, body: {'newPassword': newPassword});

  Future<void> setUserStatus(String token, int id, bool isActive) =>
      _request('PATCH', '/users/$id/status', token: token, body: {'isActive': isActive});

  // ---------- Departments ----------

  Future<List<Department>> getDepartments(String token) async {
    final data = await _request('GET', '/departments', token: token) as List;
    return data.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Department>> getDepartmentsManage(String token) async {
    final data = await _request('GET', '/departments/manage', token: token) as List;
    return data.map((e) => Department.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Department> createDepartment(String token, String name) async {
    final data = await _request('POST', '/departments', token: token, body: {'name': name});
    return Department.fromJson(data as Map<String, dynamic>);
  }

  Future<Department> updateDepartment(String token, int id, String name) async {
    final data = await _request('PUT', '/departments/$id', token: token, body: {'name': name});
    return Department.fromJson(data as Map<String, dynamic>);
  }

  Future<void> setDepartmentStatus(String token, int id, bool isActive) =>
      _request('PATCH', '/departments/$id/status', token: token, body: {'isActive': isActive});

  // ---------- Referral sources ----------

  Future<List<ReferralSource>> getReferralSources(String token) async {
    final data = await _request('GET', '/referral-sources', token: token) as List;
    return data.map((e) => ReferralSource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ReferralSource>> getReferralSourcesManage(String token) async {
    final data = await _request('GET', '/referral-sources/manage', token: token) as List;
    return data.map((e) => ReferralSource.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReferralSource> createReferralSource(String token, String name) async {
    final data = await _request('POST', '/referral-sources', token: token, body: {'name': name});
    return ReferralSource.fromJson(data as Map<String, dynamic>);
  }

  Future<ReferralSource> updateReferralSource(String token, int id, String name) async {
    final data = await _request('PUT', '/referral-sources/$id', token: token, body: {'name': name});
    return ReferralSource.fromJson(data as Map<String, dynamic>);
  }

  Future<void> setReferralSourceStatus(String token, int id, bool isActive) =>
      _request('PATCH', '/referral-sources/$id/status', token: token, body: {'isActive': isActive});

  // ---------- Procedures ----------

  Future<List<Procedure>> getProcedures(String token) async {
    final data = await _request('GET', '/procedures', token: token) as List;
    return data.map((e) => Procedure.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Procedure>> getProceduresManage(String token) async {
    final data = await _request('GET', '/procedures/manage', token: token) as List;
    return data.map((e) => Procedure.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Procedure> createProcedure(String token, String name) async {
    final data = await _request('POST', '/procedures', token: token, body: {'name': name});
    return Procedure.fromJson(data as Map<String, dynamic>);
  }

  Future<Procedure> updateProcedure(String token, int id, String name) async {
    final data = await _request('PUT', '/procedures/$id', token: token, body: {'name': name});
    return Procedure.fromJson(data as Map<String, dynamic>);
  }

  Future<void> setProcedureStatus(String token, int id, bool isActive) =>
      _request('PATCH', '/procedures/$id/status', token: token, body: {'isActive': isActive});

  // ---------- Doctors ----------

  Future<List<Doctor>> getDoctors(String token) async {
    final data = await _request('GET', '/doctors', token: token) as List;
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Doctor>> getDoctorsManage(String token) async {
    final data = await _request('GET', '/doctors/manage', token: token) as List;
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Doctor> createDoctor(String token, String name) async {
    final data = await _request('POST', '/doctors', token: token, body: {'name': name});
    return Doctor.fromJson(data as Map<String, dynamic>);
  }

  Future<Doctor> updateDoctor(String token, int id, String name) async {
    final data = await _request('PUT', '/doctors/$id', token: token, body: {'name': name});
    return Doctor.fromJson(data as Map<String, dynamic>);
  }

  Future<void> setDoctorStatus(String token, int id, bool isActive) =>
      _request('PATCH', '/doctors/$id/status', token: token, body: {'isActive': isActive});

  // ---------- Cases ----------

  Future<List<CaseSummary>> getAllCases(String token) async {
    final data = await _request('GET', '/cases/all', token: token) as List;
    return data.map((e) => CaseSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CaseSummary>> getMyCases(String token) async {
    final data = await _request('GET', '/cases/mine', token: token) as List;
    return data.map((e) => CaseSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CaseDetail> getCaseDetail(String token, int id) async {
    final data = await _request('GET', '/cases/$id', token: token);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseSummary> createCase(String token, Map<String, dynamic> payload) async {
    final data = await _request('POST', '/cases', token: token, body: payload);
    return CaseSummary.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseDetail> claimCase(String token, int id) async {
    final data = await _request('POST', '/cases/$id/claim', token: token);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CaseSummary>> getForwardedToMe(String token) async {
    final data = await _request('GET', '/cases/forwarded-to-me', token: token) as List;
    return data.map((e) => CaseSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CaseSummary>> getForwardedByMe(String token) async {
    final data = await _request('GET', '/cases/forwarded-by-me', token: token) as List;
    return data.map((e) => CaseSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CaseDetail> reopenCase(String token, int id) async {
    final data = await _request('POST', '/cases/$id/reopen', token: token);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseDetail> forwardCase(String token, int id, int toUserId, String? note) async {
    final data = await _request('POST', '/cases/$id/forward', token: token, body: {
      'toUserId': toUserId,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseDetail> acceptForward(String token, int id) async {
    final data = await _request('POST', '/cases/$id/accept-forward', token: token);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseDetail> declineForward(String token, int id) async {
    final data = await _request('POST', '/cases/$id/decline-forward', token: token);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<CaseDetail> followUpCase(String token, int id, Map<String, dynamic> payload) async {
    final data = await _request('POST', '/cases/$id/follow-up', token: token, body: payload);
    return CaseDetail.fromJson(data as Map<String, dynamic>);
  }

  // ---------- Notifications ----------

  Future<List<AppNotification>> getNotifications(String token) async {
    final data = await _request('GET', '/notifications', token: token) as List;
    return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadNotificationCount(String token) async {
    final data = await _request('GET', '/notifications/unread-count', token: token);
    return (data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  Future<void> markNotificationRead(String token, int id) =>
      _request('POST', '/notifications/$id/read', token: token);

  Future<void> markAllNotificationsRead(String token) =>
      _request('POST', '/notifications/read-all', token: token);

  Future<void> deleteNotification(String token, int id) =>
      _request('DELETE', '/notifications/$id', token: token);
}
