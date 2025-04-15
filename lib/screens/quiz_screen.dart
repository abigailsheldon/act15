import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  String? _errorMessage; // Added error message state

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      print(e);
      // Set the error message and stop loading so the user sees feedback
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _currentQuestionIndex++;
    });
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      child: Text(option),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz App")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz App")),
        body: Center(child: Text("Error loading questions: $_errorMessage")),
      );
    }
    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz App")),
        body: Center(
          child: Text(
            'Quiz Finished! Your Score: $_score/${_questions.length}',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.question,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            ...currentQuestion.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _buildOptionButton(option),
                )),
            SizedBox(height: 20.0),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20.0),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text("Next Question"),
              )
          ],
        ),
      ),
    );
  }
}
