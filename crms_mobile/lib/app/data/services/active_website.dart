/// Process-wide holder for the active website id. ApiService reads it to stamp
/// the `X-Website-Id` header on every request; AuthController is the only writer
/// (on login, cold start, and website switch). Kept separate from AuthController
/// so ApiService doesn't need to depend on it.
class ActiveWebsite {
  ActiveWebsite._();

  static int? id;
}
