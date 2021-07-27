import 'dart:async';
import 'dart:io';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:uuid/uuid.dart';

class FileService {
  Future<String> create(UploadedFile file, String baseDirectory,
      {bool randFileName = true, bool criaDiretoriaBaseadoNoAnoMesAndRetorna = true}) async {
    final filename = randFileName ? '${const Uuid().v4()}.${file.filename.split(".").last}' : file.filename;
    var directory = baseDirectory;

    final directoryAnoMes = '${DateTime.now().year}/${DateTime.now().month}';
    if (criaDiretoriaBaseadoNoAnoMesAndRetorna) {
      directory = '$baseDirectory/$directoryAnoMes';
    }

    if (!Directory(directory).existsSync()) {
      // Create a new directory, recursively creating non-existent directories.
      Directory(directory).createSync(recursive: true);
    }

    final filePath = '${directory}/${filename}';
    print('FileService@create filePath $filePath');

    final Stream<List<int>> content = file.data;
    final IOSink sink = File(filePath).openWrite();
    /*await for (var item in content) {
      sink.add(item);
    }*/

    await content.forEach(sink.add);

    await sink.flush();
    await sink.close();

    if (!File(filePath).existsSync()) {
      throw Exception('Falha ao criar o arquivo');
    }
    if (criaDiretoriaBaseadoNoAnoMesAndRetorna) {
      return '$directoryAnoMes/$filename';
    }

    return filename;
  }

  Future<void> delete(String filePath) async {
    final myFile = File(filePath);
    await myFile.delete();
  }

  Future<void> deleteIfExist(String filePath) async {
    try {
      await delete(filePath);
    } catch (e) {
      print('FileService@deleteIfExist $e');
    }
  }
}
