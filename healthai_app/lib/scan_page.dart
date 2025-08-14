import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

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


  @override
  void dispose() {
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
                                _buildModeButton(AppLocalizations.of(context)!.scan, !_isFridgeMode, () {
                                  setState(() { _isFridgeMode = false; });
                                }),
                                const SizedBox(width: 12),
                                _buildModeButton(AppLocalizations.of(context)!.fridge, _isFridgeMode, () {
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
                              child: Text(
                                AppLocalizations.of(context)!.placeFoodInFrame,
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