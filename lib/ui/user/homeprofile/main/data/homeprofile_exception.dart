class HomeProfileException implements Exception {
  final String message;

  HomeProfileException(this.message);

  @override
  String toString() => message;
}