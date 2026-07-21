import '../errors/app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get value => switch (this) {
    Success<T> s => s.value,
    Failure<T> _ => null,
  };

  AppError? get error => switch (this) {
    Success<T> _ => null,
    Failure<T> f => f.error,
  };

  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success<T> s => Success(transform(s.value)),
    Failure<T> f => Failure(f.error),
  };

  Result<T> orElse(T Function() fallback) => switch (this) {
    Success<T> s => s,
    Failure<T> _ => Success(fallback()),
  };

  T unwrap() => switch (this) {
    Success<T> s => s.value,
    Failure<T> f => throw StateError('Called unwrap() on Failure: ${f.error.message}'),
  };
}

class Success<T> extends Result<T> {
  @override
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  @override
  final AppError error;
  const Failure(this.error);
}
