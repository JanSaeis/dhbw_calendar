String normalizeIcsUrl(String input) {
  String url = input.trim();

  // Convert webcal:// to https://
  if (url.startsWith("webcal://")) {
    url = url.replaceFirst("webcal://", "https://");
  }

  // Add https:// if missing
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    url = "https://$url";
  }

  // If user pasted a directory, append .ics
  if (!url.endsWith(".ics")) {
    // Remove trailing slash
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }

    // If URL already has a filename but no .ics, append .ics
    final uri = Uri.parse(url);
    if (uri.pathSegments.isNotEmpty) {
      final last = uri.pathSegments.last;
      if (!last.contains(".")) {
        url = "$url.ics";
      }
    } else {
      // No path at all → add default filename
      url = "$url/index.ics";
    }
  }

  return url;
}

String extractUrl(String text) {
  final regex = RegExp(r'(https?:\/\/[^\s]+)');
  final match = regex.firstMatch(text);
  return match?.group(0) ?? text;
}

bool isValidIcsUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.isAbsolute) return false;
  if (!url.toLowerCase().endsWith(".ics")) return false;
  return true;
}