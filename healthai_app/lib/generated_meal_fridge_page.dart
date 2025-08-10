import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'scan_result_page.dart';
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
      
      // Save to photo gallery
      // final result = await ImageGallerySaver.saveImage(
      //   pngBytes,
      //   quality: 100,
      //   name: 'meal_screenshot_${DateTime.now().millisecondsSinceEpoch}',
      // );
      
      // if (result['isSuccess'] == true) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Screenshot saved to photo gallery!'),
      //       action: SnackBarAction(
      //         label: 'Share',
      //         onPressed: () {
      //           // Create a temporary file for sharing
      //           _shareScreenshot(pngBytes);
      //         },
      //       ),
      //     ),
      //   );
      // } else {
      //   throw Exception('Failed to save to gallery');
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save screenshot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _hideButtons = false);
    }
  }

  Future<void> _shareScreenshot(Uint8List pngBytes) async {
    try {
      // Create a temporary file for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/meal_screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(pngBytes);
      
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Check out this meal!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share screenshot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final localizations = AppLocalizations.of(context)!;
    final macros = [
      {'label': localizations.calories, 'value': meal['calories']?.toString() ?? '-', 'color': Colors.green[700] ?? Colors.green, 'icon': Icons.local_fire_department},
      {'label': localizations.protein, 'value': '${meal['protein'] ?? '-'}g', 'color': Colors.blue[700] ?? Colors.blue, 'icon': Icons.fitness_center},
      {'label': localizations.carbs, 'value': '${meal['carbs'] ?? '-'}g', 'color': Colors.orange[700] ?? Colors.orange, 'icon': Icons.grain},
      {'label': localizations.fat, 'value': '${meal['fat'] ?? '-'}g', 'color': Colors.red[400] ?? Colors.red, 'icon': Icons.water_drop},
    ];
    final recipe = (meal['recipe'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final ingredients = (meal['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          meal['meal_name'] ?? 'Generated Meal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black87),
            onPressed: () => _takeScreenshot(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _screenshotKey,
                child: Column(
                  children: [
                    // Scroll indicator at the top
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scroll to see more',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hero section with meal name and image placeholder
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, const Color(0xFFF8F9FA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Meal image placeholder with icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Meal name
                          Text(
                            meal['meal_name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Preparation time if available
                          if (meal['time'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    meal['time'],
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Nutrition facts card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics, color: Colors.green[700], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Nutrition Facts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: macros.map((m) => Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (m['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      m['icon'] as IconData,
                                      color: m['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    m['value'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: m['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['label'] as String,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Ingredients section
                    if (ingredients.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shopping_basket, color: Colors.green[700], size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.ingredients,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ingredients.map((ingredient) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
                                ),
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Instructions section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_list_numbered, color: Colors.green[700], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                localizations.localeName.startsWith('ar')
                                    ? 'طريقة التحضير'
                                    : localizations.localeName.startsWith('es')
                                        ? 'Cómo preparar'
                                        : 'How to Make',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...recipe.asMap().entries.map((entry) {
                            int index = entry.key;
                            String step = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Action buttons
          if (!_hideButtons)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red[200]!, width: 1),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              localizations.discard,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              localizations.logMeal,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 