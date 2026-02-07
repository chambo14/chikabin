import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  /// Obtient le chemin du dossier Downloads pour Android
  static Future<String?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Android : Dossier public Downloads
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      // iOS : Dossier Documents
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    return null;
  }

  /// Vérifie si le dossier Downloads existe et est accessible
  static Future<bool> isDownloadsAccessible() async {
    try {
      final downloadsPath = await getDownloadsDirectory();
      if (downloadsPath == null) return false;

      final directory = Directory(downloadsPath);
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  /// Sauvegarde un fichier dans le dossier Downloads
  static Future<String?> saveToDownloads(
      String fileName,
      List<int> bytes,
      ) async {
    try {
      final downloadsPath = await getDownloadsDirectory();
      if (downloadsPath == null) {
        throw Exception('Impossible d\'accéder au dossier Downloads');
      }

      final directory = Directory(downloadsPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '$downloadsPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      return null;
    }
  }

  /// Sauvegarde dans le dossier Documents de l'app (toujours accessible)
  static Future<String?> saveToAppDocuments(
      String fileName,
      List<int> bytes,
      ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      return null;
    }
  }
}