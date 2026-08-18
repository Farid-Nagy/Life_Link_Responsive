import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

abstract final class AppBreakpoints {
  static const double mobile = 450;
  static const double tablet = 800;
  static const double desktop = 1200;
  static const double wide = 1500;
  static const double maxContentWidth = 1440;
}

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const ResponsivePage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < AppBreakpoints.tablet
            ? 16.0
            : constraints.maxWidth < AppBreakpoints.desktop
            ? 24.0
            : 32.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AdaptiveGridDelegate extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double mainAxisExtent;
  final double spacing;

  const AdaptiveGridDelegate({
    super.key,
    required this.children,
    this.minItemWidth = 250,
    this.mainAxisExtent = 210,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth).floor().clamp(
          1,
          6,
        );
        return GridView.builder(
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }
}

/// The package is kept at the application root so all existing screens
/// automatically know which breakpoint they are in.
class AppResponsiveBuilder extends StatelessWidget {
  final Widget child;

  const AppResponsiveBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.builder(
      child: child,
      breakpoints: const [
        Breakpoint(start: 0, end: AppBreakpoints.mobile, name: PHONE),
        Breakpoint(
          start: AppBreakpoints.mobile + 1,
          end: AppBreakpoints.tablet,
          name: TABLET,
        ),
        Breakpoint(
          start: AppBreakpoints.tablet + 1,
          end: AppBreakpoints.desktop,
          name: DESKTOP,
        ),
        Breakpoint(
          start: AppBreakpoints.desktop + 1,
          end: double.infinity,
          name: 'WIDE',
        ),
      ],
    );
  }
}
