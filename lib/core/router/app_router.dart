import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/shell_page.dart';

/// Global camera controllers provider
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

/// Navigation shell key
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration
final appRouter = GoRouter(
  initialLocation: '/camera',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        GoRoute(
          path: '/camera',
          builder: (context, state) => const MainCameraPage(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const GalleryPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
