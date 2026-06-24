import 'package:url_launcher/url_launcher.dart';

import '../constants/app_urls.dart';

Future<void> openPrivacyPolicy() => _openUrl(AppUrls.privacyPolicy);

Future<void> openDataPrivacy() => _openUrl(AppUrls.dataPrivacy);

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not open $url');
  }
}
