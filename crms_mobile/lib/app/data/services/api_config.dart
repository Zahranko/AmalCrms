/// Base URL for the CRMS backend API.
///
/// The backend is deployed on the hospital LAN at 192.168.1.63:8082 (behind
/// IIS). All mobile platforms hit the same host — there is no localhost /
/// emulator-alias distinction anymore since it's a real network address.
///
/// To point at a different host (e.g. a local dev machine), change the single
/// constant below.
class ApiConfig {
  ApiConfig._();

  static const String host = 'http://192.168.1.63:8082';

  static String get baseUrl => '$host/api';
}
