import '../routes/app_routes.dart';

/// Single source of truth for the drawer. Mirrors NAV_ITEMS in nav.js -
/// add new sections here as they're built; set `roles` to restrict an item
/// to specific roles, omit it to show to everyone.
class NavItem {
  final String route;
  final String labelKey;
  final List<String>? roles;

  const NavItem({required this.route, required this.labelKey, this.roles});
}

class NavItems {
  NavItems._();

  static const items = [
    NavItem(route: Routes.dashboard, labelKey: 'nav.dashboard'),
    NavItem(route: Routes.newCase, labelKey: 'nav.newCase'),
    NavItem(route: Routes.forwardedCases, labelKey: 'nav.forwardedToMe'),
    NavItem(route: Routes.forwardedByMe, labelKey: 'nav.forwardedByMe'),
    NavItem(route: Routes.manageLists, labelKey: 'nav.manageLists', roles: ['Admin']),
    NavItem(route: Routes.userManage, labelKey: 'nav.userManagement', roles: ['Admin']),
  ];
}
