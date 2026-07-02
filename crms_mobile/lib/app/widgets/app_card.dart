import 'package:flutter/material.dart';

/// The app's standard content card: white, 14px radius, hairline border and a
/// soft shadow — the same style as the case-detail card. Use this instead of
/// raw `Card`/`Container` decorations so every list screen reads as one system.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.color = Colors.white,
    this.borderColor,
    this.onTap,
  });

  static final BorderRadius _radius = BorderRadius.circular(14);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: _radius,
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Transparent Material so ink splashes (InkWell/ListTile) render above
      // the card's background color.
      child: Material(
        color: Colors.transparent,
        borderRadius: _radius,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                borderRadius: _radius,
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
  }
}
