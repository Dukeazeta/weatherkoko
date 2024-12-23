import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:install_plugin/install_plugin.dart';

class UpdateService {
  final SupabaseClient _supabase;
  static const String _tableName = 'app_versions';
  final _dio = Dio();

  UpdateService(this._supabase);

  Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get latest version from Supabase
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final latestVersion = response['version'] as String;
      final downloadUrl = response['download_url'] as String;
      final notes = response['notes'] as String?;
      
      // Compare versions
      final needsUpdate = _compareVersions(currentVersion, latestVersion);
      
      if (needsUpdate) {
        return {
          'version': latestVersion,
          'downloadUrl': downloadUrl,
          'notes': notes,
        };
      }
      
      return null;
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  Future<void> performUpdate(String downloadUrl, BuildContext context) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('Cannot access storage');

      final savePath = '${directory.path}/weatherkoko_update.apk';
      
      await _downloadWithProgress(
        downloadUrl,
        savePath,
        context,
      );

      // Install the APK
      await InstallPlugin.installApk(savePath);
      
      // Clean up the downloaded file
      try {
        await File(savePath).delete();
      } catch (e) {
        print('Error deleting temporary file: $e');
      }
    } catch (e) {
      print('Error performing update: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download update. Please try again later.'),
          ),
        );
      }
    }
  }

  Future<void> _downloadWithProgress(
    String url,
    String savePath,
    BuildContext context,
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && context.mounted) {
            final progress = (received / total * 100).toStringAsFixed(0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading: $progress%'),
                duration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
      );
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  bool _compareVersions(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }
}
