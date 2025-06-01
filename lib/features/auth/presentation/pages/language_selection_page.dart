import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class LanguageSelectionPage extends StatefulWidget {
  final void Function(String)? onLanguageSelected;
  const LanguageSelectionPage({super.key, this.onLanguageSelected});

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'native': 'English'},
    {'code': 'ta', 'native': 'தமிழ்'},
    {'code': 'te', 'native': 'తెలుగు'},
    {'code': 'ml', 'native': 'മലയാളം'},
    {'code': 'hi', 'native': 'हिंदी'}
  ];

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = 'en'; // Default selection
  }

  Future<void> _selectLanguage(String code) async {
    setState(() {
      _selectedCode = code;
    });
  }

  Future<void> _onContinue() async {
    if (_selectedCode == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', _selectedCode!);
    Intl.defaultLocale = _selectedCode!;
    if (widget.onLanguageSelected != null) {
      widget.onLanguageSelected!(_selectedCode!);
      return;
    }
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = Colors.green.shade700;
    final greyTile = const Color(0xFFF3F3F3);
    // Set system navigation bar color to white for seamless background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Brand name aligned left, like screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'HarvestHub', // Corrected app name
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 3, top: 2),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose your preferred language',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final lang in LanguageSelectionPage.languages)
                    _LanguageTile(
                      label: lang['native']!,
                      selected: _selectedCode == lang['code'],
                      onTap: () => _selectLanguage(lang['code']!),
                      accent: green,
                      grey: greyTile,
                    ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _onContinue,
                  child: Text(
                    'Continue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Color grey;
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.grey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.08) : grey,
          border: Border.all(
            color: selected ? accent : grey,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
