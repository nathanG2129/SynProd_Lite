import 'dart:convert';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../presentation/widgets/synprod_ui.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class AndroidReleaseInfo {
  final String version;
  final String downloadUrl;
  final String? releaseNotes;

  const AndroidReleaseInfo({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
  });
}

class AppUpdaterService {
  static const MethodChannel _androidChannel =
      MethodChannel('com.synprod.synprod_lite/updater');

  static bool _androidBackgroundCheckDone = false;

  static bool get isSupported =>
      !kIsWeb && (Platform.isWindows || Platform.isAndroid);

  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isWindows) return;
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

  static Future<void> checkForUpdates({
    BuildContext? context,
    bool inBackground = false,
  }) async {
    if (!isSupported) return;

    if (Platform.isWindows) {
      if (inBackground) return;
      await AutoUpdater.instance.checkForUpdates(inBackground: false);
      return;
    }

    if (Platform.isAndroid) {
      if (inBackground) {
        if (_androidBackgroundCheckDone) return;
        _androidBackgroundCheckDone = true;
      }
      await _checkAndroidUpdates(context: context, inBackground: inBackground);
    }
  }

  @visibleForTesting
  static bool isNewerVersion(String currentVersion, String remoteVersion) {
    final currentClean = currentVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final remoteClean = remoteVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');

    final currentMain = currentClean.split('+').first.split('-').first;
    final remoteMain = remoteClean.split('+').first.split('-').first;

    final currentParts =
        currentMain.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final remoteParts =
        remoteMain.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final maxLen = currentParts.length > remoteParts.length
        ? currentParts.length
        : remoteParts.length;

    for (var i = 0; i < maxLen; i++) {
      final cur = i < currentParts.length ? currentParts[i] : 0;
      final rem = i < remoteParts.length ? remoteParts[i] : 0;
      if (rem > cur) return true;
      if (rem < cur) return false;
    }

    return false;
  }

  static Future<String> _getAndroidInstalledVersion() async {
    final result =
        await _androidChannel.invokeMapMethod<String, dynamic>('getAppVersion');
    return (result?['versionName'] as String?) ?? '1.0.0';
  }

  static Future<AndroidReleaseInfo?> _fetchLatestAndroidRelease() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request =
          await client.getUrl(Uri.parse(AppConstants.githubLatestReleaseApiUrl));
      request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      request.headers.set(HttpHeaders.userAgentHeader, 'SynProd-Lite-Android');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final rawTag = (json['tag_name'] as String?) ?? '';
      final version = rawTag.replaceFirst(RegExp(r'^[vV]\.?'), '');
      if (version.isEmpty) return null;

      final assets = (json['assets'] as List<dynamic>?) ?? const [];
      String? apkUrl;
      for (final item in assets) {
        if (item is Map<String, dynamic>) {
          final name = (item['name'] as String?)?.toLowerCase() ?? '';
          final url = item['browser_download_url'] as String?;
          if (name.endsWith('.apk') && url != null && url.isNotEmpty) {
            apkUrl = url;
            break;
          }
        }
      }

      if (apkUrl == null) return null;

      return AndroidReleaseInfo(
        version: version,
        downloadUrl: apkUrl,
        releaseNotes: json['body'] as String?,
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<void> _checkAndroidUpdates({
    required BuildContext? context,
    required bool inBackground,
  }) async {
    try {
      final currentVersion = await _getAndroidInstalledVersion();
      final latest = await _fetchLatestAndroidRelease();

      if (context == null || !context.mounted) return;

      if (latest == null) {
        if (!inBackground) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not reach GitHub Releases to check for updates.'),
            ),
          );
        }
        return;
      }

      if (!isNewerVersion(currentVersion, latest.version)) {
        if (!inBackground) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SynProd Lite v$currentVersion is up to date.'),
            ),
          );
        }
        return;
      }

      await _showAndroidUpdateDialog(
        context: context,
        currentVersion: currentVersion,
        release: latest,
      );
    } catch (_) {
      if (!inBackground && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to check for updates. Please try again later.'),
          ),
        );
      }
    }
  }

  static Future<void> _showAndroidUpdateDialog({
    required BuildContext context,
    required String currentVersion,
    required AndroidReleaseInfo release,
  }) async {
    var isDownloading = false;
    double? progress;
    String? errorMessage;

    await showSynProdDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final percentText = progress != null
              ? '${(progress! * 100).clamp(0, 100).toStringAsFixed(0)}%'
              : null;

          return SynProdDialog(
            icon: Icons.system_update_alt_outlined,
            title: 'Update Available (v${release.version})',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'A newer version of SynProd Lite is available on GitHub Releases (installed: v$currentVersion).',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.mutedTextFor(ctx),
                  ),
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text(
                    percentText != null
                        ? 'Downloading update... $percentText'
                        : 'Downloading update...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.mutedTextFor(ctx),
                    ),
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.errorTextFor(ctx),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDownloading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
              SynProdGradientButton(
                onPressed: isDownloading
                    ? null
                    : () async {
                        setDialogState(() {
                          isDownloading = true;
                          progress = null;
                          errorMessage = null;
                        });
                        try {
                          final apkFile = await _downloadApk(
                            url: release.downloadUrl,
                            version: release.version,
                            onProgress: (value) {
                              if (ctx.mounted) {
                                setDialogState(() => progress = value);
                              }
                            },
                          );
                          await _androidChannel.invokeMethod<bool>(
                            'installApk',
                            {'filePath': apkFile.path},
                          );
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            setDialogState(() {
                              isDownloading = false;
                              errorMessage =
                                  'Download or installation failed. Please try again.';
                            });
                          }
                        }
                      },
                child: Text(isDownloading ? 'Downloading...' : 'Update Now'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<File> _downloadApk({
    required String url,
    required String version,
    required ValueChanged<double?> onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final apkFile = File(
      '${tempDir.path}${Platform.pathSeparator}synprod_lite-$version-android.apk',
    );
    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'SynProd-Lite-Android');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      final sink = apkFile.openWrite();

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            onProgress(receivedBytes / totalBytes);
          }
        }
      } finally {
        await sink.close();
      }

      return apkFile;
    } finally {
      client.close(force: true);
    }
  }
}
