import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc/quiz_bloc.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizBloc()..add(LoadQuestionsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizLoadedState) {
              final question = state.questions[state.currentQuestionIndex];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${state.currentQuestionIndex + 1}, ${question['question']}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ...question['options'].map<Widget>((option) {
                      return ListTile(
                        title: Text(option),
                        leading: Radio<String>(
                          value: option,
                          groupValue:
                              state.userAnswers[state.currentQuestionIndex],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<QuizBloc>().add(SubmitAnswerEvent(
                                    questionIndex: state.currentQuestionIndex,
                                    selectedAnswer: value,
                                  ));
                            }
                          },
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 50),
                    state.currentQuestionIndex != 0
                        ? ElevatedButton(
                            onPressed: () {
                              context.read<QuizBloc>().add(LoadQuestionsEvent(
                                  isback: true,
                                  currentQuestionIndex:
                                      state.currentQuestionIndex -
                                          1)); // Reload progress
                            },
                            child: const Text('back'),
                          )
                        : Container(),
                  ],
                ),
              );
            } else if (state is QuizCompletedState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz Completed!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text('Total Questions: ${state.totalQuestions}'),
                    Text('Correct Answers: ${state.correctAnswers}'),
                    Text(
                        'Your Score: ${(state.correctAnswers / state.totalQuestions * 100).toStringAsFixed(1)}%'),
                    Text('Total Time: ${state.totalTime} seconds'),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<QuizBloc>()
                            .add(LoadQuestionsEvent(isClear: true));
                      },
                      child: const Text('Restart Quiz'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
