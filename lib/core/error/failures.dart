sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ValidationFailure extends Failure {
  final String? field;
  final int? position;

  const ValidationFailure(super.message, {this.field, this.position});
}

class CalculationFailure extends Failure {
  const CalculationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
