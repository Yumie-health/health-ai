import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'scan_result_page.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

class GeneratedMealFromFridgePage extends StatefulWidget {
  final Map<String, dynamic> meal;
  const GeneratedMealFromFridgePage({Key? key, required this.meal}) : super(key: key);

  @override
  State<GeneratedMealFromFridgePage> createState() => _GeneratedMealFromFridgePageState();
}

class _GeneratedMealFromFridgePageState extends State<GeneratedMealFromFridgePage> {
  final GlobalKey _screenshotKey = GlobalKey();
  bool _hideButtons = false;

  Future<void> _takeScreenshot() async {
    setState(() => _hideButtons = true);
    await Future.delayed(Duration(milliseconds: 100)); // Wait for UI to update
    try {
      RenderRepaintBoundary boundary = _screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final picturesDir = Directory('/storage/emulated/0/Pictures');
      if (!picturesDir.existsSync()) {
        await picturesDir.create(recursive: true);
      }
      final filePath = '${picturesDir.path}/meal_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).writeAsBytes(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screenshot saved to Pictures!'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => Share.shareXFiles([XFile(file.path)], text: 'Check out this meal!'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save screenshot: $e')));
    } finally {
      setState(() => _hideButtons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final localizations = AppLocalizations.of(context)!;
    final macros = [
      {'label': localizations.calories, 'value': meal['calories']?.toString() ?? '-', 'color': Colors.green[700] ?? Colors.green},
      {'label': localizations.protein, 'value': '${meal['protein'] ?? '-'}g', 'color': Colors.blue[700] ?? Colors.blue},
      {'label': localizations.carbs, 'value': '${meal['carbs'] ?? '-'}g', 'color': Colors.orange[700] ?? Colors.orange},
      {'label': localizations.fat, 'value': '${meal['fat'] ?? '-'}g', 'color': Colors.red[400] ?? Colors.red},
    ];
    final recipe = (meal['recipe'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final ingredients = (meal['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['meal_name'] ?? 'Generated Meal'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_hideButtons)
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.green),
              tooltip: 'Screenshot',
              onPressed: _takeScreenshot,
            ),
        ],
      ),
      body: RepaintBoundary(
        key: _screenshotKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal['meal_name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: macros.map((m) => Column(
                      children: [
                        Text(m['label'] as String, style: TextStyle(color: m['color'] as Color?, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text(m['value'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: m['color'] as Color?)),
                      ],
                    )).toList(),
                  ),
                ),
              ),
              SizedBox(height: 18),
              if (ingredients.isNotEmpty) ...[
                Text(localizations.ingredients, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ingredients.map((i) => Chip(label: Text(i))).toList(),
                ),
                SizedBox(height: 18),
              ],
              Text(
                localizations.localeName.startsWith('ar')
                    ? 'طريقة التحضير'
                    : localizations.localeName.startsWith('es')
                        ? 'Cómo preparar'
                        : 'How to Make',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: recipe.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${i + 1}. ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(recipe[i])),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),
              if (!_hideButtons)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ScanResultPage(
                                imagePath: '',
                                prefill: {
                                  'food_name': meal['meal_name'] ?? '',
                                  'calories': meal['calories']?.toString() ?? '',
                                  'protein': meal['protein']?.toString() ?? '',
                                  'carbs': meal['carbs']?.toString() ?? '',
                                  'fat': meal['fat']?.toString() ?? '',
                                  'ingredients': (meal['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [],
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(localizations.logMeal),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(localizations.discard),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 