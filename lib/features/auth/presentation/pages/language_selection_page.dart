import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class LanguageSelectionPage extends StatelessWidget {
  final void Function(String)? onLanguageSelected;
  const LanguageSelectionPage({super.key, this.onLanguageSelected});

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'labelKey': 'english'},
    {'code': 'hi', 'labelKey': 'hindi'},
    {'code': 'ta', 'labelKey': 'tamil'},
    {'code': 'te', 'labelKey': 'telugu'},
    {'code': 'ml', 'labelKey': 'malayalam'},
  ];

  Future<void> _selectLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', code);
    Intl.defaultLocale = code;
    if (onLanguageSelected != null) {
      onLanguageSelected!(code);
      // Do not navigate here; let the parent widget handle navigation after locale update
      return;
    }
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo or illustration
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.eco,
                        size: 48,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  Text(
                    loc.selectLanguage,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontFamily: 'NotoSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: languages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final label =
                          {
                            'english': loc.english,
                            'hindi': loc.hindi,
                            'tamil': loc.tamil,
                            'telugu': loc.telugu,
                            'malayalam': loc.malayalam,
                          }[lang['labelKey']] ??
                          lang['labelKey'];
                      final icon = _getLanguageIcon(lang['code']!);
                      final color = _getLanguageColor(lang['code']!, theme);
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _selectLanguage(context, lang['code']!),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: color, width: 1.2),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.15),
                              child: icon,
                            ),
                            title: Text(
                              label ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'NotoSans',
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for language icons
  Icon _getLanguageIcon(String code) {
    switch (code) {
      case 'en':
        return const Icon(Icons.language, color: Colors.green);
      case 'hi':
        return const Icon(Icons.translate, color: Colors.deepOrange);
      case 'ta':
        return const Icon(Icons.text_fields, color: Colors.purple);
      case 'te':
        return const Icon(Icons.text_format, color: Colors.blue);
      case 'ml':
        return const Icon(Icons.menu_book, color: Colors.green);
      default:
        return const Icon(Icons.language, color: Colors.green);
    }
  }

  // Helper for language colors
  Color _getLanguageColor(String code, ThemeData theme) {
    switch (code) {
      case 'en':
        return Colors.green.shade700;
      case 'hi':
        return Colors.deepOrange;
      case 'ta':
        return Colors.purple;
      case 'te':
        return Colors.blue;
      case 'ml':
        return Colors.green;
      default:
        return Colors.green.shade700;
    }
  }
}
