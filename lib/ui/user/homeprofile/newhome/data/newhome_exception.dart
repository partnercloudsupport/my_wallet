class NewHomeException implements Exception {
  final String message;

  NewHomeException(this.message);

  @override
  String toString() => message;
}