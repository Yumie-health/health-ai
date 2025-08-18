// RECREATED PAGE (glassmorphism design)
import 'dart:ui';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../l10n/app_localizations.dart';

enum _Range { w1, m1, m3, m6, y1, all, plan }

class WeightAnalyticsPage extends StatefulWidget {
  const WeightAnalyticsPage({super.key});
  @override
  State<WeightAnalyticsPage> createState() => _WeightAnalyticsPageState();
}

class _WeightAnalyticsPageState extends State<WeightAnalyticsPage> {
  _Range _range = _Range.m1;
  bool _loading = true;
  List<_Point> _points = [];
  double _current = 0;
  double _target = 0;
  double _starting = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Load user profile data
    final u = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = u.data() as Map<String, dynamic>?;
    _current = (data?['weight'] as num?)?.toDouble() ?? 0;
    _target = (data?['targetWeight'] as num?)?.toDouble() ?? 0;
    _starting = (data?['startingWeight'] as num?)?.toDouble() ?? 0;
    
    // Load weight entries
    final w = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).collection('weights')
        .orderBy('timestamp', descending: true)
        .limit(400)
        .get();
    final list = w.docs
        .map((d)=>d.data())
        .where((m)=> (m['isDeleted'] ?? false)==false)
        .map((m)=> _Point(((m['timestamp'] as Timestamp?)?.toDate()??DateTime.now()), (m['weight'] as num?)?.toDouble() ?? _current))
        .toList()
        .reversed
        .toList();
    
    // Fallback starting weight from earliest record if not explicitly set
    final derivedStarting = list.isNotEmpty ? list.first.value : _current;
    
    // Debug: Check if we're using synthetic data
    final usingSynthetic = list.isEmpty;
    if (usingSynthetic) {
      print('⚠️ Weight Analytics: Using synthetic data - no real weight entries found');
      print('Current weight: $_current, Target: $_target');
    } else {
      print('✅ Weight Analytics: Using real data - ${list.length} weight entries found');
    }
    
    setState((){ 
      _points = list; // Only use real data, no synthetic fallback
      _starting = _starting==0? derivedStarting : _starting; 
      _loading=false; 
    });
  }

  List<_Point> _synthetic(){
    final now = DateTime.now();
    final days = 30;
    final step = (_current - _target)/days;
    return List.generate(days+1,(i){
      final d = now.subtract(Duration(days: days-i));
      return _Point(d, _current - step*i);
    });
  }

  List<_Point> _filtered(){
    DateTime? start;
    final now = DateTime.now();
    switch(_range){
      case _Range.w1: start = now.subtract(const Duration(days: 7)); break;
      case _Range.m1: start = now.subtract(const Duration(days: 30)); break;
      case _Range.m3: start = now.subtract(const Duration(days: 90)); break;
      case _Range.m6: start = now.subtract(const Duration(days: 180)); break;
      case _Range.y1: start = now.subtract(const Duration(days: 365)); break;
      case _Range.all: start = null; break;
      case _Range.plan: start = now.subtract(const Duration(days: 90)); break; // show recent trend before projection
    }
    final source = start==null? _points : _points.where((p)=> p.time.isAfter(start!)).toList();
    if(source.length<2 && _points.isNotEmpty) return [_points.first,_points.last];
    return source;
  }

  // Expected weekly from nutrition (signed): deficit -> negative, surplus -> positive
