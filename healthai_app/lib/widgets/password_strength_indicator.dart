import 'package:flutter/material.dart';
import '../utils/password_strength.dart';
import '../l10n/app_localizations.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showSuggestions;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showSuggestions = true,
  });

  String _translateSuggestion(BuildContext context, String suggestion) {
    switch (suggestion) {
      case 'add_lowercase_letters':
        return AppLocalizations.of(context)!.addLowercaseLetters;
      case 'add_uppercase_letters':
        return AppLocalizations.of(context)!.addUppercaseLetters;
      case 'add_numbers':
        return AppLocalizations.of(context)!.addNumbers;
      case 'add_special_characters':
        return AppLocalizations.of(context)!.addSpecialCharacters;
      case 'avoid_common_patterns':
        return AppLocalizations.of(context)!.avoidCommonPatterns;
      case 'requires_at_least_8_characters':
        return AppLocalizations.of(context)!.requiresAtLeast8Characters;
      default:
        return suggestion;
    }
  }

  String _translateStrength(BuildContext context, PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppLocalizations.of(context)!.passwordStrengthWeak;
      case PasswordStrength.fair:
        return AppLocalizations.of(context)!.passwordStrengthFair;
      case PasswordStrength.good:
        return AppLocalizations.of(context)!.passwordStrengthGood;
      case PasswordStrength.strong:
        return AppLocalizations.of(context)!.passwordStrengthStrong;
      case PasswordStrength.veryStrong:
        return AppLocalizations.of(context)!.passwordStrengthVeryStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = PasswordStrengthChecker.checkStrength(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Strength meter
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey[300],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: result.score,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: result.color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _translateStrength(context, result.strength),
              style: TextStyle(
                color: result.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Suggestions
        if (showSuggestions && result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...result.suggestions
              .take(3)
              .map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _translateSuggestion(context, suggestion),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        // Requirements checklist (compact version)
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRequirementsGrid(password),
        ],
      ],
    );
  }

  Widget _buildRequirementsGrid(String password) {
    final requirements = [
      {'text': '8+ chars', 'met': password.length >= 8},
      {'text': 'Upper', 'met': password.contains(RegExp(r'[A-Z]'))},
      {'text': 'Lower', 'met': password.contains(RegExp(r'[a-z]'))},
      {'text': 'Number', 'met': password.contains(RegExp(r'[0-9]'))},
      {
        'text': 'Special',
        'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          requirements
              .map(
                (req) => _buildRequirementChip(
                  req['text'] as String,
                  req['met'] as bool,
                ),
              )
              .toList(),
    );
  }

  Widget _buildRequirementChip(String text, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            met ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              met
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check : Icons.close,
            size: 12,
            color: met ? Colors.green : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: met ? Colors.green : Colors.grey[600],
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
