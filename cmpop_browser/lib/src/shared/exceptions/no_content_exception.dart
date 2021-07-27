//no_content_exception.dart
class NoContentException implements Exception {
  final dynamic message;

  NoContentException([this.message = 'Exceção: Sem conteúdo']);

  @override
  String toString() {
    Object message = this.message;
    if (message == null) return 'NoContentException';
    return '$message';
  }
}