double _expectedWeeklyFromNutrition(Map<String, dynamic>? userData, bool useMetric) {
  if (userData == null) return 0.0;

  // Prefer an explicit weekly goal if you store one (e.g., -0.5 kg/week)
  final weeklyGoal = (userData['weeklyRateGoal'] as num?)?.toDouble();
  if (weeklyGoal != null) return weeklyGoal;

  // Daily energy balance (kcal/day), negative = deficit
  final energyBalance = (userData['dailyEnergyBalance'] as num?)?.toDouble();
  if (energyBalance != null) {
    final perUnit = useMetric ? 7700.0 : 3500.0; // kcal per kg or lb
    return (energyBalance * 7.0) / perUnit;
  }

  // Legacy fields
  final calorieGoal = (userData['calorieGoal'] as num?)?.toDouble();
  final currentCalories = (userData['currentCalories'] as num?)?.toDouble();
  if (calorieGoal != null && calorieGoal > 0) {
    // Handle case when currentCalories is 0 or null (no meals logged today)
    final actualCalories = currentCalories ?? 0.0;
    final dailyDeficit = calorieGoal - actualCalories; // >0 deficit (loss), <0 surplus (gain)
    
    // If no calories logged today, assume a reasonable daily intake
    if (actualCalories == 0.0) {
      // Assume user will eat around their goal, so small deficit
      final assumedDeficit = useMetric ? 500.0 : 1000.0; // 500 cal deficit for kg, 1000 for lbs
      final perUnit = useMetric ? 7700.0 : 3500.0;
      final weekly = (assumedDeficit * 7.0) / perUnit;
      final lo = useMetric ? -1.5 : -3.3;
      final hi = useMetric ?  1.0 :  2.2;
      return weekly.clamp(lo, hi);
    }
    
    // Normal calculation when calories are logged
    if (dailyDeficit.abs() < 200) return 0.0; // avoid noisy zeros
    final perUnit = useMetric ? 7700.0 : 3500.0;
    final weekly = (dailyDeficit * 7.0) / perUnit;
    // keep expectations conservative
    final lo = useMetric ? -1.5 : -3.3;
    final hi = useMetric ?  1.0 :  2.2;
    return weekly.clamp(lo, hi);
  }

  return 0.0;
}

// Robust weekly rate from weights via OLS over ~last 60 days (signed, in display units)
double _weeklyFromWeights(List<_Point> pts, double scale) {
  if (pts.length < 3) {
    if (pts.length >= 2) {
      final dDays = pts.last.time.difference(pts.first.time).inDays;
      if (dDays >= 7) {
        final dy = (pts.last.value - pts.first.value) * scale;
        return (dy / dDays) * 7.0;
      }
    }
    return 0.0;
  }

  final cutoff = DateTime.now().subtract(const Duration(days: 60));
  final recent = pts.where((p) => p.time.isAfter(cutoff)).toList();
  final used = recent.length >= 3 ? recent : pts;

  final t0 = used.first.time;
  final xs = <double>[];
  final ys = <double>[];
  for (final p in used) {
    xs.add(p.time.difference(t0).inHours / 24.0); // days
    ys.add(p.value * scale);                       // display units
  }

  final n = xs.length;
  final meanX = xs.reduce((a, b) => a + b) / n;
  final meanY = ys.reduce((a, b) => a + b) / n;

  double num = 0, den = 0;
  for (int i = 0; i < n; i++) {
    final dx = xs[i] - meanX;
    num += dx * (ys[i] - meanY);
    den += dx * dx;
  }
  if (den == 0) return 0.0;

  final slopePerDay = num / den;
  final weekly = slopePerDay * 7.0; // signed
  final lo = scale == 1.0 ? -2.0 : -4.4; // ~ -2 kg/wk | -4.4 lb/wk
  final hi = scale == 1.0 ?  1.5 :  3.3; // ~ +1.5 kg/wk | +3.3 lb/wk
  return weekly.clamp(lo, hi);
}

// Gentle fallback when measured trend ~0; sign points toward the goal
double _healthyWeeklyFallback(bool useMetric, double distanceSigned) {
  final loss = useMetric ? -0.5 : -1.0; // −0.5 kg/wk | −1 lb/wk
  final gain = useMetric ?  0.25 :  0.5; // +0.25 kg/wk | +0.5 lb/wk
  if (distanceSigned < 0) return loss; // need to go down
  if (distanceSigned > 0) return gain; // need to go up
  return 0.0;
}

