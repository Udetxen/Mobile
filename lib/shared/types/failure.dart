class Failure implements Exception {
  final String message;
  final String userFriendlyMessage;
  final String? code;

  Failure({
    required this.message,
    required this.userFriendlyMessage,
    this.code,
  });

  @override
  String toString() {
    return 'Failure(message: $message,  code: $code)';
  }
}
