class CreateCategoryException implements Exception {
  final String message;

  CreateCategoryException(this.message);

  @override
  String toString() {
    return message;
  }
}