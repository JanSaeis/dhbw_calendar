import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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
  final url =
      "https://github.com/JanSaeis/dhbw_calendar/releases/latest/download/app-release.apk";
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/update.apk';

  final dio = Dio();

  // Download the file
  await dio.download(
    url,
    filePath,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        print("Download: ${(received / total * 100).toStringAsFixed(0)}%");
      }
    },
  );

  // Open the APK installer
  await OpenFilex.open(filePath);
}
