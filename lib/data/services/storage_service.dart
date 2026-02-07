import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class StorageService {
  /// Vérifie si l'app peut accéder au stockage
  /// Sur Android 13+, file_picker ne nécessite aucune permission
  /// Sur Android < 13, file_picker gère automatiquement les permissions
  static Future<bool> canAccessStorage() async {
    if (!Platform.isAndroid) {
      return true; // iOS gère automatiquement via file_picker
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Android 13+ (API 33+) : Aucune permission nécessaire
      // file_picker utilise le système de sélection natif
      if (androidInfo.version.sdkInt >= 33) {
        return true;
      }

      // Android 10-12 (API 29-32) : file_picker gère automatiquement
      // la permission MANAGE_EXTERNAL_STORAGE ou READ_EXTERNAL_STORAGE
      // Pas besoin de demander manuellement
      return true;

    } catch (e) {
      // En cas d'erreur de détection, on suppose que c'est OK
      // file_picker gèrera les permissions si nécessaire
      return true;
    }
  }

  /// Vérifie la version Android (utile pour d'autres fonctionnalités)
  static Future<int> getAndroidSdkVersion() async {
    if (!Platform.isAndroid) {
      return 0;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 0;
    }
  }

  /// Vérifie si Android 13+ (API 33+)
  static Future<bool> isAndroid13OrAbove() async {
    final sdkVersion = await getAndroidSdkVersion();
    return sdkVersion >= 33;
  }

  /// Vérifie si Android 11+ (API 30+)
  static Future<bool> isAndroid11OrAbove() async {
    final sdkVersion = await getAndroidSdkVersion();
    return sdkVersion >= 30;
  }

  /// Retourne des informations sur les capacités de stockage
  static Future<Map<String, dynamic>> getStorageInfo() async {
    if (!Platform.isAndroid) {
      return {
        'platform': 'iOS',
        'canAccess': true,
        'needsPermission': false,
        'usesNativePicker': true,
      };
    }

    final sdkVersion = await getAndroidSdkVersion();
    final isAndroid13Plus = sdkVersion >= 33;

    return {
      'platform': 'Android',
      'sdkVersion': sdkVersion,
      'canAccess': true,
      'needsPermission': false, // file_picker gère automatiquement
      'usesNativePicker': isAndroid13Plus,
      'method': isAndroid13Plus
          ? 'Photo Picker (Android 13+)'
          : 'file_picker with auto-permissions',
    };
  }
}