// ignore_for_file: use_build_context_synchronously
import 'dart:io' show Platform;
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
import 'package:app_settings/app_settings.dart';

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
  bool _showBarcodeError = false; // shows red error under the frame when not recognized
  String? _cameraError; // To track camera initialization errors
  bool _isRetryingCamera = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _prepareAds();
  }
  Future<void> _prepareAds() async {
    // Ads are already preloaded at app startup for FAST SCAN experience
    // Just check if we need to load additional ads
    if (!mounted) return;
    
    // Load ad in background for next scan (non-blocking)
    _loadRewardedAd(() {});
    
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
      _loadRewardedAd(() {});
    }
  }

  void _onBarcodeModeChanged(bool enabled) {
    setState(() { _isBarcodeMode = enabled; });
    // Disable live scanning on iOS to prevent crashes
    if (Platform.isIOS) {
      _stopBarcodeStream();
      return;
    }
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
    // Disable live barcode scanning on iOS to prevent crashes
    if (Platform.isIOS) return;
    
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
        } else {
          if (mounted) {
            setState(() { _showBarcodeError = true; });
            // Hide error after a short delay to avoid persistent red text
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() { _showBarcodeError = false; });
            });
          }
        }
      } finally {
        _isDecoding = false;
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
    if (_isCameraInitialized) {
      _controller.dispose();
    }
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _cameraError = null;
        _isRetryingCamera = true;
      });
      
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        print('No cameras available');
        if (mounted) {
          setState(() {
            _cameraError = 'No cameras found on this device';
            _isRetryingCamera = false;
          });
        }
        return;
      }
      
      _controller = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: false);
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
          _isRetryingCamera = false;
        });
      }
    } on CameraException catch (e) {
      print('Camera error: ${e.code} - ${e.description}');
      if (mounted) {
        String errorMessage = 'Camera initialization failed';
        
        // Handle specific camera errors
        switch (e.code) {
          case 'CameraAccessDenied':
          case 'CameraAccessDeniedWithoutPrompt':
          case 'CameraAccessRestricted':
            errorMessage = 'Camera access denied. Please enable camera permissions in Settings.';
            break;
          case 'AudioAccessDenied':
          case 'AudioAccessDeniedWithoutPrompt':
          case 'AudioAccessRestricted':
            // We don't need audio, but iOS might still require it
            errorMessage = 'Microphone access denied. Please enable permissions in Settings.';
            break;
          default:
            errorMessage = 'Camera error: ${e.description ?? e.code}';
        }
        
        setState(() {
          _cameraError = errorMessage;
          _isRetryingCamera = false;
          _isCameraInitialized = false;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _cameraError = 'Failed to initialize camera. Please try again.';
          _isRetryingCamera = false;
          _isCameraInitialized = false;
        });
      }
    }
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
      _loadRewardedAd(() {});
    }
  }

  Future<void> _captureImage() async {
    if (!_isCameraInitialized || !_controller.value.isInitialized) return;
    final file = await _controller.takePicture();

    // In barcode mode, decode from snapshot and navigate directly (no paywall)
    if (_isBarcodeMode) {
      _barcodeService ??= BarcodeScannerService();
      final code = await _barcodeService!.processFilePath(file.path);
      if (!mounted) return;
      if (code == null) {
        setState(() { _showBarcodeError = true; });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() { _showBarcodeError = false; });
        });
        return;
      }
      final lookup = ProductLookupService(userAgent: 'Yumie/1.0 (contact@yumie.app)');
      final res = await lookup.fetchByBarcode(code);
      if (!mounted) return;
      if (!res.found) {
        setState(() { _showBarcodeError = true; });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() { _showBarcodeError = false; });
        });
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ScanResultProductPage(product: res.product!)),
      );
      return;
    }

    final bool showPaywall = await _shouldShowPaywall();
    if (showPaywall) {
      // Ensure ad is loaded before showing paywall
      if (!_isRewardedAdLoaded || _rewardedAd == null) {
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
    if (!_isCameraInitialized || !_controller.value.isInitialized) return;
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
    _loadRewardedAdWithFallback(AdConfig.rewardedAdUnitId, onAdLoaded);
  }

  void _loadRewardedAdWithFallback(String adUnitId, VoidCallback onAdLoaded) {
    // Don't load if already loading or loaded
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      onAdLoaded();
      return;
    }
    
    print('Loading rewarded ad with unit ID: $adUnitId');
    print('Consent status - can request ads: ${ConsentService.instance.userConsentedPersonalizedAds}');
    
    RewardedAd.load(
      adUnitId: adUnitId,
      request: ConsentService.instance.buildAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: ${error.message}');
          print('Error code: ${error.code}');
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          
          // If production ad failed, try test ad as fallback
          if (adUnitId == AdConfig.rewardedAdUnitId) {
            print('Production ad failed, trying test ad as fallback');
            Future.delayed(Duration(seconds: 2), () {
              if (mounted && !_isRewardedAdLoaded) {
                _loadRewardedAdWithFallback(AdConfig.testRewardedAdUnitId, onAdLoaded);
              }
            });
          } else {
            // Retry loading after a delay
            Future.delayed(Duration(seconds: 5), () {
              if (mounted && !_isRewardedAdLoaded) {
                print('Retrying ad load after failure');
                _loadRewardedAdWithFallback(AdConfig.rewardedAdUnitId, onAdLoaded);
              }
            });
          }
        },
      ),
    );
  }

  Future<void> _showRewardedAd(BuildContext context, VoidCallback onRewardEarned) async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          _loadRewardedAd(() {}); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
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
            onRewardEarned();
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
        );
        onRewardEarned(); // Continue anyway
      }
    } else {
      // Ad is not ready - show loading and wait for it to load
      print('Ad not ready, showing loading and waiting for ad to load');
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Loading ad...'),
            ],
          ),
          duration: Duration(seconds: 30), // Long duration while we wait
        ),
      );
      
      // Try to load ad and wait for it
      bool adLoaded = false;
      int attempts = 0;
      const maxAttempts = 3;
      
      while (!adLoaded && attempts < maxAttempts && mounted) {
        attempts++;
        print('Attempting to load ad, attempt $attempts');
        
        _loadRewardedAd(() {
          adLoaded = true;
          print('Ad loaded successfully on attempt $attempts');
        });
        
        // Wait a bit before next attempt
        if (!adLoaded && attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: 2));
        }
      }
      
      // Clear loading message
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      if (adLoaded && _isRewardedAdLoaded && _rewardedAd != null) {
        // Now show the ad
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _isRewardedAdLoaded = false;
            _rewardedAd = null;
            _loadRewardedAd(() {}); // Preload next ad
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
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
              onRewardEarned();
            },
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.adFailedToShow)),
          );
          onRewardEarned(); // Continue anyway
        }
      } else {
        // If we still can't load an ad after multiple attempts, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to load ad. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        // Don't call onRewardEarned() - user must wait for ad to work
      }
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
                    // Keep the frame just above the mode buttons/camera cluster
                    const double modeButtonsBottom = 120; // Y offset of the button row
                    const double cameraButtonBottom = 40; // Camera button bottom inset
                    const double totalBottomSpace = modeButtonsBottom + 40; // Extra padding so the frame sits above
                    final double maxFrameBottom = constraints.maxHeight - totalBottomSpace;
                    final double maxFrameTop = maxFrameBottom - frameHeight;
                    final double overlap = (frameTop + frameHeight) - maxFrameBottom;
                    if (overlap > 0) {
                      frameTop = (frameTop - overlap).clamp(0.0, frameTop);
                    }
                    // For fridge mode, bias the frame to sit closer to the buttons (relative placement)
                    if (_isFridgeMode) {
                      // Target the frame bottom to be a fixed margin above the buttons
                      final double desiredBottom = maxFrameBottom - 48; // 12px gap above buttons
                      final double desiredTop = (desiredBottom - frameHeight).clamp(0.0, maxFrameTop);
                      frameTop = desiredTop;
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
                        // Mode buttons positioned just above the camera button
                        Positioned(
                          bottom: 120, // Position above the camera button
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // Error message under the frame for barcode not recognized
                        if (_isBarcodeMode)
                          Positioned(
                            top: frameRect.bottom + 8,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _showBarcodeError ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Center(
                                child: Text(
                                  'Barcode not in frame!',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        _buildBottomButtons(),
                      ],
                    );
                  },
                )
              : Center(
                  child: _cameraError != null
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 64,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Camera Not Available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _cameraError!,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              if (_cameraError!.contains('permissions') || _cameraError!.contains('denied'))
                                Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => AppSettings.openAppSettings(),
                                      icon: Icon(Icons.settings),
                                      label: Text('Open Settings'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ElevatedButton.icon(
                                onPressed: _isRetryingCamera ? null : _initCamera,
                                icon: _isRetryingCamera
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.refresh),
                                label: Text(_isRetryingCamera ? 'Retrying...' : 'Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Go Back',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                ),
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
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: EdgeInsets.only(bottom: 20),
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
        ),
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