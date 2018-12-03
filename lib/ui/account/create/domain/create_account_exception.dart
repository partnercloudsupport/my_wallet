class CreateAccountException implements Exception {
  final String message;

  CreateAccountException(this.message);

  @override
  String toString() {
    return message;
  }
}