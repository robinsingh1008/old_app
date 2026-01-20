import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:old_book/Addfile/ad_manager.dart';
import 'package:old_book/Addfile/ad_helper.dart';
import 'package:old_book/utils/round_button.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  BannerAd? _topBanner;
  BannerAd? _bottomBanner;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;
  int _topBannerRetryCount = 0;
  int _bottomBannerRetryCount = 0;
  static const int _maxRetries = 3;
  double _topBannerHeight = 50.0;
  double _bottomBannerHeight = 50.0;
  bool _requestedAdaptive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load splash native ad (position 0)
    debugPrint("SplashScreen: Initializing native ad");
    _loadSplashAd();

    // Load banner ads immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint("SplashScreen: Loading banner ads");
        _loadTopBanner();
        _loadBottomBanner();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedAdaptive) {
      _requestedAdaptive = true;
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      // Load banner ads if not already loading
      if (!_isTopBannerLoaded && _topBanner == null) {
        _loadTopBanner();
      }
      if (!_isBottomBannerLoaded && _bottomBanner == null) {
        _loadBottomBanner();
      }
    }
  }

  void _loadSplashAd() {
    AdManager().createNativeAd(
      'splash',
      position: 0,
      onAdLoaded: () {
        debugPrint("SplashScreen: Native ad loaded successfully");
        if (mounted) setState(() {});
      },
    );

    // Retry loading ad if it fails after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !AdManager().isAdLoaded('splash', position: 0)) {
        debugPrint("SplashScreen: Retrying ad load");
        _loadSplashAd();
      }
    });
  }

  Future<void> _loadTopBanner() async {
    if (!mounted) return;

    debugPrint("SplashScreen: Loading top banner ad");
    _topBanner?.dispose();
    _topBanner = null;

    if (mounted) {
      setState(() {
        _isTopBannerLoaded = false;
      });
    }

    try {
      if (!mounted) return;
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();

      if (mounted) {
        setState(() {
          _topBannerHeight = bannerSize.height.toDouble();
        });
      }

      if (!mounted) return;
      final banner = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: bannerSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("SplashScreen: Top banner ad loaded successfully");
            if (mounted) {
              final bannerAd = ad as BannerAd;
              setState(() {
                _isTopBannerLoaded = true;
                _topBannerRetryCount = 0;
                _topBannerHeight = bannerAd.size.height.toDouble();
                _topBanner = bannerAd;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('SplashScreen top banner failed to load: $error');
            ad.dispose();
            _topBanner = null;
            if (mounted) {
              setState(() {
                _isTopBannerLoaded = false;
              });
            }
            if (mounted && _topBannerRetryCount < _maxRetries) {
              _topBannerRetryCount++;
              debugPrint(
                'SplashScreen: Retrying top banner load (attempt $_topBannerRetryCount)',
              );
              Future.delayed(Duration(seconds: 2 * _topBannerRetryCount), () {
                if (mounted) {
                  _loadTopBanner();
                }
              });
            }
          },
        ),
      );
      banner.load();
      _topBanner = banner;
    } catch (e) {
      debugPrint('Error loading splash top banner: $e');
      if (mounted && _topBannerRetryCount < _maxRetries) {
        _topBannerRetryCount++;
        debugPrint(
          'SplashScreen: Retrying top banner load after error (attempt $_topBannerRetryCount)',
        );
        Future.delayed(Duration(seconds: 2 * _topBannerRetryCount), () {
          if (mounted) {
            _loadTopBanner();
          }
        });
      }
    }
  }

  Future<void> _loadBottomBanner() async {
    if (!mounted) return;

    debugPrint("SplashScreen: Loading bottom banner ad");
    _bottomBanner?.dispose();
    _bottomBanner = null;

    if (mounted) {
      setState(() {
        _isBottomBannerLoaded = false;
      });
    }

    try {
      if (!mounted) return;
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();

      if (mounted) {
        setState(() {
          _bottomBannerHeight = bannerSize.height.toDouble();
        });
      }

      if (!mounted) return;
      final banner = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: bannerSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint("SplashScreen: Bottom banner ad loaded successfully");
            if (mounted) {
              final bannerAd = ad as BannerAd;
              setState(() {
                _isBottomBannerLoaded = true;
                _bottomBannerRetryCount = 0;
                _bottomBannerHeight = bannerAd.size.height.toDouble();
                _bottomBanner = bannerAd;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('SplashScreen bottom banner failed to load: $error');
            ad.dispose();
            _bottomBanner = null;
            if (mounted) {
              setState(() {
                _isBottomBannerLoaded = false;
              });
            }
            if (mounted && _bottomBannerRetryCount < _maxRetries) {
              _bottomBannerRetryCount++;
              debugPrint(
                'SplashScreen: Retrying bottom banner load (attempt $_bottomBannerRetryCount)',
              );
              Future.delayed(
                Duration(seconds: 2 * _bottomBannerRetryCount),
                () {
                  if (mounted) {
                    _loadBottomBanner();
                  }
                },
              );
            }
          },
        ),
      );
      banner.load();
      _bottomBanner = banner;
    } catch (e) {
      debugPrint('Error loading splash bottom banner: $e');
      if (mounted && _bottomBannerRetryCount < _maxRetries) {
        _bottomBannerRetryCount++;
        debugPrint(
          'SplashScreen: Retrying bottom banner load after error (attempt $_bottomBannerRetryCount)',
        );
        Future.delayed(Duration(seconds: 2 * _bottomBannerRetryCount), () {
          if (mounted) {
            _loadBottomBanner();
          }
        });
      }
    }
  }

  Future<AdSize> _getAdaptiveOrFallbackSize() async {
    final int width = MediaQuery.of(context).size.width.truncate();
    final AdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (adaptiveSize != null) return adaptiveSize;

    if (width >= 728) {
      return AdSize.leaderboard;
    } else if (width >= 468) {
      return AdSize.fullBanner;
    } else {
      return AdSize.banner;
    }
  }

  Widget _buildBannerShimmer(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    AdManager().disposeAllAdsForScreen('splash');
    _topBanner?.dispose();
    _bottomBanner?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("SplashScreen: App resumed, reloading banner ads");
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      if (!_isTopBannerLoaded) {
        _loadTopBanner();
      }
      if (!_isBottomBannerLoaded) {
        _loadBottomBanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "6 Old Math Books",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top banner or shimmer placeholder - always show something
          SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                if (_isTopBannerLoaded && _topBanner != null) {
                  debugPrint("SplashScreen: Showing top banner ad");
                  return SizedBox(
                    width: double.infinity,
                    height: _topBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _topBanner!),
                  );
                } else {
                  debugPrint("SplashScreen: Showing top banner shimmer");
                  return _buildBannerShimmer(_topBannerHeight);
                }
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Image(image: AssetImage("assets/images/banner.png")),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Mathematics for all students and teaching of mathematics",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Splash Native Ad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: AspectRatio(
                      aspectRatio: 320 / 300,
                      child: Column(
                        children: [
                          // Debug info
                          if (kDebugMode)
                            Expanded(
                              child: AdManager().createSmartAdWidget(
                                'splash',
                                position: 0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: RoundButton(
                      title: "Get Started",
                      buttonColor: Colors.blue,
                      onPressed: () {
                        Get.offAllNamed("/dashboard");
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bottom banner or shimmer placeholder - always show something
          SafeArea(
            top: false,
            child: Builder(
              builder: (context) {
                if (_isBottomBannerLoaded && _bottomBanner != null) {
                  debugPrint("SplashScreen: Showing bottom banner ad");
                  return SizedBox(
                    width: double.infinity,
                    height: _bottomBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _bottomBanner!),
                  );
                } else {
                  debugPrint("SplashScreen: Showing bottom banner shimmer");
                  return _buildBannerShimmer(_bottomBannerHeight);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
