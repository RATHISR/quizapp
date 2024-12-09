part of 'quiz_bloc.dart';

@immutable
sealed class QuizState {}

final class QuizInitial extends QuizState {}

class QuizLoadingState extends QuizState {}

class QuizLoadedState extends QuizState {
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final Map<int, String> userAnswers;
  final int correctAnswers;

  QuizLoadedState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.correctAnswers,
  });

  List<Object?> get props =>
      [questions, currentQuestionIndex, userAnswers, correctAnswers];
}

class QuizCompletedState extends QuizState {
  final int totalQuestions;
  final int correctAnswers;
  final Map<int, String> userAnswers;
  final int totalTime;

  QuizCompletedState({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.userAnswers,
    required this.totalTime,
  });

  List<Object?> get props =>
      [totalQuestions, correctAnswers, userAnswers, totalTime];
}
