import 'package:flutter/material.dart';
import 'math_text.dart';

/// A widget that renders structured explanation text.
/// It handles bullet points (*) and descriptions (:) with proper alignment.
class ExplanationText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ExplanationText(this.text, {Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split text into logical blocks based on bullet points or double newlines
    final lines = text.split('\n');
    List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('*')) {
        // Bullet item start
        String content = line.substring(1).trim();
        
        if (content.isEmpty) {
          // Just a bullet separator
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text('•', style: TextStyle(color: Colors.white38, fontSize: 18)),
          ));
        } else {
          children.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0, right: 12.0),
                  child: Text('•', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _renderLineContent(content),
                ),
              ],
            ),
          ));
        }
      } else if (line.startsWith(':')) {
        // Continuation/Description starting with colon
        String content = line.substring(1).trim();
        children.add(Padding(
          padding: const EdgeInsets.only(left: 28.0, bottom: 10.0),
          child: _renderLineContent(content, isDescription: true),
        ));
      } else {
        // Regular line (e.g., unit label without bullet, or mixed content)
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: _renderLineContent(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _renderLineContent(String content, {bool isDescription = false}) {
    // Check if the line itself contains a separator colon (e.g., "Unit : Description")
    if (!isDescription && content.contains(' : ')) {
      final parts = content.split(' : ');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MathText(parts[0].trim(), style: style?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          MathText(parts[1].trim(), style: style?.copyWith(color: Colors.white70, height: 1.5)),
        ],
      );
    }

    return MathText(
      content,
      style: isDescription 
        ? style?.copyWith(color: Colors.white70, height: 1.5) 
        : style,
    );
  }
}
