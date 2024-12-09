import 'dart:convert';

import 'package:contus_quizzes/bloc/bloc/quiz_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizRepo {
  final List<Map<String, dynamic>> _questions = [
    {
      "id": 1,
      "question": "What is 3 + 3?",
      "options": ["3", "4", "5", "6"],
      "answer": "6"
    },
    {
      "id": 2,
      "question": "What is 2 + 2?",
      "options": ["3", "4", "5", "6"],
      "answer": "4"
    },
    {
      "id": 3,
      "question": "What is 2 + 1?",
      "options": ["3", "4", "5", "6"],
      "answer": "3"
    },
    {
      "id": 4,
      "question": "What is 2 + 3?",
      "options": ["3", "4", "5", "6"],
      "answer": "5"
    }
  ];

  DateTime _startTime = DateTime.now();

  void onLoadQuestions(
      LoadQuestionsEvent event, Emitter<QuizState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (event.isClear == true) {
      prefs.remove('quizProgress');
    }

    final savedData = prefs.getString('quizProgress');
    if (savedData != null) {
      final progress = json.decode(savedData);
      if (event.isback == true) {
        emit(QuizLoadedState(
          questions: _questions,
          currentQuestionIndex: event.currentQuestionIndex ??
              progress['currentQuestionIndex'] - 1,
          userAnswers: (progress['userAnswers'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(int.parse(key), value as String)),
          correctAnswers: progress['correctAnswers'],
        ));
      } else {
        emit(QuizLoadedState(
          questions: _questions,
          currentQuestionIndex: progress['currentQuestionIndex'],
          userAnswers: (progress['userAnswers'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(int.parse(key), value as String)),
          correctAnswers: progress['correctAnswers'],
        ));
      }
    } else {
      _startTime = DateTime.now();
      emit(QuizLoadedState(
        questions: _questions,
        currentQuestionIndex: 0,
        // ignore: prefer_const_literals_to_create_immutables
        userAnswers: {},
        correctAnswers: 0,
      ));
    }
  }

  void onSubmitAnswer(SubmitAnswerEvent event, Emitter<QuizState> emit,
      {dynamic state}) async {
    final currentState = state;
    if (currentState is QuizLoadedState) {
      final isCorrect =
          _questions[event.questionIndex]['answer'] == event.selectedAnswer;
      final updatedAnswers = Map<int, String>.from(currentState.userAnswers)
        ..[event.questionIndex] = event.selectedAnswer;

      // Move to the next question or show results
      if (currentState.currentQuestionIndex < _questions.length - 1) {
        final nextState = QuizLoadedState(
          questions: currentState.questions,
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
          userAnswers: updatedAnswers,
          correctAnswers: currentState.correctAnswers + (isCorrect ? 1 : 0),
        );

        emit(nextState);
        await saveProgress(nextState);
      } else {
        final totalTime = DateTime.now().difference(_startTime).inSeconds;
        emit(QuizCompletedState(
          totalQuestions: currentState.questions.length,
          correctAnswers: currentState.correctAnswers,
          userAnswers: currentState.userAnswers,
          totalTime: totalTime,
        ));
        // await clearProgress();
      }
    }
  }

  void onBackAnswer(SubmitAnswerEvent event, Emitter<QuizState> emit,
      {dynamic state}) async {
    final currentState = state;
    if (currentState is QuizLoadedState) {
      final isCorrect =
          _questions[event.questionIndex]['answer'] == event.selectedAnswer;
      final updatedAnswers = Map<int, String>.from(currentState.userAnswers)
        ..[event.questionIndex] = event.selectedAnswer;

      // Move to the next question or show results
      if (currentState.currentQuestionIndex < _questions.length - 1) {
        final nextState = QuizLoadedState(
          questions: currentState.questions,
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
          userAnswers: updatedAnswers,
          correctAnswers: currentState.correctAnswers + (isCorrect ? 1 : 0),
        );
        emit(nextState);
        await saveProgress(nextState);
      } else {
        final totalTime = DateTime.now().difference(_startTime).inSeconds;
        emit(QuizCompletedState(
          totalQuestions: currentState.questions.length,
          correctAnswers: currentState.correctAnswers,
          userAnswers: currentState.userAnswers,
          totalTime: totalTime,
        ));
        // await clearProgress();
      }
    }
  }

  void onFinishQuiz(FinishQuizEvent event, Emitter<QuizState> emit,
      {dynamic state}) async {
    final currentState = state;
    if (currentState is QuizLoadedState) {
      final totalTime = DateTime.now().difference(_startTime).inSeconds;
      emit(QuizCompletedState(
        totalQuestions: currentState.questions.length,
        correctAnswers: currentState.correctAnswers,
        userAnswers: currentState.userAnswers,
        totalTime: totalTime,
      ));
      await clearProgress();
    }
  }

  Future<void> saveProgress(QuizLoadedState state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final progress = {
      'currentQuestionIndex': state.currentQuestionIndex,
      'userAnswers': state.userAnswers
          .map((key, value) => MapEntry(key.toString(), value)),
      'correctAnswers': state.correctAnswers,
    };
    prefs.setString('quizProgress', json.encode(progress));
  }

  Future<void> clearProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('quizProgress');
  }
}
