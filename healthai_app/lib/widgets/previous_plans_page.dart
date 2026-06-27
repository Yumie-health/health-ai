import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

class PreviousPlansPage extends StatefulWidget {
  const PreviousPlansPage({super.key});

  @override
  State<PreviousPlansPage> createState() => _PreviousPlansPageState();
}

class _PreviousPlansPageState extends State<PreviousPlansPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _previousPlans = [];
  Map<String, List<Map<String, dynamic>>> _weightEntries = {};

  @override
  void initState() {
    super.initState();
    _loadPreviousPlans();
  }

  Future<void> _loadPreviousPlans() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data() ?? {};

      final previousPlans = List<Map<String, dynamic>>.from(
        data['previousPlans'] ?? [],
      );

      // Load weight entries for each plan period
      final weightEntries = await _loadWeightEntriesForPlans(
        user.uid,
        previousPlans,
      );

      setState(() {
        _previousPlans = previousPlans;
        _weightEntries = weightEntries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadWeightEntriesForPlans(
    String userId,
    List<Map<String, dynamic>> plans,
  ) async {
    final entries = <String, List<Map<String, dynamic>>>{};

    for (final plan in plans) {
      final startDate = plan['startDate'] as Timestamp?;
      final endDate = plan['endDate'] as Timestamp?;

      if (startDate != null && endDate != null) {
        final planId =
            '${startDate.toDate().millisecondsSinceEpoch}_${endDate.toDate().millisecondsSinceEpoch}';

        final weightDocs =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('weights')
                .where('timestamp', isGreaterThanOrEqualTo: startDate)
                .where('timestamp', isLessThanOrEqualTo: endDate)
                .orderBy('timestamp', descending: false)
                .get();

        final planEntries =
            weightDocs.docs
                .map((doc) => doc.data())
                .where((data) => (data['isDeleted'] ?? false) == false)
                .toList();

        entries[planId] = planEntries;
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final useMetric = context.watch<PreferencesProvider?>()?.useMetric ?? true;
    final theme = Theme.of(context);
    final bg = _elevatedBackground(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            'Previous Plans',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          foregroundColor: kPrimaryGreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_previousPlans.isEmpty) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            'Previous Plans',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
            ),
          ),
          foregroundColor: kPrimaryGreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Previous Plans',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your previous plans will appear here once you change goals.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Previous Plans',
          style: TextStyle(fontWeight: FontWeight.w700, color: kPrimaryGreen),
        ),
        foregroundColor: kPrimaryGreen,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Weight Journey',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: kPrimaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your progress through different goals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _previousPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _previousPlans[index];
                    return _PreviousPlanCard(
                      plan: plan,
                      weightEntries: _getWeightEntriesForPlan(plan),
                      useMetric: useMetric,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getWeightEntriesForPlan(
    Map<String, dynamic> plan,
  ) {
    final startDate = plan['startDate'] as Timestamp?;
    final endDate = plan['endDate'] as Timestamp?;

    if (startDate != null && endDate != null) {
      final planId =
          '${startDate.toDate().millisecondsSinceEpoch}_${endDate.toDate().millisecondsSinceEpoch}';
      return _weightEntries[planId] ?? [];
    }

    return [];
  }

  Color _elevatedBackground(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0E1116) : const Color(0xFFF6F7FB);
  }
}

class _PreviousPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final List<Map<String, dynamic>> weightEntries;
  final bool useMetric;

  const _PreviousPlanCard({
    required this.plan,
    required this.weightEntries,
    required this.useMetric,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final startDate = plan['startDate'] as Timestamp?;
    final endDate = plan['endDate'] as Timestamp?;
    final startingWeight = (plan['startingWeight'] as num?)?.toDouble() ?? 0.0;
    final targetWeight = (plan['targetWeight'] as num?)?.toDouble() ?? 0.0;
    final goal = plan['goal'] as String? ?? 'Unknown Goal';
    final status = plan['status'] as String? ?? 'completed';

    final startWeightDisplay =
        useMetric ? startingWeight : (startingWeight * 2.20462);
    final targetWeightDisplay =
        useMetric ? targetWeight : (targetWeight * 2.20462);
    final unit = useMetric ? 'kg' : 'lbs';

    // Calculate weight change
    final weightChange = targetWeightDisplay - startWeightDisplay;
    final weightChangeAbs = weightChange.abs();
    final isLoss = weightChange < 0;

    // Calculate duration
    String durationText = 'Unknown';
    if (startDate != null && endDate != null) {
      final duration = endDate.toDate().difference(startDate.toDate());
      final days = duration.inDays;
      if (days < 30) {
        durationText = '$days days';
      } else {
        final months = (days / 30).round();
        durationText = '$months months';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLoss ? Icons.trending_down : Icons.trending_up,
                    color:
                        isLoss
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF6B6B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          status == 'completed'
                              ? const Color(0xFF34C759).withOpacity(0.1)
                              : const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status == 'completed' ? 'Completed' : 'Changed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            status == 'completed'
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${startWeightDisplay.toStringAsFixed(1)} $unit → ${targetWeightDisplay.toStringAsFixed(1)} $unit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isLoss
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${weightChangeAbs.toStringAsFixed(1)} $unit ${isLoss ? 'lost' : 'gained'} • $durationText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nutrition Goals
                  _buildNutritionSection(theme),
                  const SizedBox(height: 16),
                  // Weight Entries
                  _buildWeightEntriesSection(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(ThemeData theme) {
    final calories = plan['dailyCalorieGoal'] as int? ?? 0;
    final protein = plan['proteinGoal'] as int? ?? 0;
    final carbs = plan['carbsGoal'] as int? ?? 0;
    final fat = plan['fatGoal'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Goals',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _NutritionCard(
                label: 'Calories',
                value: '$calories',
                unit: 'kcal',
                color: const Color(0xFF64D2FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NutritionCard(
                label: 'Protein',
                value: '$protein',
                unit: 'g',
                color: const Color(0xFF34C759),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NutritionCard(
                label: 'Carbs',
                value: '$carbs',
                unit: 'g',
                color: const Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NutritionCard(
                label: 'Fat',
                value: '$fat',
                unit: 'g',
                color: const Color(0xFFFFD93D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightEntriesSection(ThemeData theme) {
    if (weightEntries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Entries',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No weight entries recorded during this period',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Entries (${weightEntries.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weightEntries.length,
            itemBuilder: (context, index) {
              final entry = weightEntries[index];
              final weight = (entry['weight'] as num?)?.toDouble() ?? 0.0;
              final timestamp = entry['timestamp'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();

              final weightDisplay = useMetric ? weight : (weight * 2.20462);
              final unit = useMetric ? 'kg' : 'lbs';

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weightDisplay.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      unit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.month}/${date.day}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
