import 'package:dartz/dartz.dart';
import 'package:number_trivia/core/error/failures.dart';

class InvalidInputFailure extends Failure {
  @override
  List<Object> get props => [];
}

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final result = int.parse(str);

      if (result < 0) {
        throw FormatException();
      }
      return Right(result);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}
