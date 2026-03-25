// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import 'package:flutter/services.dart';
// // import 'package:frontend/services/api_service.dart';
// // import 'results_screen.dart';
// // import '../models/assessment_result.dart';

// // class AssessmentScreen extends StatefulWidget {
// //   const AssessmentScreen({super.key});

// //   @override
// //   State<AssessmentScreen> createState() => _AssessmentScreenState();
// // }

// // class _AssessmentScreenState extends State<AssessmentScreen> {
// //   int _currentSectionIndex = 0;
// //   Map<int, List<int?>> _answers = {}; // Stores answers per section
// //   dynamic _questionnaire;
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadQuestions();
// //   }

// //   // Load the JSON from assets
// //   Future<void> _loadQuestions() async {
// //     final String response = await rootBundle.loadString('assets/questions.json');
// //     final data = await json.decode(response);
// //     setState(() {
// //       _questionnaire = data['sections'];
// //       // Initialize answers map with nulls
// //       for (int i = 0; i < _questionnaire.length; i++) {
// //         _answers[i] = List<int?>.filled(_questionnaire[i]['questions'].length, null);
// //       }
// //       _isLoading = false;
// //     });
// //   }

// //   void _nextSection() {
// //     if (_answers[_currentSectionIndex]!.contains(null)) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please answer all questions in this section.")),
// //       );
// //       return;
// //     }
// //     setState(() {
// //       _currentSectionIndex++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

// //     bool isReviewPage = _currentSectionIndex == _questionnaire.length;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(isReviewPage ? "Review Your Answers" : _questionnaire[_currentSectionIndex]['title']),
// //         backgroundColor: Colors.white,
// //         foregroundColor: Colors.black,
// //         elevation: 0,
// //       ),
// //       body: isReviewPage ? _buildReviewPage() : _buildQuestionList(),
// //     );
// //   }

// //   Widget _buildQuestionList() {
// //     var section = _questionnaire[_currentSectionIndex];
// //     List<dynamic> questions = section['questions'];
// //     List<dynamic> options = section['options'];

// //     return Column(
// //       children: [
// //         LinearProgressIndicator(value: (_currentSectionIndex + 1) / _questionnaire.length),
// //         Expanded(
// //           child: ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: questions.length,
// //             itemBuilder: (context, index) {
// //               return Card(
// //                 margin: const EdgeInsets.only(bottom: 15),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(12.0),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text("${index + 1}. ${questions[index]}", 
// //                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
// //                       const SizedBox(height: 10),
// //                       Wrap(
// //                         spacing: 8,
// //                         children: options.map<Widget>((opt) {
// //                           bool isSelected = _answers[_currentSectionIndex]![index] == opt['value'];
// //                           return ChoiceChip(
// //                             label: Text(opt['text']),
// //                             selected: isSelected,
// //                             onSelected: (selected) {
// //                               setState(() {
// //                                 _answers[_currentSectionIndex]![index] = opt['value'];
// //                               });
// //                             },
// //                           );
// //                         }).toList(),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //         Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: ElevatedButton(
// //             onPressed: _nextSection,
// //             style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
// //             child: const Text("Next"),
// //           ),
// //         )
// //       ],
// //     );
// //   }

// //   Widget _buildReviewPage() {
// //     return Column(
// //       children: [
// //         const Padding(
// //           padding: EdgeInsets.all(16.0),
// //           child: Text(
// //             "Please review your answers before submitting. This assessment is completely anonymous.",
// //             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
// //             textAlign: TextAlign.center,
// //           ),
// //         ),
// //         Expanded(
// //           child: ListView.builder(
// //             padding: const EdgeInsets.symmetric(horizontal: 16),
// //             itemCount: _questionnaire.length,
// //             itemBuilder: (context, sIndex) {
// //               var section = _questionnaire[sIndex];
// //               return Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// //                     width: double.infinity,
// //                     color: Colors.grey[200],
// //                     child: Text(
// //                       section['title'],
// //                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
// //                     ),
// //                   ),
// //                   ...List.generate(section['questions'].length, (qIndex) {
// //                     int? selectedValue = _answers[sIndex]![qIndex];
// //                     String chosenText = section['options']
// //                         .firstWhere((opt) => opt['value'] == selectedValue)['text'];