Future<double> _calculateWeeklyRate(List<_Point> points, bool useMetric, double scale) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ No user found for weekly rate calculation');
    return 0.0;
  }

  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>?;

    final expected = _expectedWeeklyFromNutrition(userData, useMetric); // signed
    final measured = _weeklyFromWeights(points, scale);                  // signed

    int spanDays = 0;
    if (points.length >= 2) {
      spanDays = max(0, points.last.time.difference(points.first.time).inDays);
    }
    final hasGoodData = points.length >= 3 && spanDays >= 14;

    // Blend: if we have good data, weight trend dominates
    final weekly = hasGoodData ? (measured * 0.7 + expected * 0.3)
                               : (measured * 0.3 + expected * 0.7);

    final lo = scale == 1.0 ? -2.0 : -4.4;
    final hi = scale == 1.0 ?  1.5 :  3.3;
    final result = weekly.clamp(lo, hi);


    return result;
  } catch (e) {
    // Error calculating weekly rate
    return _weeklyFromWeights(points, scale);
  }
}

  @override
  Widget build(BuildContext context) {
    final useMetric = context.watch<PreferencesProvider?>()?.useMetric ?? true;
    final unit = useMetric? 'kg' : 'lbs';
    final scale = useMetric? 1.0 : 2.20462;
    final theme = Theme.of(context);
    final bg = _elevatedBackground(context);

    if(_loading){
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.weightAnalytics), backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child:CircularProgressIndicator())
      );
    }

    return FutureBuilder<double>(
      future: _calculateWeeklyRate(_points, useMetric, scale),
      builder: (context, snapshot) {
        final weekly = snapshot.data ?? 0.0;

        // Distances in scaled units
        final currentScaled = _current * scale;
        final targetScaled  = _target  * scale;

        // Signed distance: positive if target above current (need to gain),
        // negative if target below current (need to lose).
        final distanceToGoal = (targetScaled - currentScaled);
        final remainingScaled = distanceToGoal.abs();

        double signedWeekly = weekly; // signed units/week (loss < 0, gain > 0)

        // If weekly is ~0, nudge with a healthy fallback toward the goal
        if (signedWeekly.abs() < (useMetric ? 0.05 : 0.1)) {
          signedWeekly = _healthyWeeklyFallback(useMetric, distanceToGoal);
        }

        // ETA rules:
        // - If essentially at goal -> 0
        // - Only show ETA if the current trend heads TOWARD the goal
        //   (distance and weekly must have the same sign).
        double? weeksToGoal;
        final atGoal = remainingScaled <= (useMetric ? 0.05 : 0.1);
        if (atGoal) {
          weeksToGoal = 0;
        } else if (signedWeekly == 0) {
          weeksToGoal = null;
        } else if (distanceToGoal * signedWeekly > 0) {
          weeksToGoal = remainingScaled / signedWeekly.abs();
        } else {
          weeksToGoal = null; // moving away from goal
        }

        final timeText = weeksToGoal == null
            ? '—'
            : (weeksToGoal <= 0.05 ? 'Reached' : _formatWeeks(weeksToGoal));



        // Build series from logged weights (solid) and projection (dashed)
        final List<DateTime> xDates = [];
        final List<FlSpot> actualSpots = [];
        final List<FlSpot> projSpots = [];
        final filtered = _filtered();
        if(filtered.isNotEmpty){
          final startDate = filtered.first.time;
          for(final p in filtered){
            final x = p.time.difference(startDate).inDays.toDouble();
            final y = p.value*scale;
            actualSpots.add(FlSpot(x, y));
            xDates.add(p.time);
          }
        }

        // Projection line (dashed) based on current trend
        if(actualSpots.isNotEmpty && weeksToGoal != null && weeksToGoal! > 0){
          final last = actualSpots.last;
          final startX = last.x;
          final startY = last.y;
          final perDay = weekly / 7; // Convert weekly rate to daily rate
          int horizonDays = weeksToGoal!=null && weeksToGoal!>0
            ? (weeksToGoal!*7).ceil()
            : 30; // fallback to 30 days
          for(int i=1; i<=horizonDays; i++){
            final x = startX + i;
            final y = startY + (perDay * i);
            projSpots.add(FlSpot(x, y));
          }
        }

        // Total change since start
        final totalChangeScaled = ((_current - _starting) * scale);
        final totalChangeAbsStr = totalChangeScaled.abs().toStringAsFixed(1);
        final signedChangeStr = '${totalChangeScaled>=0? '+':'-'}$totalChangeAbsStr $unit';

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.weightAnalytics,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Key stats (no graph)
                    Row(children:[
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.toGoal,
                        value: '${remainingScaled.abs().toStringAsFixed(1)} $unit',
                        subtitle: atGoal? 'goal reached' : AppLocalizations.of(context)!.remaining,
                        highlight: true,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.weeklyRate,
                        value: '${signedWeekly.abs().toStringAsFixed(1)} $unit',
                        subtitle: signedWeekly == 0.0 ? 'log weight to see trend' : (signedWeekly <= 0 ? AppLocalizations.of(context)!.weeklyLoss : 'weekly gain'),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children:[
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.starting,
                        value: '${(_starting*scale).toStringAsFixed(1)} $unit',
                        subtitle: AppLocalizations.of(context)!.startingWeight,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.current,
                        value: '${(_current*scale).toStringAsFixed(1)} $unit',
                        subtitle: AppLocalizations.of(context)!.today,
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children:[
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.targetLabel,
                        value: '${(_target*scale).toStringAsFixed(1)} $unit',
                        subtitle: AppLocalizations.of(context)!.goalWeight,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _InfoCard(
                        title: AppLocalizations.of(context)!.eta,
                        value: weeksToGoal==null? '—' : (weeksToGoal<=0.05? 'Reached' : _formatWeeks(weeksToGoal)),
                        subtitle: weeksToGoal==null? 'insufficient data' : _etaDateText(weeksToGoal),
                      )),
                    ]),
                    const SizedBox(height: 18),

                    // Expectation text
                    signedWeekly == 0.0 
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5EEF9)),
                          ),
                          child: Text(
                            'Log your weight entries to see personalized trends and projections.',
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                          ),
                        )
                      : _ExpectationBlock(
                          weekly: signedWeekly,
                          unit: unit,
                          etaText: weeksToGoal==null? '—' : _etaDateText(weeksToGoal),
                          remaining: remainingScaled,
                        ),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.expectationsDisclaimer, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),

                    const SizedBox(height: 18),
                    _BigDeltaCard(
                      isLoss: totalChangeScaled <= 0,
                      valueText: '${totalChangeScaled.abs().toStringAsFixed(1)} $unit',
                    ),
                    const SizedBox(height: 12),
                    // References for medical guidance
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(AppLocalizations.of(context)!.references, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse('https://www.cdc.gov/healthyweight/assessing/bmi/index.html'), mode: LaunchMode.externalApplication);
                            },
                            child: Text(AppLocalizations.of(context)!.cdcAboutBmi),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse('https://www.dietaryguidelines.gov/'), mode: LaunchMode.externalApplication);
                            },
                            child: Text(AppLocalizations.of(context)!.usdaDietaryGuidelines),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Gentle background that works for light/dark
  Color _elevatedBackground(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0E1116) : const Color(0xFFF6F7FB);
  }

  // Delta helpers for header summary like screenshot
  String _rangePastLabel(){
    switch(_range){
      case _Range.w1: return 'past week';
      case _Range.m1: return 'past month';
      case _Range.m3: return 'past 3 months';
      case _Range.m6: return 'past 6 months';
      case _Range.y1: return 'past year';
      case _Range.all: return 'all time';
      case _Range.plan: return 'projection';
    }
  }
  bool _deltaIsDown(List<_Point> data){
    if(data.length<2) return false;
    return data.last.value <= data.first.value;
  }
  String _deltaText(List<_Point> data, double scale, String unit){
    if(data.length<2) return '0 $unit';
    final change = (data.last.value - data.first.value)*scale;
    final sign = change<0? '↓' : '↑';
    return '$sign ${change.abs().toStringAsFixed(1)} $unit';
  }

  String _labelSince(List<_Point> d){
    if(d.isEmpty) return 'start';
    final dt = d.first.time;
    return '${_month(dt.month)} ${dt.day}';
  }
  String _month(int m){
    const names=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[(m-1).clamp(0,11)];
  }
  String _formatWeeks(double w){
    if(w>8) return '${(w/4).toStringAsFixed(0)} months';
    return '${w.toStringAsFixed(1)} weeks';
  }
  String _etaDateText(double? weeks){
    if(weeks==null) return '—';
    final days = (weeks*7).round();
    final eta = DateTime.now().add(Duration(days: days));
    return '${_month(eta.month)} ${eta.day}';
  }
  String _projectionLabel(){
    switch(_range){
      case _Range.w1: return '1 week';
      case _Range.m1: return '1 month';
      case _Range.m3: return '3 months';
      case _Range.m6: return '6 months';
      case _Range.y1: return '1 year';
      case _Range.all: return 'All time';
      case _Range.plan: return 'Plan to goal';
    }
  }
}

