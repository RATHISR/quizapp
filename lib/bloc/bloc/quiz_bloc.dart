import 'package:contus_quizzes/bloc/bloc/quiz_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    QuizRepo quizRepo = QuizRepo();

    on<LoadQuestionsEvent>(quizRepo.onLoadQuestions);
    on<SubmitAnswerEvent>(
        (event, emit) => quizRepo.onSubmitAnswer(event, emit, state: state));
    on<FinishQuizEvent>(
        (event, emit) => quizRepo.onFinishQuiz(event, emit, state: state));
  }
}
