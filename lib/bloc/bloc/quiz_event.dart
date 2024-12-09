part of 'quiz_bloc.dart';

@immutable
sealed class QuizEvent {}

class LoadQuestionsEvent extends QuizEvent {
  final bool? isClear;
  final bool? isback;
  final int? currentQuestionIndex;
  LoadQuestionsEvent({this.isClear, this.isback, this.currentQuestionIndex});
}

class SubmitAnswerEvent extends QuizEvent {
  final int questionIndex;
  final String selectedAnswer;

  SubmitAnswerEvent(
      {required this.questionIndex, required this.selectedAnswer});

  List<Object?> get props => [questionIndex, selectedAnswer];
}

class FinishQuizEvent extends QuizEvent {}
