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

		try {
			// Validate image data
			if (image.planes.isEmpty) return null;
			if (image.width <= 0 || image.height <= 0) return null;
			
			final plane = image.planes.first;
			if (plane.bytes.isEmpty) return null;
			if (plane.bytesPerRow <= 0) return null;
			
			final Uint8List bytes = plane.bytes;
			final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
			
			// Try different image formats for iOS compatibility
			final formats = [
				InputImageFormat.nv21,
				InputImageFormat.bgra8888,
				InputImageFormat.yuv420,
			];
			
			for (final format in formats) {
				try {
					for (final r in <InputImageRotation>{rotation, InputImageRotation.rotation90deg, InputImageRotation.rotation180deg, InputImageRotation.rotation270deg}) {
						final inputImageData = InputImageMetadata(
							size: imageSize,
							rotation: r,
							format: format,
							bytesPerRow: plane.bytesPerRow,
						);
						
						// Additional validation before creating InputImage
						if (bytes.length < (imageSize.width * imageSize.height * 1.5).toInt()) {
							continue; // Skip if buffer is too small
						}
						
						final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
						final barcodes = await _scanner.processImage(inputImage);
						
						for (final b in barcodes) {
							final raw = b.rawValue?.trim();
							if (raw != null && raw.isNotEmpty) {
								return raw;
							}
						}
					}
				} catch (e) {
					// Continue to next format if this one fails
					continue;
				}
			}
		} catch (e) {
			// Log error for debugging but don't crash
			print('BarcodeScannerService: Error processing image: $e');
		}
		return null;
	}

	/// Returns lightweight guidance data for UI (presence + relative size), without decoding result handling.
	Future<BarcodeGuidance?> processCameraImageForGuidance(CameraImage image, {required InputImageRotation rotation}) async {
		if (_isClosed) return null;
		
		try {
			// Validate image data
			if (image.planes.isEmpty) return const BarcodeGuidance(hasBarcode: false);
			if (image.width <= 0 || image.height <= 0) return const BarcodeGuidance(hasBarcode: false);
			
			final plane = image.planes.first;
			if (plane.bytes.isEmpty) return const BarcodeGuidance(hasBarcode: false);
			if (plane.bytesPerRow <= 0) return const BarcodeGuidance(hasBarcode: false);
			
			final Uint8List bytes = plane.bytes;
			final ui.Size imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
			
			// Try different image formats for iOS compatibility
			final formats = [
				InputImageFormat.nv21,
				InputImageFormat.bgra8888,
				InputImageFormat.yuv420,
			];
			
			for (final format in formats) {
				try {
					final inputImageData = InputImageMetadata(
						size: imageSize,
						rotation: rotation,
						format: format,
						bytesPerRow: plane.bytesPerRow,
					);
					
					// Additional validation before creating InputImage
					if (bytes.length < (imageSize.width * imageSize.height * 1.5).toInt()) {
						continue; // Skip if buffer is too small
					}
					
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
				} catch (e) {
					// Continue to next format if this one fails
					continue;
				}
			}
		} catch (e) {
			// Log error for debugging but don't crash
			print('BarcodeScannerService: Error processing image for guidance: $e');
		}
		
		return const BarcodeGuidance(hasBarcode: false);
	}

	Future<String?> processFilePath(String imagePath) async {
		if (_isClosed) return null;
		
		try {
			// Validate file path
			if (imagePath.isEmpty) return null;
			
			final inputImage = InputImage.fromFilePath(imagePath);
			final barcodes = await _scanner.processImage(inputImage);
			
			for (final b in barcodes) {
				final raw = b.rawValue?.trim();
				if (raw != null && raw.isNotEmpty) {
					return raw;
				}
			}
		} catch (e) {
			// Log error for debugging but don't crash
			print('BarcodeScannerService: Error processing file path $imagePath: $e');
		}
		
		return null;
	}

	Future<void> dispose() async {
		_isClosed = true;
		await _scanner.close();
	}
}

// No custom Size class; using ui.Size

