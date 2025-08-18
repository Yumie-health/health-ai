import 'dart:typed_data';
import 'dart:ui' as ui show Size, Rect;

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Simple guidance info for UI cues while scanning.
class BarcodeGuidance {
  final bool hasBarcode;
  /// Width of the largest detected barcode relative to the camera image width (0..1)
  final double? widthFraction;
  /// Raw bounding box, if available, for potential future use
  final ui.Rect? boundingBox;

  const BarcodeGuidance({required this.hasBarcode, this.widthFraction, this.boundingBox});
}

/// Lightweight helper around ML Kit barcode scanning for camera frames.
///
/// Usage:
/// - Create once per scan session
/// - Call [processCameraImage] on each camera frame until it returns a code
/// - Dispose using [dispose] when done
class BarcodeScannerService {
	final BarcodeScanner _scanner;
	bool _isClosed = false;

	BarcodeScannerService()
			: _scanner = BarcodeScanner(
				formats: const [
					BarcodeFormat.ean13,
					BarcodeFormat.ean8,
					BarcodeFormat.upca,
					BarcodeFormat.upce,
					BarcodeFormat.code128,
				],
			);

	Future<String?> processCameraImage(CameraImage image, {required InputImageRotation rotation}) async {
		if (_isClosed) return null;

		// Simpler: first plane with bytesPerRow; try multiple rotations for reliability
		final Uint8List bytes = image.planes.first.bytes;
		final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
		for (final r in <InputImageRotation>{rotation, InputImageRotation.rotation90deg, InputImageRotation.rotation180deg, InputImageRotation.rotation270deg}) {
			final inputImageData = InputImageMetadata(
				size: imageSize,
				rotation: r,
				format: InputImageFormat.nv21,
				bytesPerRow: image.planes.first.bytesPerRow,
			);
			final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
			final barcodes = await _scanner.processImage(inputImage);
			for (final b in barcodes) {
				final raw = b.rawValue?.trim();
				if (raw != null && raw.isNotEmpty) {
					return raw;
				}
			}
		}
		return null;
	}

	/// Returns lightweight guidance data for UI (presence + relative size), without decoding result handling.
	Future<BarcodeGuidance?> processCameraImageForGuidance(CameraImage image, {required InputImageRotation rotation}) async {
		if (_isClosed) return null;
		final Uint8List bytes = image.planes.first.bytes;
		final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
		final inputImageData = InputImageMetadata(
			size: imageSize,
			rotation: rotation,
			format: InputImageFormat.nv21,
			bytesPerRow: image.planes.first.bytesPerRow,
		);
		final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
		final barcodes = await _scanner.processImage(inputImage);
		if (barcodes.isEmpty) return const BarcodeGuidance(hasBarcode: false);
		// Choose the largest barcode by width as the primary target
		double maxWidth = 0;
		ui.Rect? maxBox;
		for (final b in barcodes) {
			final box = b.boundingBox;
			final w = box?.width ?? 0;
			if (w > maxWidth) {
				maxWidth = w;
				maxBox = box;
			}
		}
		final double widthFraction = imageSize.width == 0
			? 0.0
			: ((maxWidth / imageSize.width).clamp(0.0, 1.0) as double);
		return BarcodeGuidance(hasBarcode: true, widthFraction: widthFraction, boundingBox: maxBox);
	}

	Future<String?> processFilePath(String imagePath) async {
		if (_isClosed) return null;
		final inputImage = InputImage.fromFilePath(imagePath);
		final barcodes = await _scanner.processImage(inputImage);
		for (final b in barcodes) {
			final raw = b.rawValue?.trim();
			if (raw != null && raw.isNotEmpty) {
				return raw;
			}
		}
		return null;
	}

	Future<void> dispose() async {
		_isClosed = true;
		await _scanner.close();
	}
}

// No custom Size class; using ui.Size

