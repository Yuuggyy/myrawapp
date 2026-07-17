import 'package:flutter/material.dart';

/// Simple, dependency-free responsive helper for MyRawApp.
///
/// Breakpoints:
/// - mobile  : < 600  (phones — most of RawBank's users)
/// - tablet  : 600–1024
/// - desktop : >= 1024 (tablets landscape / web / Windows desktop build)
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static DeviceType deviceTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return DeviceType.desktop;
    if (width >= tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) => deviceTypeOf(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceTypeOf(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceTypeOf(context) == DeviceType.desktop;
  static bool isTabletOrLarger(BuildContext context) => deviceTypeOf(context) != DeviceType.mobile;

  /// Pick a value depending on the current device type. Falls back gracefully
  /// (desktop -> tablet -> mobile) if a larger breakpoint value isn't provided.
  static T value<T>(BuildContext context, {required T mobile, T? tablet, T? desktop}) {
    switch (deviceTypeOf(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Horizontal page padding that grows a bit on bigger screens.
  static double horizontalPadding(BuildContext context) =>
      value<double>(context, mobile: 20, tablet: 40, desktop: 64);

  /// Content is capped in width on tablet/desktop so cards, text and forms
  /// don't stretch edge to edge on a bigger screen — it stays readable and
  /// centered, like a real banking web app would look.
  static double maxContentWidth(BuildContext context) =>
      value<double>(context, mobile: double.infinity, tablet: 640, desktop: 880);

  /// Number of columns for grids of cards / account tiles / type pickers.
  static int gridColumns(BuildContext context) =>
      value<int>(context, mobile: 2, tablet: 3, desktop: 4);

  /// Clamp the system font scale so a user with huge accessibility text
  /// settings doesn't break card layouts (a real complaint on banking apps).
  static TextScaler clampedTextScaler(BuildContext context) {
    return MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25);
  }
}

/// Wrap a screen's scrollable content with this so it centers and caps its
/// width on tablet/desktop while staying full-bleed on phones. Use it inside
/// the body of a Scaffold, around the main Column/ListView.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveBody({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.maxContentWidth(context);
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    if (maxWidth == double.infinity) return content;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
