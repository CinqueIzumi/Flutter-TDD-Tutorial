import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/networkinfo.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  // Initialize the variables
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  // Assign the variable's values
  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        // ensures that the isConnected will always return true in this group
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        // ensures that the isConnected will always return true in this group
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getConcreteNumberTrivia(tNumber);
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {

      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // arrange

        // When the function getConcreteNumberTrivia() is called with any number, return the tNumberTriviaModel
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        //assert

        // Check that the call has been made with tNumber
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));

        // Ensure that the result is of the right type of the Either, as the failure is the left type
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        // arrange

        // When the function getConcreteNumberTrivia() is called with any number, return the tNumberTriviaModel
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        await repository.getConcreteNumberTrivia(tNumber);

        //assert

        // Check that the call has been made with tNumber
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        // Check that the trivia model has been cached locally
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange

        // When the function getConcreteNumberTrivia() is called with any number, return a ServerException
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());

        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        //assert

        // Check that the call has been made with tNumber
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));

        // Verify that nothing has interacted with the local data source
        verifyZeroInteractions(mockLocalDataSource);

        // Ensure that the result is of the left type of the Either, specifically the ServerFailure type
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return cache failure when there is no cached data present',
          () async {
        // arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'test', number: 123);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getRandomNumberTrivia();
      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // arrange

            // When the function getConcreteNumberTrivia() is called with any number, return the tNumberTriviaModel
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            //act
            final result = await repository.getRandomNumberTrivia();

            //assert

            // Check that the call has been made with tNumber
            verify(mockRemoteDataSource.getRandomNumberTrivia());

            // Ensure that the result is of the right type of the Either, as the failure is the left type
            expect(result, equals(Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // arrange

            // When the function getConcreteNumberTrivia() is called with any number, return the tNumberTriviaModel
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            //act
            await repository.getRandomNumberTrivia();

            //assert

            // Check that the call has been made
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            // Check that the trivia model has been cached locally
            verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // arrange

            // When the function getConcreteNumberTrivia() is called with any number, return a ServerException
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenThrow(ServerException());

            //act
            final result = await repository.getRandomNumberTrivia();

            //assert

            // Check that the call has been made
            verify(mockRemoteDataSource.getRandomNumberTrivia());

            // Verify that nothing has interacted with the local data source
            verifyZeroInteractions(mockLocalDataSource);

            // Ensure that the result is of the left type of the Either, specifically the ServerFailure type
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
              () async {
            // arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test('should return cache failure when there is no cached data present',
              () async {
            // arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenThrow(CacheException());
            //act
            final result = await repository.getRandomNumberTrivia();
            //assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Left(CacheFailure())));
          });
    });
  });
}
