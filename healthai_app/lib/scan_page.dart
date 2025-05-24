import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'scan_result_page.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'scanner_overlay.dart';
import 'scan_result_fridge_page.dart';
import 'scan_paywall_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();
  Rect? _frameRect;
  double _frameBorderRadius = 32;
  bool _isFridgeMode = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<bool> _shouldShowPaywall() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastScanDate = prefs.getString('lastScanDate');
    final scansToday = prefs.getInt('scansToday') ?? 0;
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastScanDate != todayStr) {
      await prefs.setString('lastScanDate', todayStr);
      await prefs.setInt('scansToday', 0);
      return false; // first scan of the day
    }
    return scansToday >= 1;
  }

  Future<void> _incrementScanCount() async {
    final prefs = await SharedPreferences.getInstance();
    final scansToday = prefs.getInt('scansToday') ?? 0;
    await prefs.setInt('scansToday', scansToday + 1);
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized) return;
    final file = await _controller.takePicture();
    final imgBytes = await File(file.path).readAsBytes();
    final original = img.decodeImage(imgBytes);
    if (original == null) return;

    // Map frameRect (in logical pixels) to image coordinates
    final previewSize = _controller.value.previewSize!;
    final screen = MediaQuery.of(context).size;
    final scaleX = original.width / screen.width;
    final scaleY = original.height / screen.height;
    double frameWidth, frameHeight;
    if (_isFridgeMode) {
      frameWidth = screen.width * 0.92;
      frameHeight = screen.height * 0.6;
    } else {
      frameWidth = screen.width * 0.7;
      frameHeight = frameWidth;
    }
    final frameLeft = (screen.width - frameWidth) / 2;
    final frameTop = (screen.height - frameHeight) / 2;
    final cropX = (frameLeft * scaleX).round();
    final cropY = (frameTop * scaleY).round();
    final cropW = (frameWidth * scaleX).round();
    final cropH = (frameHeight * scaleY).round();
    final cropped = img.copyCrop(
      original,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
    final tempPath = file.path;
    final croppedFile = await File(tempPath).writeAsBytes(img.encodeJpg(cropped));

    final bool showPaywall = await _shouldShowPaywall();
    if (showPaywall) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanPaywallPage(
            onUpgrade: () {
              Navigator.of(context).pop();
            },
            onWatchAd: (paywallContext) async {
              await _incrementScanCount();
              if (_isFridgeMode) {
                Navigator.of(paywallContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ScanResultFridgePage(imagePath: croppedFile.path),
                  ),
                );
              } else {
                Navigator.of(paywallContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ScanResultPage(imagePath: croppedFile.path),
                  ),
                );
              }
            },
            onDiscard: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
      return;
    }

    await _incrementScanCount();
    if (_isFridgeMode) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultFridgePage(imagePath: croppedFile.path),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultPage(imagePath: croppedFile.path),
        ),
      );
    }
  }

  void _toggleFlash() async {
    _isFlashOn = !_isFlashOn;
    await _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _uploadFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      if (_isFridgeMode) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScanResultFridgePage(imagePath: picked.path),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScanResultPage(imagePath: picked.path),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? LayoutBuilder(
              builder: (context, constraints) {
                double frameWidth, frameHeight;
                if (_isFridgeMode) {
                  frameWidth = constraints.maxWidth * 0.92;
                  frameHeight = constraints.maxHeight * 0.60;
                } else {
                  frameWidth = constraints.maxWidth * 0.7;
                  frameHeight = frameWidth;
                }
                final double frameLeft = (constraints.maxWidth - frameWidth) / 2;
                final double frameTop = (constraints.maxHeight - frameHeight) / 2;
                final frameRect = Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight);
                return Stack(
                  children: [
                    Positioned.fill(child: CameraPreview(_controller)),
                    Positioned.fill(
                      child: ScannerOverlay(
                        borderRadius: _frameBorderRadius,
                        frameRect: frameRect,
                        borderColor: Colors.greenAccent,
                        overlayOpacity: 0.7,
                      ),
                    ),
                    // X button at top left
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SafeArea(
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white, size: 32),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    // Meal/Fridge toggle buttons
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildModeButton('Meal', !_isFridgeMode, () {
                              setState(() { _isFridgeMode = false; });
                            }),
                            const SizedBox(width: 12),
                            _buildModeButton('Fridge', _isFridgeMode, () {
                              setState(() { _isFridgeMode = true; });
                            }),
                          ],
                        ),
                      ),
                    ),
                    // Instruction overlay just above the frame
                    Positioned(
                      top: frameRect.top - 64,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Text(
                            "Place the food inside of the frame",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    _buildBottomButtons(),
                  ],
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 32),
            onPressed: _toggleFlash,
          ),
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.black, size: 36),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
            onPressed: _uploadFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.greenAccent : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 