class Failure {
  final String message;

  Failure([this.message = "An unknown error occurred"]);

  @override
  String toString() => message;
}
