// ignore_for_file: use_super_parameters, library_private_types_in_public_api
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:old_book/Addfile/ad_helper.dart';
import 'package:shimmer/shimmer.dart';

class OpenPdf extends StatefulWidget {
  const OpenPdf({Key? key}) : super(key: key);

  @override
  _OpenPdfState createState() => _OpenPdfState();
}

class _OpenPdfState extends State<OpenPdf> with WidgetsBindingObserver {
  String? pdfurl;
  String? title;

  BannerAd? _topBanner;
  BannerAd? _bottomBanner;
  bool _isTopBannerLoaded = false;
  bool _isBottomBannerLoaded = false;
  bool _requestedAdaptive = false;
  int _topBannerRetryCount = 0;
  int _bottomBannerRetryCount = 0;
  static const int _maxRetries = 3;
  double _topBannerHeight = 50.0; // Default banner height
  double _bottomBannerHeight = 50.0; // Default banner height

  //final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pdfurl = Get.arguments["pdf"];
    title = Get.arguments["chapter"];
    if (kDebugMode) {
      print(pdfurl);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedAdaptive) {
      _requestedAdaptive = true;
      // Reset retry counts
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _loadTopBanner();
      _loadBottomBanner();
    }
  }

  Future<void> _loadTopBanner() async {
    // Dispose existing banner if any
    _topBanner?.dispose();
    setState(() {
      _isTopBannerLoaded = false;
    });

    try {
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();
      // Update height for shimmer placeholder
      if (mounted) {
        setState(() {
          _topBannerHeight = bannerSize.height.toDouble();
        });
      }

      final banner = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: bannerSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              final bannerAd = ad as BannerAd;
              setState(() {
                _isTopBannerLoaded = true;
                _topBannerRetryCount = 0;
                _topBannerHeight = bannerAd.size.height.toDouble();
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('Top banner failed to load: $error');
            }
            ad.dispose();
            if (mounted && _topBannerRetryCount < _maxRetries) {
              _topBannerRetryCount++;
              // Retry after a delay
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
      if (kDebugMode) {
        print('Error loading top banner: $e');
      }
      if (mounted && _topBannerRetryCount < _maxRetries) {
        _topBannerRetryCount++;
        Future.delayed(Duration(seconds: 2 * _topBannerRetryCount), () {
          if (mounted) {
            _loadTopBanner();
          }
        });
      }
    }
  }

  Future<void> _loadBottomBanner() async {
    // Dispose existing banner if any
    _bottomBanner?.dispose();
    setState(() {
      _isBottomBannerLoaded = false;
    });

    try {
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();
      // Update height for shimmer placeholder
      if (mounted) {
        setState(() {
          _bottomBannerHeight = bannerSize.height.toDouble();
        });
      }

      final banner = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: bannerSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              final bannerAd = ad as BannerAd;
              setState(() {
                _isBottomBannerLoaded = true;
                _bottomBannerRetryCount = 0;
                _bottomBannerHeight = bannerAd.size.height.toDouble();
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('Bottom banner failed to load: $error');
            }
            ad.dispose();
            if (mounted && _bottomBannerRetryCount < _maxRetries) {
              _bottomBannerRetryCount++;
              // Retry after a delay
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
      if (kDebugMode) {
        print('Error loading bottom banner: $e');
      }
      if (mounted && _bottomBannerRetryCount < _maxRetries) {
        _bottomBannerRetryCount++;
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

    // Fallback sizes based on available width
    // Leaderboard (728x90) for very wide layouts; FullBanner (468x60) for tablets; Banner (320x50) for phones
    if (width >= 728) {
      return AdSize.leaderboard;
    } else if (width >= 468) {
      return AdSize.fullBanner;
    } else {
      return AdSize.banner;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reload ads when app comes back to foreground
      // Always try to reload to ensure ads are shown
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _loadTopBanner();
      _loadBottomBanner();
    }
  }

  // Build shimmer placeholder for banner ads
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
    _topBanner?.dispose();
    _bottomBanner?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toString(),
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            debugPrint("DetailPage back button pressed");

            Get.back(result: true);
          },
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Top banner or shimmer placeholder
          SafeArea(
            bottom: false,
            child: _isTopBannerLoaded && _topBanner != null
                ? SizedBox(
                    width: double.infinity,
                    height: _topBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _topBanner!),
                  )
                : _buildBannerShimmer(_topBannerHeight),
          ),
          Expanded(
            child: RepaintBoundary(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  children: [
                    PDF().cachedFromUrl(pdfurl.toString()),

                    // Overlay to prevent screenshots
                  ],
                ),
              ),
            ),
          ),
          // Bottom banner or shimmer placeholder
          SafeArea(
            top: false,
            child: _isBottomBannerLoaded && _bottomBanner != null
                ? SizedBox(
                    width: double.infinity,
                    height: _bottomBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _bottomBanner!),
                  )
                : _buildBannerShimmer(_bottomBannerHeight),
          ),
        ],
      ),
    );
  }
}
