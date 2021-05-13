import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetConcreteNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumber = 1;
  final tNumberTrivia = NumberTrivia(text: 'test', number: tNumber);

  test('should get trivia for the number from the repository', ()  async {
    // arrange
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any)) // Whenever the method is called
        .thenAnswer((_) async => Right(tNumberTrivia)); // always answer with the right (correct within Future<Either>) response

    // act
    final result = await usecase(Params(number: tNumber));

    // assert
    expect(result, Right(tNumberTrivia)); // We expect the result to contain right (correct)
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber)); // Verify that the method has been called on the repository
    verifyNoMoreInteractions(mockNumberTriviaRepository); // Ensure the mock is no longer being used
  });
}
