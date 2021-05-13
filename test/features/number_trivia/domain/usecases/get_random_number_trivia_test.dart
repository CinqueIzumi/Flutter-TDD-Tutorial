import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test('should get trivia from the repository', ()  async {
    // arrange
    when(mockNumberTriviaRepository.getRandomNumberTrivia()) // Whenever the method is called
        .thenAnswer((_) async => Right(tNumberTrivia)); // always answer with the right (correct within Future<Either>) response

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tNumberTrivia)); // We expect the result to contain right (correct)
    verify(mockNumberTriviaRepository.getRandomNumberTrivia()); // Verify that the method has been called on the repository
    verifyNoMoreInteractions(mockNumberTriviaRepository); // Ensure the mock is no longer being used
  });
}
