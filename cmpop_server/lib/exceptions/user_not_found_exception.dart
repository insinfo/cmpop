class UserNotFoundException implements Exception {
  UserNotFoundException(
      {this.error,
      this.message = '401 Usuário não encontrado',
      this.stackTrace,
      this.statusCode = 401,
      List<String> errors = const []}) {
    if (errors != null) {
      this.errors.addAll(errors);
    }
  }

  dynamic error;

  /// A list of errors that occurred when this exception was thrown.
  final List<String> errors = [];

  /// The cause of this exception.
  String message;

  /// The [StackTrace] associated with this error.
  StackTrace stackTrace;

  /// An HTTP status code this exception will throw.
  int statusCode;

  Map toJson() {
    return {'is_error': true, 'status_code': statusCode, 'message': message, 'errors': errors};
  }

  Map toMap() => toJson();

  @override
  String toString() {
    return "$statusCode: $message";
  }
}
