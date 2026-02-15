class Section {
  final String title;
  final List<String> questions;
  final List<Option> options;

  Section({required this.title, required this.questions, required this.options});
}

class Option {
  final String text;
  final int value;

  Option({required this.text, required this.value});
}