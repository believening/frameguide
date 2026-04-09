import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/gallery/data/photo_storage.dart';
import '../../features/gallery/presentation/pages/photo_detail_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/pages/shell_page.dart';
import '../../features/learn/presentation/pages/learn_page.dart';
import '../../features/learn/presentation/pages/tip_detail_page.dart';

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
          path: '/learn',
          builder: (context, state) => const LearnPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    // Tip detail page outside shell (full screen)
    GoRoute(
      path: '/learn/tip/:id',
      builder: (context, state) {
        final tipId = state.pathParameters['id'] ?? '';
        return TipDetailPage(tipId: tipId);
      },
    ),
    // Photo detail page (full screen)
    GoRoute(
      path: '/gallery/photo/:id',
      builder: (context, state) {
        // 从 extra 获取 SavedPhoto
        final photo = state.extra as SavedPhoto?;
        if (photo != null) {
          return PhotoDetailPage(photo: photo);
        }
        // fallback: 通过 ID 查找
        final photoId = state.pathParameters['id'] ?? '';
        return PhotoDetailPage(photoId: photoId);
      },
    ),
  ],
);
