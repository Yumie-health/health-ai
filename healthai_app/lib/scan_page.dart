import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'scan_result_page.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized || _frameRect == null) return;
    final file = await _controller.takePicture();
    final imgBytes = await File(file.path).readAsBytes();
    final original = img.decodeImage(imgBytes);
    if (original == null) return;

    // Map frameRect (in logical pixels) to image coordinates
    final previewSize = _controller.value.previewSize!;
    final screen = MediaQuery.of(context).size;
    final scaleX = original.width / screen.width;
    final scaleY = original.height / screen.height;
    final cropX = (_frameRect!.left * scaleX).round();
    final cropY = (_frameRect!.top * scaleY).round();
    final cropW = (_frameRect!.width * scaleX).round();
    final cropH = (_frameRect!.height * scaleY).round();
    final safeCropX = max(0, min(cropX, original.width - 1));
    final safeCropY = max(0, min(cropY, original.height - 1));
    final safeCropW = min(cropW, original.width - safeCropX);
    final safeCropH = min(cropH, original.height - safeCropY);
    final cropped = img.copyCrop(
      original,
      x: safeCropX,
      y: safeCropY,
      width: safeCropW,
      height: safeCropH,
    );
    final dir = await getTemporaryDirectory();
    final croppedPath = '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(croppedPath).writeAsBytes(img.encodeJpg(cropped, quality: 95));
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultPage(imagePath: croppedPath),
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultPage(imagePath: picked.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? LayoutBuilder(
              builder: (context, constraints) {
                final double frameSize = constraints.maxWidth * 0.7;
                final double frameLeft = (constraints.maxWidth - frameSize) / 2;
                final double frameTop = (constraints.maxHeight - frameSize) / 2;
                _frameRect = Rect.fromLTWH(frameLeft, frameTop, frameSize, frameSize);
                return Stack(
                  children: [
                    Positioned.fill(child: CameraPreview(_controller)),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScanOverlayPainter(
                          frameRect: _frameRect!,
                          borderRadius: _frameBorderRadius,
                        ),
                      ),
                    ),
                    _buildTopText(),
                    _buildBottomButtons(),
                  ],
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTopText() {
    return Positioned(
      top: 60,
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
}

class _ScanOverlayPainter extends CustomPainter {
  final Rect frameRect;
  final double borderRadius;

  _ScanOverlayPainter({required this.frameRect, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw full black overlay
    final overlayPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(screenRect, overlayPaint);

    // Cut out the frame area (make it transparent)
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final frameRRect = RRect.fromRectAndRadius(frameRect, Radius.circular(borderRadius));
    canvas.saveLayer(screenRect, Paint());
    canvas.drawRRect(frameRRect, clearPaint);
    canvas.restore();

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;
    canvas.drawRRect(frameRRect, borderPaint);

    // Draw green glow
    final glowPaint = Paint()
      ..color = const Color(0x884CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(frameRRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 