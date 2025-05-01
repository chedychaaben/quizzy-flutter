import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'dart:convert';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'results_screen.dart';
import '../l10n/app_localizations.dart';
import 'settings_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String category;
  final String difficulty;
  final int numberOfQuestions;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.numberOfQuestions,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<dynamic> _questions = [];
  List<List<String>> _allShuffledAnswers = [];
  List<String?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _answered = false;
  String? _selectedAnswer;
  Timer? _timer;
  int _timeLeft = 15;
  final HtmlUnescape _unescape = HtmlUnescape();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Updated to use just_audio
  static const int _questionDuration = 15;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Dispose of the just_audio player
    super.dispose();
  }

  Future<void> _playSound(bool correct) async {
    try {
      final soundPath = correct
          ? 'assets/sounds/correct.ogg'
          : 'assets/sounds/wrong.ogg';
      await _audioPlayer.setAsset(soundPath); // Load the sound
      await _audioPlayer.play(); // Play the sound
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final categoryId = await _getCategoryId(widget.category);
      final url =
          'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&category=$categoryId&difficulty=${widget.difficulty.toLowerCase()}&type=multiple';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['results'] == null || (data['results'] as List).isEmpty) {
        throw Exception('No questions available');
      }

      final decodedQuestions = (data['results'] as List).map((question) {
        return {
          'question': _unescape.convert(question['question']),
          'correct_answer': _unescape.convert(question['correct_answer']),
          'incorrect_answers': (question['incorrect_answers'] as List)
              .map((answer) => _unescape.convert(answer))
              .toList(),
        };
      }).toList();

      setState(() {
        _questions = decodedQuestions;
        _userAnswers = List<String?>.filled(decodedQuestions.length, null);
        _isLoading = false;
        _prepareShuffledAnswers();
        _startTimer();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.errorLoading),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchQuestions();
            },
            child: Text(localizations.retry),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text(localizations.returnHome),
          ),
        ],
      ),
    );
  }

  void _prepareShuffledAnswers() {
    _allShuffledAnswers = _questions.map<List<String>>((question) {
      final answers = List<String>.from(question['incorrect_answers']);
      answers.add(question['correct_answer']);
      answers.shuffle();
      return answers;
    }).toList();
  }

  Future<int> _getCategoryId(String categoryName) async {
    const url = 'https://opentdb.com/api_category.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final category = (data['trivia_categories'] as List).firstWhere(
        (cat) => cat['name'].toString().toLowerCase() == categoryName.toLowerCase(),
        orElse: () => null,
      );
      return category?['id'] ?? 0;
    }
    throw Exception('Failed to load categories');
  }

  void _startTimer() {
    _timeLeft = _questionDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        _nextQuestion();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  Future<void> _selectAnswer(String answer) async {
    if (_answered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _userAnswers[_currentQuestionIndex] = answer;
      if (answer == _questions[_currentQuestionIndex]['correct_answer']) {
        _score++;
      }
    });

    final settings = ref.read(settingsProvider);
    if (settings.soundEnabled) {
      await _playSound(answer == _questions[_currentQuestionIndex]['correct_answer']);
    }
    if (settings.notificationsEnabled) {
      await _vibrate();
    }

    _timer?.cancel();
    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  Future<void> _vibrate() async {
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  Future<void> _saveScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.category}_${widget.difficulty}';
      final scoresString = prefs.getString('best_scores');
      Map<String, dynamic> scores = {};

      if (scoresString != null) {
        scores = json.decode(scoresString);
      }

      final currentBest = scores[key] ?? 0;
      
      if (_score > currentBest) {
        scores[key] = _score;
        await prefs.setString('best_scores', json.encode(scores));
      }
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      await _saveScore();
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: _score,
            total: _questions.length,
            questions: _questions,
            userAnswers: _userAnswers,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.quizTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty || _allShuffledAnswers.isEmpty || _currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.quizTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.errorLoading),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchQuestions,
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentAnswers = _allShuffledAnswers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.questionLabel} ${_currentQuestionIndex + 1} / ${_questions.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: localizations.darkMode,
            onPressed: () {
              ref.read(settingsProvider.notifier).toggleDarkMode(!settings.isDarkMode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer Display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${localizations.timeLabel}: $_timeLeft s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Highlight the timer in red for better visibility
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              minHeight: 4,
            ),
            const SizedBox(height: 16),
            // Question Display
            Text(
              _unescape.convert(currentQuestion['question']),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Answer Buttons
            Expanded(
              child: ListView.builder(
                itemCount: currentAnswers.length,
                itemBuilder: (context, index) {
                  final answer = currentAnswers[index];
                  final isCorrect = answer == currentQuestion['correct_answer'];
                  final isSelected = answer == _selectedAnswer;
                  
                  Color buttonColor = Theme.of(context).primaryColor;
                  
                  if (_answered) {
                    if (isCorrect) {
                      buttonColor = Colors.green;
                    } else if (isSelected || _selectedAnswer != currentQuestion['correct_answer']) {
                      buttonColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        disabledBackgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                          side: BorderSide(
                            color: _answered
                                ? (isCorrect ? Colors.green : Colors.red) // Green for correct, red for incorrect
                                : Colors.white, // White border for unanswered buttons
                            width: 2, // Border width
                          ),
                        ),
                      ),
                      onPressed: _answered ? null : () => _selectAnswer(answer),
                      child: Text(
                        answer,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}