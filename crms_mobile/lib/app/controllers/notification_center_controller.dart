import 'dart:async';

import 'package:get/get.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../data/models/app_notification.dart';
import '../data/services/api_config.dart';
import '../data/services/api_service.dart';
import '../data/services/local_notifications_service.dart';
import 'auth_controller.dart';

/// Global notification hub.
///
/// Opens a SignalR WebSocket connection to /hubs/notifications and receives
/// push events instantly when a notification is created. A 5-minute fallback
/// timer reloads the full list in case the WebSocket is briefly disconnected.
class NotificationCenterController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  HubConnection? _hub;
  Timer? _fallbackTimer;

  // Highest notification id already seen (pushed or loaded) — lets the
  // fallback reload raise OS popups for notifications that arrived while the
  // WebSocket was down, without re-popping ones the push path handled.
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
    _connectHub();
    _fallbackTimer?.cancel();
    // 5-minute reload as safety net for any brief SignalR outage.
    _fallbackTimer = Timer.periodic(const Duration(minutes: 5), (_) => reload(silent: true));
  }

  /// Called on logout.
  void stop() {
    _hub?.stop();
    _hub = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    notifications.clear();
    unreadCount.value = 0;
    _lastSeenMaxId = null;
  }

  Future<void> _connectHub() async {
    final token = _token;
    if (token == null) return;

    _hub?.stop();

    _hub = HubConnectionBuilder()
        .withUrl(
          '${ApiConfig.host}/hubs/notifications',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            // The negotiate HTTP round-trip hangs indefinitely with this
            // client on Android; going straight to a WebSocket (matching
            // what the backend's OnMessageReceived already expects via the
            // access_token query param) skips it entirely.
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .build();

    _hub!.on('NewNotification', (args) {
      if (args == null || args.isEmpty) return;
      try {
        final n = AppNotification.fromJson(args[0] as Map<String, dynamic>);
        notifications.insert(0, n);
        unreadCount.value = unreadCount.value + 1;
        if (_lastSeenMaxId == null || n.id > _lastSeenMaxId!) _lastSeenMaxId = n.id;
        LocalNotificationsService.instance.show(
          id: n.id,
          title: _titleFor(n.type),
          body: n.message,
        );
      } catch (_) {}
    });

    try {
      await _hub!.start();
    } catch (_) {
      // Hub unreachable; fallback timer will keep the list fresh.
    }
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

  // Raises OS popups for notifications first seen via a reload — i.e. ones the
  // SignalR push missed because the socket was down. The first load after
  // start() only establishes a baseline so we don't pop on startup.
  void _maybePopup(List<AppNotification> list) {
    if (list.isEmpty) return;
    final maxId = list.map((n) => n.id).reduce((a, b) => a > b ? a : b);

    if (_lastSeenMaxId == null) {
      _lastSeenMaxId = maxId;
      return;
    }

    final fresh = list.where((n) => n.id > _lastSeenMaxId! && !n.isRead);
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
      notifications.removeWhere((n) => n.id == id);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (_) {}
  }

  @override
  void onClose() {
    _hub?.stop();
    _fallbackTimer?.cancel();
    super.onClose();
  }
}
