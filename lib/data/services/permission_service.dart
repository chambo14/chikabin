import 'dart:io';
import 'package:chikabin/data/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionService {
  /// Demande les permissions de stockage selon la version Android
  /// Désormais, cette méthode délègue à StorageService
  static Future<bool> requestStoragePermission() async {
    // StorageService gère automatiquement les permissions
    // file_picker s'occupe de tout sur toutes les versions Android
    return await StorageService.canAccessStorage();
  }

  /// Vérifie si Android 11+ (API 30+)
  static Future<bool> isAndroid11OrAbove() async {
    return await StorageService.isAndroid11OrAbove();
  }

  /// Vérifie si Android 13+ (API 33+)
  static Future<bool> isAndroid13OrAbove() async {
    return await StorageService.isAndroid13OrAbove();
  }

  /// Demande toutes les permissions nécessaires pour l'app
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    if (Platform.isAndroid) {
      // Permission de stockage (toujours true maintenant)
      results['storage'] = await requestStoragePermission();

      // Permission de notifications - OPTIONNEL
      // Si vous n'utilisez pas les notifications, retirez cette section
      results['notification'] = true; // Pas de gestion pour l'instant
    } else {
      // iOS
      results['storage'] = true;
      results['notification'] = true;
    }

    return results;
  }

  /// Vérifie si toutes les permissions sont accordées
  static Future<bool> checkAllPermissions() async {
    // Avec file_picker, les permissions sont toujours "accordées"
    // car file_picker gère tout automatiquement
    return await StorageService.canAccessStorage();
  }

  /// Ouvre les paramètres de l'application
  static Future<void> openSettings() async {
    // Utilise url_launcher au lieu de permission_handler
    const settingsUrl = 'app-settings:';
    if (await canLaunchUrl(Uri.parse(settingsUrl))) {
      await launchUrl(Uri.parse(settingsUrl));
    }
  }

  /// Affiche les informations sur les capacités de stockage (debug)
  static Future<void> showStorageInfo() async {
    final info = await StorageService.getStorageInfo();
    print('=== Storage Info ===');
    info.forEach((key, value) {
      print('$key: $value');
    });
    print('===================');
  }
}