import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  Map<String, dynamic> _scores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresString = prefs.getString('best_scores');
      setState(() {
        _scores = scoresString != null ? json.decode(scoresString) : {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading scores: $e')),
      );
    }
  }

  Future<void> _resetScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('best_scores');
      setState(() {
        _scores = {};
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting scores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.ranking),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: localizations.resetScores,
            onPressed: () {
              _showResetDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scores.isEmpty
              ? Center(
                  child: Text(
                    localizations.noScores,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black, // Adjust text color based on theme
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: sortedScores.length,
                  itemBuilder: (context, index) {
                    final entry = sortedScores[index];
                    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.white // White border in dark mode
                              : Colors.black, // Black border in light mode
                          width: 2, // Border width
                        ),
                      ),
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.8) // Dark background in dark mode
                          : Colors.white, // Light background in light mode
                      child: ListTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white // White text in dark mode
                                : Colors.black, // Black text in light mode
                          ),
                        ),
                        subtitle: Text(
                          '${localizations.bestScore}: ${entry.value}',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white70 // Light gray text in dark mode
                                : Colors.black87, // Dark gray text in light mode
                          ),
                        ),
                        trailing: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white // White text in dark mode
                                : Colors.black, // Black text in light mode
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showResetDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.resetScores),
        content: Text(localizations.confirmReset),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              _resetScores();
              Navigator.pop(context);
            },
            child: Text(localizations.reset),
          ),
        ],
      ),
    );
  }
}