/// Time to Goal compact card
class _TimeToGoalCard extends StatelessWidget {
  final String text;
  const _TimeToGoalCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Time to Goal',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: const Color(0xFF34C759),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaSummary extends StatelessWidget{
  final String deltaText; final bool directionDown; final String rangeLabel;
  const _DeltaSummary({required this.deltaText,required this.directionDown, required this.rangeLabel});
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EEF9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0,8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
        Icon(directionDown? Icons.south : Icons.north, size: 18, color: directionDown? const Color(0xFF0DA14B): const Color(0xFF1565C0)),
        const SizedBox(height: 4),
        Text(deltaText, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
        const SizedBox(height: 2),
        Text(rangeLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget{
  final String title; final String value; final String subtitle; final bool highlight;
  const _InfoCard({required this.title, required this.value, required this.subtitle, this.highlight=false});
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    final isDark = theme.brightness==Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFEFFAF1) : (isDark? const Color(0xFF151A22) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight? const Color(0xFFBEE3C2) : (isDark? Colors.white.withOpacity(0.06): Colors.black.withOpacity(0.06))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark?0.25:0.06), blurRadius: 18, offset: const Offset(0,10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(title, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[700], letterSpacing: 0.2)),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2, color: highlight? const Color(0xFF2E7D32): null)),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ]),
    );
  }
}

