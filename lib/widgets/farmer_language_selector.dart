import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';

class FarmerLanguageSelector extends StatelessWidget {
  final bool showAsPopup;
  final Color? backgroundColor;
  final Color? textColor;
  final Function(String languageCode)? onLanguageChanged;

  const FarmerLanguageSelector({
    super.key,
    this.showAsPopup = true,
    this.backgroundColor,
    this.textColor,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsPopup) {
      return _buildPopupSelector(context);
    } else {
      return _buildInlineSelector(context);
    }
  }

  Widget _buildPopupSelector(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return PopupMenuButton<String>(
      onSelected: (value) => _changeLanguage(context, value),
      itemBuilder: (context) => [
        _buildLanguageMenuItem(
          context,
          'en',
          '🇺🇸',
          'English',
          localizations.english,
          localeProvider.locale.languageCode == 'en',
        ),
        _buildLanguageMenuItem(
          context,
          'tl',
          '🇵🇭',
          'Tagalog',
          localizations.filipino,
          localeProvider.locale.languageCode == 'tl',
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (textColor ?? Colors.white).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrentLanguageFlag(localeProvider.locale.languageCode),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              _getCurrentLanguageName(
                  context, localeProvider.locale.languageCode),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: textColor ?? Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineSelector(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                localizations.selectLanguage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLanguageCard(
                  context,
                  'en',
                  '🇺🇸',
                  'English',
                  'English',
                  localeProvider.locale.languageCode == 'en',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageCard(
                  context,
                  'tl',
                  '🇵🇭',
                  'Tagalog',
                  'Filipino',
                  localeProvider.locale.languageCode == 'tl',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem(
    BuildContext context,
    String languageCode,
    String flag,
    String nativeName,
    String localizedName,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: languageCode,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    localizedName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    String languageCode,
    String flag,
    String nativeName,
    String localizedName,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _changeLanguage(context, languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              nativeName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isSelected ? theme.colorScheme.primary : Colors.black87,
              ),
            ),
            Text(
              localizedName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'tl':
        return '🇵🇭';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  String _getCurrentLanguageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'tl':
        return 'Tagalog';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _changeLanguage(
      BuildContext context, String languageCode) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    // Update the locale
    localeProvider.setLocale(Locale(languageCode, ''));

    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);

    // Call the callback if provided
    onLanguageChanged?.call(languageCode);
  }
}
