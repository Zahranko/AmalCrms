import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_drawer.dart';
import 'app_top_bar.dart';

/// Shared page shell (top bar + drawer) used by every authenticated screen
/// except login. Mirrors the topbar/drawer markup repeated across
/// dashboard.html, userManage.html, customers.html and manageLists.html.
class AppShellScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const AppShellScaffold({super.key, required this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppTopBar(),
      drawer: const AppDrawer(),
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: false, child: body),
    );
  }
}
