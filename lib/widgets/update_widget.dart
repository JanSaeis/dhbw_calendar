import 'package:flutter/material.dart';
import '../services/updater.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkForUpdates(BuildContext context) async {
  final updateAvailable = await isUpdateAvailable();

  if (!context.mounted) return;

  if (updateAvailable) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Update available"),
        content: const Text("A new version of the app is available."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await downloadAndInstallApk();
            },
            child: const Text("Update"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
        ],
      ),
    );
  }
}
