import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String detectAbi() {
  final version = Platform.version.toLowerCase();

  if (version.contains("arm64")) return "arm64-v8a";
  if (version.contains("arm")) return "armeabi-v7a";
  if (version.contains("x86_64")) return "x86_64";

  return "arm64-v8a"; // fallback
}

Future<bool> isUpdateAvailable() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version; // e.g. "1.0.3"

  final response = await http.get(
    Uri.parse(
      'https://api.github.com/repos/JanSaeis/dhbw_calendar/releases/latest',
    ),
  );

  if (response.statusCode != 200) return false;

  final data = jsonDecode(response.body);
  final latestTag = data['tag_name']; // e.g. "v1.0.4"

  final latestVersion = latestTag.replaceFirst('v', '');

  return _isNewerVersion(latestVersion, currentVersion);
}

bool _isNewerVersion(String remote, String local) {
  List<int> r = remote.split('.').map(int.parse).toList();
  List<int> l = local.split('.').map(int.parse).toList();

  for (int i = 0; i < r.length; i++) {
    if (r[i] > l[i]) return true;
    if (r[i] < l[i]) return false;
  }
  return false;
}

Future<void> downloadAndInstallApk() async {
  // Fetch release info
  final api = await http.get(
    Uri.parse(
      "https://api.github.com/repos/JanSaeis/dhbw_calendar/releases/latest",
    ),
  );

  final json = jsonDecode(api.body);
  final assets = json["assets"] as List;

  // Detect ABI and pick correct APK
  final abi = detectAbi();
  final expectedName = "dhbw_calendar-$abi.apk";

  final apk = assets.firstWhere(
    (a) => a["name"] == expectedName,
    orElse: () => throw Exception("No APK found for ABI: $abi"),
  );

  final apiUrl = apk["url"]; // GitHub API asset URL

  // Save to Downloads
  final downloadsDir = Directory('/storage/emulated/0/Download');
  final filePath = '${downloadsDir.path}/dhbw_update.apk';

  final dio = Dio();
  const int notifId = 1;

  // Show "downloading" notification
  await notifications.show(
    notifId,
    'Downloading update…',
    'Please wait',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'update_channel',
        'App Updates',
        importance: Importance.high,
        priority: Priority.high,
        onlyAlertOnce: true,
        ongoing: true,
      ),
    ),
  );

  // Download (no progress)
  await dio.download(
    apiUrl,
    filePath,
    options: Options(
      headers: {"Accept": "application/octet-stream"},
      followRedirects: true,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  // Final notification
  await notifications.show(
    notifId,
    'Download complete',
    'Tap to install',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'update_channel',
        'App Updates',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
      ),
    ),
  );

  // Open installer
  await OpenFilex.open(filePath);
}
