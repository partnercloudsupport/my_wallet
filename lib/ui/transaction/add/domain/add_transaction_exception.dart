class AddTransactionException implements Exception {
  final String message;

  AddTransactionException(this.message);

  @override
  String toString() {
    return message;
  }
}