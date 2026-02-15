import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend/services/api_service.dart';
import 'results_screen.dart';
import '../models/assessment_result.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentSectionIndex = 0;
  Map<int, List<int?>> _answers = {}; // Stores answers per section
  dynamic _questionnaire;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Load the JSON from assets
  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = await json.decode(response);
    setState(() {
      _questionnaire = data['sections'];
      // Initialize answers map with nulls
      for (int i = 0; i < _questionnaire.length; i++) {
        _answers[i] = List<int?>.filled(_questionnaire[i]['questions'].length, null);
      }
      _isLoading = false;
    });
  }

  void _nextSection() {
    if (_answers[_currentSectionIndex]!.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions in this section.")),
      );
      return;
    }
    setState(() {
      _currentSectionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isReviewPage = _currentSectionIndex == _questionnaire.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isReviewPage ? "Review Your Answers" : _questionnaire[_currentSectionIndex]['title']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isReviewPage ? _buildReviewPage() : _buildQuestionList(),
    );
  }

  Widget _buildQuestionList() {
    var section = _questionnaire[_currentSectionIndex];
    List<dynamic> questions = section['questions'];
    List<dynamic> options = section['options'];

    return Column(
      children: [
        LinearProgressIndicator(value: (_currentSectionIndex + 1) / _questionnaire.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${index + 1}. ${questions[index]}", 
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: options.map<Widget>((opt) {
                          bool isSelected = _answers[_currentSectionIndex]![index] == opt['value'];
                          return ChoiceChip(
                            label: Text(opt['text']),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _answers[_currentSectionIndex]![index] = opt['value'];
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _nextSection,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text("Next"),
          ),
        )
      ],
    );
  }

  Widget _buildReviewPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Please review your answers before submitting. This assessment is completely anonymous.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _questionnaire.length,
            itemBuilder: (context, sIndex) {
              var section = _questionnaire[sIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Text(
                      section['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  ...List.generate(section['questions'].length, (qIndex) {
                    int? selectedValue = _answers[sIndex]![qIndex];
                    String chosenText = section['options']
                        .firstWhere((opt) => opt['value'] == selectedValue)['text'];

                    return ListTile(
                      dense: true,
                      title: Text("${qIndex + 1}. ${section['questions'][qIndex]}"),
                      subtitle: Text(
                        "Your Answer: $chosenText",
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.edit_note, size: 20),
                      onTap: () {
                        setState(() => _currentSectionIndex = sIndex);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentSectionIndex = 0),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                  child: const Text("Edit All"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text("Confirm & Submit"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _submitAssessment() async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    List<List<int>> scores = _answers.values.map((v) => v.cast<int>()).toList();
    
    try {
      // Sent as "Anonymous" to ensure privacy
      final Map<String, dynamic> rawData = await ApiService.submitAssessment("Anonymous", scores);
      
      final resultObject = AssessmentResult.fromJson(rawData);
      
      if (!mounted) return;
      Navigator.pop(context); 
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(result: resultObject),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Submission Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}