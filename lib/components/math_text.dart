import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MathText(this.text, {Key? key, this.style, this.textAlign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> lines = text.split('\n');
    
    if (lines.length <= 1 && !text.contains('\$')) {
      return Text(text, style: style, textAlign: textAlign);
    }

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center 
          ? CrossAxisAlignment.center 
          : (textAlign == TextAlign.right ? CrossAxisAlignment.end : CrossAxisAlignment.start),
      children: lines.map((line) => _buildLine(line)).toList(),
    );
  }

  Widget _buildLine(String line) {
    if (line.isEmpty) return const SizedBox(height: 8);
    if (!line.contains('\$')) {
      return Text(line, style: style, textAlign: textAlign);
    }

    final List<Widget> widgets = [];
    final List<String> parts = line.split('\$');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        if (parts[i].isNotEmpty) {
          widgets.add(Text(parts[i], style: style));
        }
      } else {
        // Math text
        if (parts[i].isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Math.tex(
              parts[i],
              textStyle: style?.copyWith(fontSize: (style?.fontSize ?? 14) + 2),
              onErrorFallback: (err) => Text('\$${parts[i]}\$', style: style?.copyWith(color: Colors.red)),
            ),
          ));
        }
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: _getWrapAlignment(),
      children: widgets,
    );
  }

  WrapAlignment _getWrapAlignment() {
    switch (textAlign) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.right:
        return WrapAlignment.end;
      default:
        return WrapAlignment.start;
    }
  }
}