class _ExpectationBlock extends StatelessWidget{
  final double weekly; final String unit; final String etaText; final double remaining;
  const _ExpectationBlock({required this.weekly, required this.unit, required this.etaText, required this.remaining});
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    
    // Handle case when weekly rate is 0 (no trend)
    if (weekly == 0.0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EEF9)),
        ),
        child: Text(
          'Your weight trend is currently flat. Log more weight entries to see your progress trend.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
        ),
      );
    }
    
    final losing = weekly < 0;
    final dir = losing ? AppLocalizations.of(context)!.loseVerb : AppLocalizations.of(context)!.gainVerb;
    final rate = weekly.abs().toStringAsFixed(1);
    final remainingFormatted = remaining.toStringAsFixed(1);
    
    // Create properly formatted expectation text using localization
    String expectationText;
    final l = AppLocalizations.of(context)!;
    
    if (weekly < 0) {
      // Losing weight with actual trend data
      if (etaText == '—' || etaText == 'Reached') {
        expectationText = l.expectationBlurb(l.loseVerb, '', rate, remainingFormatted, unit);
      } else {
        expectationText = l.expectationBlurb(l.loseVerb, etaText, rate, remainingFormatted, unit);
      }
    } else if (weekly > 0) {
      // Gaining weight
      expectationText = l.expectationBlurb(l.gainVerb, etaText, rate, remainingFormatted, unit);
    } else {
      // No trend data available, provide estimate
      if (etaText == '—' || etaText == 'Reached') {
        expectationText = l.weightTrendNoData(remainingFormatted, unit);
      } else {
        expectationText = l.weightTrendHealthyRate(rate, etaText, remainingFormatted, unit);
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Text(
        expectationText,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
    );
  }
}

