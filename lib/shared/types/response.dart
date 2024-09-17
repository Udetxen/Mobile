import 'failure.dart';

class Response<T> {
  final T? data;
  final Failure? failure;

  bool get isSuccess => data != null;

  Response({this.data, this.failure});

  Future<void> on({
    required Function(Failure failure) onFailure,
    required Function(T data) onSuccess,
  }) async {
    if (isSuccess) {
      await onSuccess(data as T);
    } else {
      await onFailure(failure!);
    }
  }
}
