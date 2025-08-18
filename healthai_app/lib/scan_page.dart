// ignore_for_file: use_build_context_synchronously
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_result_page.dart';
import 'scanner_overlay.dart';
import 'scan_result_fridge_page.dart';
import 'scan_paywall_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/consent_service.dart';
import 'services/subscription_service.dart';
import 'config/ad_config.dart';
import 'services/connectivity_service.dart';
import 'log_meal_page.dart';
import 'services/barcode_scanner_service.dart';
import 'services/product_lookup_service.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'scan_result_product_page.dart';

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
  // Frame rect kept for future use if we reintroduce cropping
  // Removed persistent frameRect; computing per-frame in build
  double _frameBorderRadius = 32;
  bool _isFridgeMode = false; // legacy flag kept for compatibility
  bool _isBarcodeMode = false;
  BarcodeScannerService? _barcodeService;
  bool _isDecoding = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  // Guidance UI state for barcode mode
  Color _frameBorderColor = Colors.redAccent;
  String _bottomGuidanceText = 'Not in frame, bring closer';
  bool _isGuidanceStreaming = false;
  bool _isGuidanceDecoding = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _prepareAds();
  }
  Future<void> _prepareAds() async {
    // Skip consent - it's already done at app startup in main.dart
    // Just load the ad using existing consent status
    if (!mounted) return;
    
    debugPrint('=== LOADING REWARDED AD (using existing consent) ===');
    _loadRewardedAd(() {
      debugPrint('Rewarded ad loaded successfully');
    });
    
    // Also preload ad when paywall might be shown
    _preloadAdForPaywall();
  }

  Future<void> _preloadAdForPaywall() async {
    // Preload ad when user might need it (after first scan)
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastScanDate = prefs.getString('lastScanDate');
    final scansToday = prefs.getInt('scansToday') ?? 0;
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    // If user has already scanned today, preload ad for next scan
    if (lastScanDate == todayStr && scansToday >= 1) {
      debugPrint('Preloading ad for paywall (user has scanned today)');
      _loadRewardedAd(() {
        debugPrint('Paywall ad preloaded successfully');
      });
    }
  }

  void _onBarcodeModeChanged(bool enabled) {
    setState(() { _isBarcodeMode = enabled; });
    // Disable live guidance stream and color/text cues; manual snapshot only
    _stopBarcodeStream();
  }

  void _stopBarcodeStream() {
    _barcodeService?.dispose();
    _barcodeService = null;
    _isDecoding = false;
    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
  }

  Future<void> _startBarcodeStream() async {
    if (!_isCameraInitialized || !_controller.value.isInitialized) return;
    _barcodeService ??= BarcodeScannerService();
    if (_controller.value.isStreamingImages) return;
    await _controller.startImageStream((image) async {
      if (_isDecoding) return;
      _isDecoding = true;
      try {
        const rotation = InputImageRotation.rotation0deg;
        final code = await _barcodeService!.processCameraImage(image, rotation: rotation);
        if (code != null && mounted) {
          await _onBarcodeDetected(code);
        }
      } finally {
        _isDecoding = false;
      }
    });
  }

  void _resetGuidance() {
    _frameBorderColor = Colors.redAccent;
    _bottomGuidanceText = 'Not in frame, bring closer';
  }

  Future<void> _startGuidanceStream() async {
    if (!_isCameraInitialized || !_controller.value.isInitialized || _isGuidanceStreaming) return;
    _barcodeService ??= BarcodeScannerService();
    _isGuidanceStreaming = true;
    if (_controller.value.isStreamingImages) return;
    await _controller.startImageStream((image) async {
      if (_isGuidanceDecoding || !_isBarcodeMode) return;
      _isGuidanceDecoding = true;
      try {
        const rotation = InputImageRotation.rotation0deg;
        final guidance = await _barcodeService!.processCameraImageForGuidance(image, rotation: rotation);
        if (!mounted) return;
        if (!_isBarcodeMode) return;
        if (guidance == null || guidance.hasBarcode == false) {
          setState(() {
            _frameBorderColor = Colors.redAccent;
            _bottomGuidanceText = 'Not in frame, bring closer';
          });
        } else {
          final fraction = guidance.widthFraction ?? 0.0;
          if (fraction < 0.35) {
            setState(() {
              _frameBorderColor = Colors.orangeAccent;
              _bottomGuidanceText = 'Bring closer';
            });
          } else {
            setState(() {
              _frameBorderColor = Colors.greenAccent;
              _bottomGuidanceText = 'Snap photo';
            });
          }
        }
      } catch (_) {
        // ignore guidance errors
      } finally {
        _isGuidanceDecoding = false;
      }
    });
  }

  Future<void> _onBarcodeDetected(String code) async {
    _stopBarcodeStream();
    final lookup = ProductLookupService(userAgent: 'Yumie/1.0 (contact@yumie.app)');
    final res = await lookup.fetchByBarcode(code);
    if (!mounted) return;
    if (!res.found) { return; }
    final p = res.product!;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanResultProductPage(product: p)),
    );
  }


  @override
  void dispose() {
    _stopBarcodeStream();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: false);
    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
    // Guidance stream removed
  }

  Future<bool> _shouldShowPaywall() async {
    // Check if user is premium first
    final subscriptionService = SubscriptionService();
    final isPremium = await subscriptionService.isPremiumUser();
    if (isPremium) {
      return false; // Premium users don't see paywall
    }
    
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
    
    // Preload ad for next scan if user might need it
    if (scansToday >= 0) { // After first scan, preload for next one
      debugPrint('Preloading ad for next scan...');
      _loadRewardedAd(() {
        debugPrint('Ad preloaded for next scan');
      });
    }
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized) return;
    // Stop guidance stream before capturing to avoid conflicts
    if (_isBarcodeMode && _controller.value.isStreamingImages) {
      try { await _controller.stopImageStream(); } catch (_) {}
      _isGuidanceStreaming = false;
    }
    final file = await _controller.takePicture();
    // Removed cropping to eliminate image package; use original file directly

    // In barcode mode, decode from snapshot and navigate directly (no paywall)
    if (_isBarcodeMode) {
      _barcodeService ??= BarcodeScannerService();
      final code = await _barcodeService!.processFilePath(file.path);
      if (!mounted) return;
      if (code == null) { _startGuidanceStream(); return; }
      final lookup = ProductLookupService(userAgent: 'Yumie/1.0 (contact@yumie.app)');
      final res = await lookup.fetchByBarcode(code);
      if (!mounted) return;
      if (!res.found) { _startGuidanceStream(); return; }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ScanResultProductPage(product: res.product!)),
      );
      return;
    }

    final bool showPaywall = await _shouldShowPaywall();
    if (showPaywall) {
      // Ensure ad is loaded before showing paywall
      if (!_isRewardedAdLoaded || _rewardedAd == null) {
        debugPrint('Preloading ad before showing paywall...');
        await Future.delayed(Duration(milliseconds: 500)); // Give ad a moment to load
      }
      
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanPaywallPage(
            onUpgrade: () {
              Navigator.of(context).pop();
            },
            onWatchAd: (paywallContext) async {
              await _showRewardedAd(paywallContext, () async {
                await _incrementScanCount();
                if (_isFridgeMode) {
                  Navigator.of(paywallContext).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ScanResultFridgePage(imagePath: file.path),
                    ),
                  );
                } else {
                  Navigator.of(paywallContext).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ScanResultPage(imagePath: file.path),
                    ),
                  );
                }
              });
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
          builder: (_) => ScanResultFridgePage(imagePath: file.path),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultPage(imagePath: file.path),
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
    if (picked == null || !mounted) return;
    if (_isBarcodeMode) {
      _barcodeService ??= BarcodeScannerService();
      final code = await _barcodeService!.processFilePath(picked.path);
      if (!mounted) return;
      if (code == null) { return; }
      await _onBarcodeDetected(code);
      return;
    }
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

  void _loadRewardedAd(VoidCallback onAdLoaded) {
    // Don't load if already loading or loaded
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      debugPrint('Ad already loaded, skipping load request');
      onAdLoaded();
      return;
    }
    
    debugPrint('Loading rewarded ad with unit ID: ${AdConfig.rewardedAdUnitId}');
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: ConsentService.instance.buildAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad loaded successfully!');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          debugPrint('Check logcat for test device ID message starting with:');
          debugPrint('"Use RequestConfiguration.Builder().setTestDeviceIds"');
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          
          // Retry loading after a delay
          Future.delayed(Duration(seconds: 5), () {
            if (mounted && !_isRewardedAdLoaded) {
              debugPrint('Retrying ad load after failure...');
              _loadRewardedAd(() {});
            }
          });
        },
      ),
    );
  }

  Future<void> _showRewardedAd(BuildContext context, VoidCallback onRewardEarned) async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Scan ad dismissed');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          _loadRewardedAd(() {}); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Scan ad failed to show: $error');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
          );
          _loadRewardedAd(() {});
        },
      );
      
      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            debugPrint('User earned reward from scan ad');
            onRewardEarned();
          },
        );
      } catch (e) {
        debugPrint('Error showing scan ad: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
        );
        onRewardEarned(); // Continue anyway
      }
    } else {
      debugPrint('Scan ad not loaded, attempting to load and show...');
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Loading ad...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Try to load ad quickly and show it
      _loadRewardedAd(() {
        if (_isRewardedAdLoaded && _rewardedAd != null) {
          debugPrint('Ad loaded quickly, showing now...');
          _showRewardedAd(context, onRewardEarned);
        } else {
          debugPrint('Ad still not loaded after quick load attempt');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.adNotLoadedYet)),
          );
          onRewardEarned(); // Continue anyway
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          body: _isCameraInitialized
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    double frameWidth, frameHeight;
                    if (_isBarcodeMode) {
                      frameWidth = constraints.maxWidth * 0.90;
                      // Make barcode box taller vertically
                      frameHeight = frameWidth * 0.45;
                    } else if (_isFridgeMode) {
                      frameWidth = constraints.maxWidth * 0.92;
                      // Make the fridge box taller so it extends further downward
                      frameHeight = constraints.maxHeight * 0.58;
                    } else {
                      frameWidth = constraints.maxWidth * 0.7;
                      frameHeight = frameWidth;
                    }
                    final double frameLeft = (constraints.maxWidth - frameWidth) / 2;
                    double frameTop = (constraints.maxHeight - frameHeight) / 2;
                    // Compute adaptive position for mode toggles above bottom controls
                    const double shutterSize = 72;
                    const double bottomButtonsBottom = 40; // matches _buildBottomButtons
                    const double gapAboveShutter = 24;
                    final double safeBottom = MediaQuery.of(context).padding.bottom;
                    final double togglesBottom = bottomButtonsBottom + shutterSize + gapAboveShutter + safeBottom;
                    // Keep the frame well above the toggles row
                    const double togglesHeight = 44;
                    final double maxFrameBottom = constraints.maxHeight - togglesBottom - togglesHeight - 12;
                    final double maxFrameTop = maxFrameBottom - frameHeight;
                    final double overlap = (frameTop + frameHeight) - maxFrameBottom;
                    if (overlap > 0) {
                      frameTop = (frameTop - overlap).clamp(0.0, frameTop);
                    }
                    // Nudge fridge frame slightly downward (more space above)
                    if (_isFridgeMode) {
                      final double downwardBias = constraints.maxHeight * 0.06;
                      final double desiredTop = frameTop + downwardBias;
                      frameTop = desiredTop.clamp(0.0, maxFrameTop);
                    }
                    final frameRect = Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight);
                    return Stack(
                      children: [
                        Positioned.fill(child: CameraPreview(_controller)),
                        Positioned.fill(
                          child: ScannerOverlay(
                            borderRadius: _frameBorderRadius,
                            frameRect: frameRect,
                            // Use a single consistent color; remove red/orange/green cues
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
                        // Scan/Fridge/Barcode toggle buttons
                        Positioned(
                          bottom: togglesBottom,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildModeButton(AppLocalizations.of(context)!.scan, (!_isFridgeMode && !_isBarcodeMode), () {
                                  setState(() { _isFridgeMode = false; });
                                  _onBarcodeModeChanged(false);
                                }),
                                const SizedBox(width: 12),
                                _buildModeButton(AppLocalizations.of(context)!.fridge, _isFridgeMode, () {
                                  setState(() { _isFridgeMode = true; });
                                  _onBarcodeModeChanged(false);
                                }),
                                const SizedBox(width: 12),
                                _buildModeButton(AppLocalizations.of(context)!.barcode, _isBarcodeMode, () {
                                  setState(() { _isFridgeMode = false; });
                                  _onBarcodeModeChanged(true);
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
                              child: Text(
                                _isBarcodeMode
                                  ? AppLocalizations.of(context)!.placeBarcodeInFrame
                                  : (_isFridgeMode
                                      ? AppLocalizations.of(context)!.placeFridgeInFrame
                                      : AppLocalizations.of(context)!.placeFoodInFrame),
                                style: const TextStyle(
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
        ),
        ValueListenableBuilder<bool>(
          valueListenable: ConnectivityService.instance.online,
          builder: (context, isOnline, _) {
            if (isOnline) return SizedBox.shrink();
            return Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('No internet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text('Please connect to use this feature. You can still log meals offline and they will sync when you are back online.',
                            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                                icon: Icon(Icons.home),
                                label: Text('Home'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogMealPage())),
                                icon: Icon(Icons.restaurant_menu),
                                label: Text('Log a meal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _toggleFlash,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _captureImage(),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 36,
              ),
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