// //                     return ListTile(
// //                       dense: true,
// //                       title: Text("${qIndex + 1}. ${section['questions'][qIndex]}"),
// //                       subtitle: Text(
// //                         "Your Answer: $chosenText",
// //                         style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
// //                       ),
// //                       trailing: const Icon(Icons.edit_note, size: 20),
// //                       onTap: () {
// //                         setState(() => _currentSectionIndex = sIndex);
// //                       },
// //                     );
// //                   }),
// //                   const SizedBox(height: 20),
// //                 ],
// //               );
// //             },
// //           ),
// //         ),
// //         Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: OutlinedButton(
// //                   onPressed: () => setState(() => _currentSectionIndex = 0),
// //                   style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
// //                   child: const Text("Edit All"),
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: ElevatedButton(
// //                   onPressed: _submitAssessment,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     foregroundColor: Colors.white,
// //                     minimumSize: const Size(0, 50),
// //                   ),
// //                   child: const Text("Confirm & Submit"),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         )
// //       ],
// //     );
// //   }

// //   void _submitAssessment() async {
// //     showDialog(
// //       context: context, 
// //       barrierDismissible: false, 
// //       builder: (context) => const Center(child: CircularProgressIndicator()),
// //     );

// //     List<List<int>> scores = _answers.values.map((v) => v.cast<int>()).toList();
    
// //     try {
// //       // Sent as "Anonymous" to ensure privacy
// //       final Map<String, dynamic> rawData = await ApiService.submitAssessment("Anonymous", scores);
      
// //       final resultObject = AssessmentResult.fromJson(rawData);
      
// //       if (!mounted) return;
// //       Navigator.pop(context); 
      
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => ResultsScreen(result: resultObject),
// //         ),
// //       );
// //     } catch (e) {
// //       if (!mounted) return;
// //       Navigator.pop(context); 
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text("Submission Error: $e"),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:frontend/services/api_service.dart';
// import 'results_screen.dart';
// import '../models/assessment_result.dart';

// class AssessmentScreen extends StatefulWidget {
//   const AssessmentScreen({super.key});

//   @override
//   State<AssessmentScreen> createState() => _AssessmentScreenState();
// }

// class _AssessmentScreenState extends State<AssessmentScreen> {
//   int _currentSectionIndex = 0;
//   final Map<int, List<int?>> _answers = {}; // Stores answers per section
//   dynamic _questionnaire;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadQuestions();
//   }

//   // Logic: Load JSON from assets
//   Future<void> _loadQuestions() async {
//     final String response = await rootBundle.loadString('assets/questions.json');
//     final data = await json.decode(response);
//     setState(() {
//       _questionnaire = data['sections'];
//       for (int i = 0; i < _questionnaire.length; i++) {
//         _answers[i] = List<int?>.filled(_questionnaire[i]['questions'].length, null);
//       }
//       _isLoading = false;
//     });
//   }

//   void _nextSection() {
//     if (_answers[_currentSectionIndex]!.contains(null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Please answer all questions in this section."),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.redAccent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _currentSectionIndex++;
//     });
//   }

//   void _submitAssessment() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     List<List<int>> scores = _answers.values.map((v) => v.cast<int>()).toList();

//     try {
//       final Map<String, dynamic> rawData = await ApiService.submitAssessment("Anonymous", scores);
//       final resultObject = AssessmentResult.fromJson(rawData);

//       if (!mounted) return;
//       Navigator.pop(context);

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResultsScreen(result: resultObject),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Submission Error: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

//     bool isReviewPage = _currentSectionIndex == _questionnaire.length;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),
//       appBar: AppBar(
//         title: Text(
//           isReviewPage ? "Review Your Answers" : _questionnaire[_currentSectionIndex]['title'],
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         leading: _currentSectionIndex > 0
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//                 onPressed: () => setState(() => _currentSectionIndex--),
//               )
//             : null,
//       ),
//       body: Column(
//         children: [
//           LinearProgressIndicator(
//             value: (_currentSectionIndex + 1) / (_questionnaire.length + 1),
//             backgroundColor: Colors.grey[200],
//             valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
//             minHeight: 6,
//           ),
//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 400),
//               child: isReviewPage
//                   ? _buildReviewPage(key: const ValueKey('review_page'))
//                   : _buildQuestionList(key: ValueKey(_currentSectionIndex)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionList({required Key key}) {
//     var section = _questionnaire[_currentSectionIndex];
//     List<dynamic> questions = section['questions'];
//     List<dynamic> options = section['options'];

//     return Column(
//       key: key,
//       children: [
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.all(20),
//             itemCount: questions.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               return QuestionCard(
//                 question: questions[index],
//                 index: index,
//                 options: options,
//                 selectedValue: _answers[_currentSectionIndex]![index],
//                 onSelect: (val) {
//                   setState(() {
//                     _answers[_currentSectionIndex]![index] = val;
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//         _buildBottomAction(
//           label: _currentSectionIndex == _questionnaire.length - 1 ? "Review" : "Next",
//           onPressed: _nextSection,
//           color: Colors.indigoAccent,
//         ),
//       ],
//     );
//   }

//   Widget _buildReviewPage({required Key key}) {
//     return Column(
//       key: key,
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(20.0),
//           child: Text(
//             "This assessment is anonymous. Please ensure your answers reflect your current feelings.",
//             style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             itemCount: _questionnaire.length,
//             itemBuilder: (context, sIndex) {
//               var section = _questionnaire[sIndex];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
//                 ),
//                 child: ExpansionTile(
//                   shape: const RoundedRectangleBorder(side: BorderSide.none),
//                   title: Text(section['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                   children: List.generate(section['questions'].length, (qIndex) {
//                     int? selectedValue = _answers[sIndex]![qIndex];
//                     String chosenText = section['options'].firstWhere((opt) => opt['value'] == selectedValue)['text'];

//                     return ListTile(
//                       title: Text(section['questions'][qIndex], style: const TextStyle(fontSize: 13)),
//                       subtitle: Text(chosenText, style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
//                       trailing: const Icon(Icons.edit_outlined, size: 18),
//                       onTap: () => setState(() => _currentSectionIndex = sIndex),
//                     );
//                   }),
//                 ),
//               );
//             },
//           ),
//         ),
//         _buildBottomAction(
//           label: "Confirm & Submit",
//           onPressed: _submitAssessment,
//           color: Colors.green,
//           isDouble: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomAction({required String label, required VoidCallback onPressed, required Color color, bool isDouble = false}) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(color: Colors.white),
//       child: isDouble
//           ? Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => setState(() => _currentSectionIndex = 0),
//                     style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                     child: const Text("Restart"),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: onPressed,
//                     style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
//                     child: Text(label),
//                   ),
//                 ),
//               ],
//             )
//           : ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
//               child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//     );
//   }
// }

// class QuestionCard extends StatelessWidget {
//   final String question;
//   final int index;
//   final List<dynamic> options;
//   final int? selectedValue;
//   final Function(int) onSelect;

//   const QuestionCard({super.key, required this.question, required this.index, required this.options, this.selectedValue, required this.onSelect});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Question ${index + 1}", style: TextStyle(color: Colors.indigoAccent.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12)),
//           const SizedBox(height: 8),
//           Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 20),
//           ...options.map((opt) {
//             bool isSelected = selectedValue == opt['value'];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: InkWell(
//                 onTap: () => onSelect(opt['value']),
//                 borderRadius: BorderRadius.circular(12),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: isSelected ? Colors.indigoAccent : Colors.grey[200]!, width: 2),
//                     color: isSelected ? Colors.indigoAccent.withOpacity(0.05) : Colors.transparent,
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Colors.indigoAccent : Colors.grey[400], size: 22),
//                       const SizedBox(width: 12),
//                       Expanded(child: Text(opt['text'], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }

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
  final Map<int, List<int?>> _answers = {}; 
  dynamic _questionnaire;
  bool _isLoading = true;

  // Branding Color: Maroon / Burgundy
  final Color primaryMaroon = const Color(0xFF800020);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = await json.decode(response);
    setState(() {
      _questionnaire = data['sections'];
      for (int i = 0; i < _questionnaire.length; i++) {
        _answers[i] = List<int?>.filled(_questionnaire[i]['questions'].length, null);
      }
      _isLoading = false;
    });
  }

  void _nextSection() {
    if (_answers[_currentSectionIndex]!.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please answer all questions in this section."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _currentSectionIndex++;
    });
  }

  void _submitAssessment() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryMaroon)),
    );

    List<List<int>> scores = _answers.values.map((v) => v.cast<int>()).toList();

    try {
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
        SnackBar(content: Text("Submission Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryMaroon)));

    bool isReviewPage = _currentSectionIndex == _questionnaire.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          isReviewPage ? "Review Your Answers" : _questionnaire[_currentSectionIndex]['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: _currentSectionIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => setState(() => _currentSectionIndex--),
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentSectionIndex + 1) / (_questionnaire.length + 1),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
            minHeight: 6,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isReviewPage
                  ? _buildReviewPage(key: const ValueKey('review_page'))
                  : _buildQuestionList(key: ValueKey(_currentSectionIndex)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList({required Key key}) {
    var section = _questionnaire[_currentSectionIndex];
    List<dynamic> questions = section['questions'];
    List<dynamic> options = section['options'];

    return Column(
      key: key,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return QuestionCard(
                question: questions[index],
                index: index,
                options: options,
                selectedValue: _answers[_currentSectionIndex]![index],
                primaryColor: primaryMaroon,
                onSelect: (val) {
                  setState(() {
                    _answers[_currentSectionIndex]![index] = val;
                  });
                },
              );
            },
          ),
        ),
        _buildBottomAction(
          label: _currentSectionIndex == _questionnaire.length - 1 ? "Review" : "Next",
          onPressed: _nextSection,
          color: primaryMaroon,
        ),
      ],
    );
  }

  Widget _buildReviewPage({required Key key}) {
    return Column(
      key: key,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "This assessment is anonymous. Please ensure your answers reflect your current feelings.",
            style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _questionnaire.length,
            itemBuilder: (context, sIndex) {
              var section = _questionnaire[sIndex];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  title: Text(section['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  children: List.generate(section['questions'].length, (qIndex) {
                    int? selectedValue = _answers[sIndex]![qIndex];
                    String chosenText = section['options'].firstWhere((opt) => opt['value'] == selectedValue)['text'];

                    return ListTile(
                      title: Text(section['questions'][qIndex], style: const TextStyle(fontSize: 13)),
                      subtitle: Text(chosenText, style: TextStyle(color: primaryMaroon, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.edit_outlined, size: 18),
                      onTap: () => setState(() => _currentSectionIndex = sIndex),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        _buildBottomAction(
          label: "Confirm & Submit",
          onPressed: _submitAssessment,
          color: Colors.green, // Keep submit green or change to primaryMaroon if preferred
          isDouble: true,
        ),
      ],
    );
  }

  Widget _buildBottomAction({required String label, required VoidCallback onPressed, required Color color, bool isDouble = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: isDouble
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentSectionIndex = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryMaroon,
                      side: BorderSide(color: primaryMaroon),
                      minimumSize: const Size(0, 56), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Restart"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color, 
                      foregroundColor: Colors.white, 
                      minimumSize: const Size(0, 56), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                      elevation: 0
                    ),
                    child: Text(label),
                  ),
                ),
              ],
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 56), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                elevation: 0
              ),
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String question;
  final int index;
  final List<dynamic> options;
  final int? selectedValue;
  final Color primaryColor;
  final Function(int) onSelect;

  const QuestionCard({
    super.key, 
    required this.question, 
    required this.index, 
    required this.options, 
    this.selectedValue, 
    required this.primaryColor,
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Question ${index + 1}", style: TextStyle(color: primaryColor.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          ...options.map((opt) {
            bool isSelected = selectedValue == opt['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(opt['value']),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!, width: 2),
                    color: isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? primaryColor : Colors.grey[400], size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(opt['text'], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}