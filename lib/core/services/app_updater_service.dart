import 'dart:io' show Platform;

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../constants/app_constants.dart';

class AppUpdaterService {
  static bool get isSupported => !kIsWeb && Platform.isWindows;

  static Future<void> initialize() async {
    if (!isSupported) return;
    try {
      await AutoUpdater.instance.setFeedURL(AppConstants.windowsAppcastUrl);
      await AutoUpdater.instance.setScheduledCheckInterval(
        AppConstants.autoUpdateCheckIntervalSeconds,
      );
      await AutoUpdater.instance.checkForUpdates(inBackground: true);
    } catch (_) {
      // Avoid blocking app startup if the update feed is unreachable.
    }
  }

  static Future<void> checkForUpdates() async {
    if (!isSupported) return;
    await AutoUpdater.instance.checkForUpdates(inBackground: false);
  }
}
