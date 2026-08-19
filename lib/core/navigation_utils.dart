import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// Abrir navegación a una dirección.
/// Intenta abrir Google Maps nativos, con fallback a web.
Future<void> navegarADireccion(String direccion) async {
  final encoded = Uri.encodeComponent(direccion);

  if (Platform.isAndroid) {
    final uri = Uri.parse('google.navigation:q=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
  }

  if (Platform.isIOS) {
    final uri = Uri.parse('maps://app?daddr=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
  }

  // Fallback: Google Maps web
  final webUri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$encoded',
  );
  await launchUrl(webUri, mode: LaunchMode.externalApplication);
}
