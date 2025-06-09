import 'package:flutter/material.dart';

/// Converts text with markdown-style asterisks to rich text with formatting
/// Single asterisks (*text*) become italic
/// Double asterisks (**text**) become bold
class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final TextAlign textAlign;

  const FormattedText({
    super.key,
    required this.text,
    this.baseStyle,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the text and create spans
    List<TextSpan> spans = _parseText(text, baseStyle ?? const TextStyle());

    return RichText(
      text: TextSpan(
        children: spans,
        style: baseStyle ?? DefaultTextStyle.of(context).style,
      ),
      textAlign: textAlign,
    );
  }

  List<TextSpan> _parseText(String text, TextStyle defaultStyle) {
    List<TextSpan> spans = [];
    // First handle double asterisks (bold)
    RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    // Find all bold patterns
    for (Match match in boldPattern.allMatches(text)) {
      // Add the text before this match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      // Add the bold text
      spans.add(
        TextSpan(
          text: match.group(1), // The text between asterisks
          style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last bold match
    if (lastMatchEnd < text.length) {
      // Process this remaining text for italic (single asterisk)
      String remaining = text.substring(lastMatchEnd);
      spans.addAll(_parseItalicText(remaining, defaultStyle));
    } else if (spans.isEmpty) {
      // No bold found, process the entire text for italic
      spans.addAll(_parseItalicText(text, defaultStyle));
    }

    return spans;
  }

  List<TextSpan> _parseItalicText(String text, TextStyle defaultStyle) {
    List<TextSpan> spans = [];
    RegExp italicPattern = RegExp(r'\*(.*?)\*');
    int lastMatchEnd = 0;

    // Find all italic patterns
    for (Match match in italicPattern.allMatches(text)) {
      // Add the text before this match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      // Add the italic text
      spans.add(
        TextSpan(
          text: match.group(1), // The text between asterisks
          style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last italic match
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle),
      );
    } else if (spans.isEmpty) {
      // No formatting found at all, return the original text
      spans.add(TextSpan(text: text, style: defaultStyle));
    }

    return spans;
  }
}
