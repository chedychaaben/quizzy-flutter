import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../l10n/app_localizations.dart';
import 'quiz_screen.dart';
import 'settings_provider.dart';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';

class QuizParametersScreen extends ConsumerStatefulWidget {
  const QuizParametersScreen({super.key});

  @override
  ConsumerState<QuizParametersScreen> createState() => _QuizParametersScreenState();
}

class _QuizParametersScreenState extends ConsumerState<QuizParametersScreen> {
  List<String> _categories = [];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> _questionNumbers = [5, 10, 15, 20];
  String? _selectedCategory;
  String? _selectedDifficulty;
  int _selectedQuestionNumber = 10;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCountingDown = false; // New flag to hide parameters during countdown

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = _difficulties[0];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    const url = 'https://opentdb.com/api_category.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['trivia_categories'];
      
      setState(() {
        _categories = categoryList.map((cat) => cat['name'] as String).toList();
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories[0];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider); // Access settingsProvider here

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.selectParameters),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.selectParameters),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.errorFetching),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCategories,
                child: Text(localizations.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectParameters),
        actions: [
          Row(
            children: [
              const Text('Sound'),
              Switch(
                value: settings.soundEnabled, // Access soundEnabled here
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleSound(value);
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('Dark Mode'),
              Switch(
                value: settings.isDarkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleDarkMode(value);
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), // Use your background image
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
            child: Container(
              color: Colors.black.withOpacity(0.3), // Optional: Add a semi-transparent overlay
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Semi-transparent background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: Visibility(
                    visible: !_isCountingDown, // Hide parameters during countdown
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: localizations.category,
                            labelStyle: const TextStyle(
                              color: Colors.white, // Set the label color to white
                              fontWeight: FontWeight.bold, // Make the label bold
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.8), // Dropdown field background
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                              borderSide: const BorderSide(color: Colors.white), // Border color
                            ),
                          ),
                          value: _selectedCategory,
                          style: const TextStyle(
                            color: Colors.white, // Set the selected text color to white
                            fontSize: 16, // Adjust font size
                          ),
                          dropdownColor: Colors.black, // Set the dropdown background color to black
                          isExpanded: true, // Allow the dropdown to expand fully
                          items: _categories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white, // Set the dropdown item text color to white
                                        fontSize: 16, // Adjust font size
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Difficulty Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: localizations.difficulty,
                            labelStyle: const TextStyle(
                              color: Colors.white, // Set the label color to white
                              fontWeight: FontWeight.bold, // Make the label bold
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.8), // Dropdown field background
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                              borderSide: const BorderSide(color: Colors.white), // Border color
                            ),
                          ),
                          value: _selectedDifficulty,
                          style: const TextStyle(
                            color: Colors.white, // Set the selected text color to white
                            fontSize: 16, // Adjust font size
                          ),
                          dropdownColor: Colors.black, // Set the dropdown background color to black
                          isExpanded: true, // Allow the dropdown to expand fully
                          items: _difficulties
                              .map((difficulty) => DropdownMenuItem(
                                    value: difficulty,
                                    child: Text(
                                      difficulty,
                                      style: const TextStyle(
                                        color: Colors.white, // Set the dropdown item text color to white
                                        fontSize: 16, // Adjust font size
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Number of Questions Dropdown
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: localizations.numQuestions,
                            labelStyle: const TextStyle(
                              color: Colors.white, // Set the label color to white
                              fontWeight: FontWeight.bold, // Make the label bold
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.8), // Dropdown field background
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                              borderSide: const BorderSide(color: Colors.white), // Border color
                            ),
                          ),
                          value: _selectedQuestionNumber,
                          style: const TextStyle(
                            color: Colors.white, // Set the selected text color to white
                            fontSize: 16, // Adjust font size
                          ),
                          dropdownColor: Colors.black, // Set the dropdown background color to black
                          isExpanded: true, // Allow the dropdown to expand fully
                          items: _questionNumbers
                              .map((number) => DropdownMenuItem(
                                    value: number,
                                    child: Text(
                                      number.toString(),
                                      style: const TextStyle(
                                        color: Colors.white, // Set the dropdown item text color to white
                                        fontSize: 16, // Adjust font size
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedQuestionNumber = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Start Quiz Button
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedCategory != null && _selectedDifficulty != null) {
                              setState(() {
                                _isCountingDown = true; // Hide parameters
                              });
                              _showCountdownDialog(
                                context,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        category: _selectedCategory!,
                                        difficulty: _selectedDifficulty!,
                                        numberOfQuestions: _selectedQuestionNumber,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _isCountingDown = false; // Show parameters again after quiz
                                    });
                                  });
                                },
                                settings.soundEnabled, // Pass the sound setting
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blue, // Button background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: Text(
                            localizations.startQuiz,
                            style: const TextStyle(
                              color: Colors.white, // Button text color
                              fontSize: 18, // Button text size
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountdownDialog(BuildContext context, VoidCallback onCountdownComplete, bool isSoundEnabled) {
    int countdown = 3;
    final player = AudioPlayer(); // Create an audio player instance

    // Play the countdown audio if sound is enabled
    if (isSoundEnabled) {
      player.setAsset('assets/sounds/countdown.mp3').then((_) {
        player.play();
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start the countdown
            Future.delayed(const Duration(seconds: 1), () {
              if (countdown > 0) {
                setState(() {
                  countdown--;
                });
              } else {
                Navigator.of(context).pop(); // Close the dialog
                onCountdownComplete(); // Start the quiz
              }
            });

            return Dialog(
              backgroundColor: Colors.black.withOpacity(0.8), // Full-screen background
              insetPadding: EdgeInsets.zero, // Remove default padding
              child: Stack(
                children: [
                  // Countdown text in the center
                  Center(
                    child: Text(
                      countdown > 0 ? '$countdown' : 'Go!',
                      style: const TextStyle(
                        fontSize: 100, // Large font size for full-screen effect
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}