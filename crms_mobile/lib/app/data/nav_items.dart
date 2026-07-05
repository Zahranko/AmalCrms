import '../routes/app_routes.dart';

/// Single source of truth for the drawer. Mirrors WEBSITE_NAV / ADMIN_CONTROL_NAV
/// in nav.js — items depend on the active website's key and the user's role.
class NavItem {
  final String route;
  final String labelKey;
  final List<String>? roles;

  const NavItem({required this.route, required this.labelKey, this.roles});
}

class NavItems {
  NavItems._();

  // The full CRM (`crms` website).
  static const _crms = [
    NavItem(route: Routes.adminDashboard, labelKey: 'nav.dashboard', roles: ['Admin']),
    NavItem(route: Routes.dashboard, labelKey: 'nav.cases', roles: ['Admin']),
    NavItem(route: Routes.dashboard, labelKey: 'nav.dashboard', roles: ['Employee', 'Manager']),
    NavItem(route: Routes.newCase, labelKey: 'nav.newCase', roles: ['Employee', 'Manager', 'Admin']),
    NavItem(route: Routes.forwardedCases, labelKey: 'nav.forwardedToMe', roles: ['Employee', 'Manager', 'Admin']),
    NavItem(route: Routes.forwardedByMe, labelKey: 'nav.forwardedByMe', roles: ['Employee', 'Manager', 'Admin']),
    NavItem(route: Routes.hospitalManagerDashboard, labelKey: 'nav.dashboard', roles: ['HospitalManager']),
    NavItem(route: Routes.hospitalManagerDashboard, labelKey: 'nav.hospitalReport', roles: ['Admin']),
  ];

  // The `contact` placeholder website.
  static const _contact = [
    NavItem(route: Routes.contact, labelKey: 'nav.contact', roles: ['Employee', 'Manager', 'Admin', 'HospitalManager']),
  ];

  // Admin control items — shown for Admin inside every website; they act on
  // whichever website is currently active.
  static const _adminControl = [
    NavItem(route: Routes.manageLists, labelKey: 'nav.manageLists', roles: ['Admin']),
    NavItem(route: Routes.userManage, labelKey: 'nav.userManagement', roles: ['Admin']),
    NavItem(route: Routes.systemParams, labelKey: 'nav.systemParams', roles: ['Admin']),
  ];

  static List<NavItem> itemsFor(String? websiteKey, String? role) {
    final base = websiteKey == 'contact' ? _contact : _crms;
    final items = base.where((i) => i.roles == null || i.roles!.contains(role)).toList();
    if (role == 'Admin') {
      items.addAll(_adminControl.where((i) => i.roles == null || i.roles!.contains(role)));
    }
    return items;
  }
}
