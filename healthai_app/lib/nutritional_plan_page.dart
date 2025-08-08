import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';
import 'providers/preferences_provider.dart';

class NutritionalPlanPage extends StatefulWidget {
  @override
  _NutritionalPlanPageState createState() => _NutritionalPlanPageState();
}

class _NutritionalPlanPageState extends State<NutritionalPlanPage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? originalData;
  String? editingField;
  bool isLoading = true;
  bool isSaving = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userData = Map<String, dynamic>.from(doc.data() ?? {});
        originalData = Map<String, dynamic>.from(doc.data() ?? {});
        isLoading = false;
        hasChanges = false;
      });
    }
  }

  void _startEdit(String field) {
    setState(() => editingField = field);
  }

  void _cancelEdit() {
    setState(() {
      editingField = null;
      userData = Map<String, dynamic>.from(originalData!);
      hasChanges = false;
    });
  }

  void _undoChanges() {
    setState(() {
      userData = Map<String, dynamic>.from(originalData!);
      hasChanges = false;
    });
  }

  void _updateField(String field, dynamic value) {
    setState(() {
      userData![field] = value;
      hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && userData != null) {
      // Check if weight was changed
      final originalWeight = originalData?['weight']?.toDouble() ?? 0.0;
      final newWeight = userData!['weight']?.toDouble() ?? 0.0;
      final weightChange = newWeight - originalWeight;
      
      // Update the user data (but exclude startingWeight - it should never change after initial setup)
      final updateData = Map<String, dynamic>.from(userData!);
      updateData.remove('startingWeight'); // Never update starting weight
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
      
      // If weight changed, also update the weight change tracking
      if (weightChange != 0) {
        // Get current total weight change
        final currentTotalChange = originalData?['totalWeightChange']?.toDouble() ?? 0.0;
        final newTotalChange = currentTotalChange + weightChange;
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'lastWeightChange': weightChange,
          'lastWeightUpdate': DateTime.now(),
          'totalWeightChange': newTotalChange,
        });
      }
      
      setState(() {
        originalData = Map<String, dynamic>.from(userData!);
        editingField = null;
        hasChanges = false;
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    final useMetric = prefs.useMetric;
    final localizations = AppLocalizations.of(context)!;
    if (isLoading || userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.nutritionalPlan)),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Calculate BMI
    final double weight = (userData!['weight'] ?? 70).toDouble();
    final double heightCm = (userData!['height'] ?? 170).toDouble();
    final double heightM = heightCm / 100.0;
    final double bmi = weight / (heightM * heightM);
    final double targetWeight = (userData!['targetWeight'] ?? weight).toDouble();
    final int age = (userData!['age'] ?? 18).toInt();
    final int? calories = userData!['dailyCalorieGoal'] != null ? userData!['dailyCalorieGoal'] as int : null;
    final int? protein = userData!['proteinGoal'] != null ? userData!['proteinGoal'] as int : null;
    final int? carbs = userData!['carbsGoal'] != null ? userData!['carbsGoal'] as int : null;
    final int? fat = userData!['fatGoal'] != null ? userData!['fatGoal'] as int : null;
    // Unit conversions
    final double displayWeight = useMetric ? weight : (weight * 2.20462);
    final String weightUnit = useMetric ? 'kg' : 'lb';
    String heightDisplay;
    if (useMetric) {
      heightDisplay = '${heightCm.toStringAsFixed(1)} cm';
    } else {
      int totalInches = (heightCm * 0.393701).round();
      int feet = totalInches ~/ 12;
      int inches = totalInches % 12;
      heightDisplay = "${feet}'${inches}\" ft";
    }
    return Scaffold(
      appBar: AppBar(title: Text(localizations.nutritionalPlan)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary
            Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(label: localizations.bmi, value: bmi.toStringAsFixed(1)),
                    _SummaryItem(label: localizations.age, value: '$age'),
                    _SummaryItem(label: localizations.weight, value: '${displayWeight.toStringAsFixed(1)} $weightUnit'),
                    _SummaryItem(label: localizations.target, value: '${useMetric ? targetWeight.toStringAsFixed(1) : (targetWeight * 2.20462).toStringAsFixed(1)} $weightUnit'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            // Editable Cards
            _EditableCard(
              label: localizations.age,
              value: '$age',
              isEditing: editingField == 'age',
              onTap: () => _startEdit('age'),
              editor: editingField == 'age'
                  ? _NumberEditor(
                      initial: age,
                      min: 16,
                      max: 100,
                      onChanged: (v) => _updateField('age', v),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.weight,
              value: '${displayWeight.toStringAsFixed(1)} $weightUnit',
              isEditing: editingField == 'weight',
              onTap: () => _startEdit('weight'),
              editor: editingField == 'weight'
                  ? _SliderEditor(
                      initial: displayWeight,
                      min: useMetric ? 30 : 66,
                      max: useMetric ? 200 : 440,
                      unit: weightUnit,
                      onChanged: (v) => _updateField('weight', useMetric ? v : v / 2.20462),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.height,
              value: heightDisplay,
              isEditing: editingField == 'height',
              onTap: () => _startEdit('height'),
              editor: editingField == 'height'
                  ? (useMetric
                      ? _SliderEditor(
                          initial: heightCm,
                          min: 100,
                          max: 220,
                          unit: 'cm',
                          onChanged: (v) => _updateField('height', v),
                        )
                      : _FtInSliderEditor(
                          cm: heightCm,
                          onChanged: (ft, inch) => _updateField('height', (ft * 12 + inch) * 2.54),
                        ))
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.targetWeight,
              value: '${useMetric ? targetWeight.toStringAsFixed(1) : (targetWeight * 2.20462).toStringAsFixed(1)} $weightUnit',
              isEditing: editingField == 'targetWeight',
              onTap: () => _startEdit('targetWeight'),
              editor: editingField == 'targetWeight'
                  ? _SliderEditor(
                      initial: useMetric ? targetWeight : targetWeight * 2.20462,
                      min: useMetric ? 30 : 66,
                      max: useMetric ? 200 : 440,
                      unit: weightUnit,
                      onChanged: (v) => _updateField('targetWeight', useMetric ? v : v / 2.20462),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.calorieGoal,
              value: calories != null ? '$calories kcal' : localizations.notSet,
              isEditing: editingField == 'dailyCalorieGoal',
              onTap: () => _startEdit('dailyCalorieGoal'),
              editor: editingField == 'dailyCalorieGoal'
                  ? _SliderEditor(
                      initial: calories?.toDouble() ?? 2000,
                      min: 1000,
                      max: 5000,
                      unit: 'kcal',
                      onChanged: (v) => _updateField('dailyCalorieGoal', v.round()),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.proteinGoal,
              value: protein != null ? '$protein g' : localizations.notSet,
              isEditing: editingField == 'proteinGoal',
              onTap: () => _startEdit('proteinGoal'),
              editor: editingField == 'proteinGoal'
                  ? _SliderEditor(
                      initial: protein?.toDouble() ?? 120,
                      min: 40,
                      max: 300,
                      unit: 'g',
                      onChanged: (v) => _updateField('proteinGoal', v.round()),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.carbGoal,
              value: carbs != null ? '$carbs g' : localizations.notSet,
              isEditing: editingField == 'carbsGoal',
              onTap: () => _startEdit('carbsGoal'),
              editor: editingField == 'carbsGoal'
                  ? _SliderEditor(
                      initial: carbs?.toDouble() ?? 250,
                      min: 40,
                      max: 600,
                      unit: 'g',
                      onChanged: (v) => _updateField('carbsGoal', v.round()),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.fatGoal,
              value: fat != null ? '$fat g' : localizations.notSet,
              isEditing: editingField == 'fatGoal',
              onTap: () => _startEdit('fatGoal'),
              editor: editingField == 'fatGoal'
                  ? _SliderEditor(
                      initial: fat?.toDouble() ?? 70,
                      min: 10,
                      max: 200,
                      unit: 'g',
                      onChanged: (v) => _updateField('fatGoal', v.round()),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
            _EditableCard(
              label: localizations.waterIntake,
              value: userData!['waterIntake'] ?? '-',
              isEditing: editingField == 'waterIntake',
              onTap: () => _startEdit('waterIntake'),
              editor: editingField == 'waterIntake'
                  ? _SliderEditor(
                      initial: double.tryParse((userData!['waterIntake'] ?? '2.0').toString().replaceAll('L', '').replaceAll('+', '')) ?? 2.0,
                      min: 0.5,
                      max: 5.0,
                      unit: 'L',
                      onChanged: (v) => _updateField('waterIntake', v.toStringAsFixed(1) + 'L'),
                    )
                  : null,
              hasChanges: hasChanges,
              isSaving: isSaving,
              onUndo: _undoChanges,
              onCancel: _cancelEdit,
              onSave: _saveChanges,
              localizations: localizations,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[800], fontSize: 15)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }
}

class _EditableCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final VoidCallback onTap;
  final Widget? editor;
  final Widget? trailing;
  final bool hasChanges;
  final bool isSaving;
  final VoidCallback? onUndo;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final AppLocalizations localizations;
  
  const _EditableCard({
    required this.label, 
    required this.value, 
    required this.isEditing, 
    required this.onTap, 
    this.editor, 
    this.trailing,
    required this.hasChanges,
    required this.isSaving,
    this.onUndo,
    this.onCancel,
    this.onSave,
    required this.localizations,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isEditing ? 6 : 1,
      child: InkWell(
        onTap: isEditing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.all(isEditing ? 18 : 16),
          decoration: BoxDecoration(
            color: isEditing ? Colors.green[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEditing
                ? [BoxShadow(color: Colors.green.withOpacity(0.08), blurRadius: 16, offset: Offset(0, 4))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              SizedBox(height: 6),
              isEditing && editor != null
                  ? editor!
                  : Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              // Action buttons that appear under the card when editing
              if (isEditing) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (hasChanges)
                      OutlinedButton.icon(
                        icon: Icon(Icons.undo),
                        label: Text(localizations.undo),
                        onPressed: onUndo,
                      ),
                    if (onCancel != null)
                      OutlinedButton.icon(
                        icon: Icon(Icons.cancel),
                        label: Text(localizations.cancel),
                        onPressed: onCancel,
                      ),
                    ElevatedButton.icon(
                      icon: isSaving ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.save),
                      label: Text(localizations.save),
                      onPressed: hasChanges && !isSaving ? onSave : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderEditor extends StatelessWidget {
  final double initial;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;
  const _SliderEditor({required this.initial, required this.min, required this.max, required this.unit, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: initial,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: '${initial.toStringAsFixed(1)} $unit',
          onChanged: onChanged,
        ),
        Text('${initial.toStringAsFixed(1)} $unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

class _NumberEditor extends StatelessWidget {
  final int initial;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _NumberEditor({required this.initial, required this.min, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: initial > min ? () => onChanged(initial - 1) : null,
        ),
        Text('$initial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: initial < max ? () => onChanged(initial + 1) : null,
        ),
      ],
    );
  }
}

class _FtInSliderEditor extends StatefulWidget {
  final double cm;
  final void Function(int, int) onChanged;
  const _FtInSliderEditor({required this.cm, required this.onChanged});
  @override
  State<_FtInSliderEditor> createState() => _FtInSliderEditorState();
}

class _FtInSliderEditorState extends State<_FtInSliderEditor> {
  late int feet;
  late int inches;
  @override
  void initState() {
    super.initState();
    int totalInches = (widget.cm * 0.393701).round();
    feet = totalInches ~/ 12;
    inches = totalInches % 12;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('ft:'),
        SizedBox(width: 6),
        Expanded(
          child: Slider(
            value: feet.toDouble(),
            min: 3,
            max: 7,
            divisions: 4,
            label: '$feet',
            onChanged: (v) {
              setState(() => feet = v.round());
              widget.onChanged(feet, inches);
            },
          ),
        ),
        SizedBox(width: 12),
        Text('in:'),
        SizedBox(width: 6),
        Expanded(
          child: Slider(
            value: inches.toDouble(),
            min: 0,
            max: 11,
            divisions: 11,
            label: '$inches',
            onChanged: (v) {
              setState(() => inches = v.round());
              widget.onChanged(feet, inches);
            },
          ),
        ),
      ],
    );
  }
} 