class _BigDeltaCard extends StatelessWidget{
  final bool isLoss; final String valueText;
  const _BigDeltaCard({required this.isLoss, required this.valueText});
  @override Widget build(BuildContext context){
    final theme = Theme.of(context);
    final bg = isLoss ? const Color(0xFFE3F2FD) : const Color(0xFFFDECEC);
    final border = isLoss ? const Color(0xFFBCDDF8) : const Color(0xFFF8C5C5);
    final textColor = isLoss ? const Color(0xFF1565C0) : const Color(0xFFD32F2F);
    final icon = isLoss ? Icons.south_east : Icons.north_east;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0,10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children:[
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 10),
            Text(valueText, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: textColor)),
          ]),
          Text(AppLocalizations.of(context)!.sinceStart, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

/// Modern stat card with accent dot
class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final bool isPositive;
  final bool isGoal;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.delta,
    this.isPositive = true,
    this.isGoal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          // Accent dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isGoal 
                  ? [const Color(0xFF34C759), const Color(0xFF7AE08A)]
                  : isPositive 
                    ? [const Color(0xFF64D2FF), const Color(0xFF4E8CFF)]
                    : [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.4,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    )),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isGoal 
                ? const Color(0xFF34C759).withOpacity(0.12)
                : isPositive 
                  ? const Color(0xFF34C759).withOpacity(0.12)
                  : const Color(0xFFFF6B6B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isGoal 
                  ? const Color(0xFF34C759).withOpacity(0.3)
                  : isPositive 
                    ? const Color(0xFF34C759).withOpacity(0.3)
                    : const Color(0xFFFF6B6B).withOpacity(0.3),
              ),
            ),
            child: Text(
              delta,
              style: TextStyle(
                color: isGoal 
                  ? const Color(0xFF219653)
                  : isPositive 
                    ? const Color(0xFF219653)
                    : const Color(0xFFE53E3E),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft glassmorphism container with blur + subtle border/shadow
class _GlassChartCard extends StatelessWidget {
  final List<FlSpot> actualSpots;
  final List<FlSpot> projectedSpots;
  final List<DateTime> dates;
  final String unit;
  final _Range range;
  final double target;
  final ValueChanged<_Range> onChange;

  const _GlassChartCard({
    required this.actualSpots,
    required this.projectedSpots,
    required this.dates,
    required this.unit,
    required this.range,
    required this.target,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient backdrop
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
                colors: isDark
                    ? [const Color(0xFF11151B), const Color(0xFF121824), const Color(0xFF0E121A)]
                    : [const Color(0xFFEFF3FF), const Color(0xFFEAF0FF), const Color(0xFFE6ECFC)],
              ),
            ),
          ),
          // Blur layer for glass effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: const SizedBox.expand(),
          ),
          // Foreground with border + shadow
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.5),
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                _RangeTabs(selected: range, onChange: onChange),
                const SizedBox(height: 8),
                Expanded(child: _WeightLineChart(
                  actualSpots: actualSpots,
                  projectedSpots: projectedSpots,
                  dates: dates,
                  unit: unit,
                  range: range,
                  target: target,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Range tabs
class _RangeTabs extends StatelessWidget {
  final _Range selected;
  final ValueChanged<_Range> onChange;

  const _RangeTabs({required this.selected, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RangeTab('1W', selected == _Range.w1, () => onChange(_Range.w1)),
        const SizedBox(width: 12),
        _RangeTab('1M', selected == _Range.m1, () => onChange(_Range.m1)),
        const SizedBox(width: 12),
        _RangeTab('3M', selected == _Range.m3, () => onChange(_Range.m3)),
        const SizedBox(width: 12),
        _RangeTab('6M', selected == _Range.m6, () => onChange(_Range.m6)),
        const SizedBox(width: 12),
        _RangeTab('1Y', selected == _Range.y1, () => onChange(_Range.y1)),
        const SizedBox(width: 12),
        _RangeTab('All', selected == _Range.all, () => onChange(_Range.all)),
        const SizedBox(width: 12),
        _RangeTab('Plan', selected == _Range.plan, () => onChange(_Range.plan)),
      ],
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeTab(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFF64D2FF).withOpacity(0.5),
              width: 1,
            ),
            gradient: isSelected ? const LinearGradient(colors: [Color(0xFF64D2FF), Color(0xFF4E8CFF)]) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// The star: elegant weight progress line chart
class _WeightLineChart extends StatelessWidget {
  final List<FlSpot> actualSpots;
  final List<FlSpot> projectedSpots;
  final List<DateTime> dates;
  final String unit;
  final _Range range;
  final double target;

  const _WeightLineChart({
    required this.actualSpots,
    required this.projectedSpots,
    required this.dates,
    required this.unit,
    required this.range,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ys = [...actualSpots.map((s)=>s.y), ...projectedSpots.map((s)=>s.y)];
    final minY = ys.isEmpty ? 0.0 : (ys.reduce((a, b) => a < b ? a : b) - 5).clamp(0.0, double.infinity);
    final maxY = ys.isEmpty ? 1.0 : (ys.reduce((a, b) => a > b ? a : b) + 5).toDouble();
    final bottomInterval = ((actualSpots.length + projectedSpots.length) / 5).clamp(1, 30).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: ((actualSpots.length + projectedSpots.length) - 1).toDouble().clamp(1, double.infinity),
        minY: minY,
        maxY: maxY,
        backgroundColor: Colors.transparent,
        clipData: const FlClipData.all(),

        // Smooth intro animation
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchSpotThreshold: 24,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            tooltipRoundedRadius: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((barSpot) {
                final idx = barSpot.spotIndex;
                final dt = (idx >= 0 && idx < dates.length) ? dates[idx] : DateTime.now();
                return LineTooltipItem(
                  "${_formatDate(dt)}\n",
                  TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.8,
                    color: const Color(0xFF64D2FF),
                  ),
                  children: [
                    TextSpan(
                      text: "${barSpot.y.toStringAsFixed(1)} $unit",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.85),
                      ),
                    ),
                  ],
                );
              }).toList();
            },
            tooltipMargin: 10,
            getTooltipColor: (_) => isDark
                ? const Color(0xFF0F1420).withOpacity(0.9)
                : Colors.white.withOpacity(0.96),
            showOnTopOfTheChartBoxArea: true,
          ),
        ),

        // Grid
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: bottomInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.07),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
            strokeWidth: 1,
          ),
        ),

        // Axes
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 10,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.1,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: bottomInterval,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
                final dt = dates[idx];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _getTimelineLabel(dt),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Subtle border
        borderData: FlBorderData(
          show: true,
          border: Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08), width: 1),
            bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08), width: 1),
          ),
        ),

        // Weight progress line
        lineBarsData: [
          // Goal line (if target is within visible range)
          if (target >= minY && target <= maxY)
            LineChartBarData(
              spots: [FlSpot(0, target), FlSpot(((actualSpots.length + projectedSpots.length) - 1).toDouble(), target)],
              isCurved: false,
              barWidth: 2,
              color: const Color(0xFF34C759).withOpacity(0.6),
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),

          // Actual weight progress line
          LineChartBarData(
            spots: actualSpots.isEmpty ? [const FlSpot(0,0)] : actualSpots,
            isCurved: true,
            curveSmoothness: 0.23,
            barWidth: 4.2,
            isStrokeCapRound: true,
            gradient: const LinearGradient(colors: [Color(0xFF64D2FF), Color(0xFF4E8CFF)]),
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, p, bar, i) => FlDotCirclePainter(
                radius: 3.8,
                strokeWidth: 1.8,
                color: const Color(0xFFEAF6FF),
                strokeColor: const Color(0xFF4E8CFF),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF64D2FF).withOpacity(0.22),
                  const Color(0xFF4E8CFF).withOpacity(0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Projected dashed line (Plan)
          if (projectedSpots.isNotEmpty)
            LineChartBarData(
              spots: projectedSpots,
              isCurved: true,
              curveSmoothness: 0.23,
              barWidth: 3,
              color: Colors.grey,
              dashArray: const [6,6],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    switch (range) {
      case _Range.w1:
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return dayNames[dt.weekday % 7];
      case _Range.m1:
        return '${dt.month}/${dt.day}';
      case _Range.m3:
      case _Range.m6:
      case _Range.y1:
      case _Range.all:
      case _Range.plan:
        return '${dt.month}/${dt.day}';
    }
  }

  String _getTimelineLabel(DateTime dt) {
    switch (range) {
      case _Range.w1:
        // Show day abbreviations for week view
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        return dayNames[dt.weekday % 7];
      case _Range.m1:
      case _Range.m3:
      case _Range.m6:
      case _Range.y1:
      case _Range.all:
        // Show day numbers for month view
        return dt.day.toString();
      case _Range.plan:
        // Show month names for plan view
        return _monthShort(dt.month);
    }
  }

  String _monthShort(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}

class _Point {
  final DateTime time;
  final double value;
  _Point(this.time, this.value);
}


