import 'dart:async';

import 'package:get/get.dart';

import '../data/models/app_notification.dart';
import '../data/services/api_service.dart';
import '../data/services/local_notifications_service.dart';
import 'auth_controller.dart';

/// Global notification hub. Polls the backend every 30s (mirrors the web bell's
/// poll), keeps the unread count + list fresh, and raises a local OS popup when
/// a genuinely new notification arrives — including the "new case created"
/// alert every employee receives.
class NotificationCenterController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  static const _pollInterval = Duration(seconds: 30);

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Timer? _timer;
  int? _lastSeenMaxId;

  String? get _token => _auth.session.value?.token;

  @override
  void onInit() {
    super.onInit();
    if (_auth.isLoggedIn) start();
  }

  /// Called on login (and at startup if already authenticated).
  void start() {
    _lastSeenMaxId = null;
    reload();
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => reload(silent: true));
  }

  /// Called on logout.
  void stop() {
    _timer?.cancel();
    _timer = null;
    notifications.clear();
    unreadCount.value = 0;
    _lastSeenMaxId = null;
  }

  Future<void> reload({bool silent = false}) async {
    final token = _token;
    if (token == null) return;

    if (!silent) isLoading.value = true;
    try {
      final list = await _apiService.getNotifications(token);
      notifications.assignAll(list);
      unreadCount.value = list.where((n) => !n.isRead).length;
      _maybePopup(list);
      errorMessage.value = null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await _auth.logout();
        return;
      }
      if (!silent) errorMessage.value = e.toString();
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  void _maybePopup(List<AppNotification> list) {
    if (list.isEmpty) return;
    final maxId = list.map((n) => n.id).reduce((a, b) => a > b ? a : b);

    // First load just establishes a baseline so we don't pop on startup.
    if (_lastSeenMaxId == null) {
      _lastSeenMaxId = maxId;
      return;
    }

    final fresh = list.where((n) => n.id > _lastSeenMaxId! && !n.isRead).toList();
    for (final n in fresh) {
      LocalNotificationsService.instance.show(
        id: n.id,
        title: _titleFor(n.type),
        body: n.message,
      );
    }
    if (maxId > _lastSeenMaxId!) _lastSeenMaxId = maxId;
  }

  String _titleFor(String type) {
    switch (type) {
      case 'CaseCreated':
        return 'New case';
      case 'CaseForwarded':
        return 'Case forwarded to you';
      case 'ForwardAccepted':
        return 'Forward accepted';
      case 'ForwardDeclined':
        return 'Forward declined';
      case 'FollowUpReminder':
        return 'Follow-up reminder';
      default:
        return 'Notification';
    }
  }

  Future<void> markRead(int id) async {
    final token = _token;
    if (token == null) return;
    try {
      await _apiService.markNotificationRead(token, id);
      await reload(silent: true);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final token = _token;
    if (token == null) return;
    try {
      await _apiService.markAllNotificationsRead(token);
      await reload(silent: true);
    } catch (_) {}
  }

  Future<void> delete(int id) async {
    final token = _token;
    if (token == null) return;
    try {
      await _apiService.deleteNotification(token, id);
      await reload(silent: true);
    } catch (_) {}
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
