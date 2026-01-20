// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:old_book/Addfile/ad_helper.dart';
import 'package:old_book/Addfile/ad_manager.dart';
import 'package:old_book/screen/detail_page.dart';
import 'package:old_book/utils/ad_frequency_manager.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  String? algebrapdf;
  RewardedAd? _rewardedAd;
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
  final List<Map<String, String>> books = [
    {
      "title": "बीजगणित",
      "image": "assets/images/beej.png",
      "routeName": "beejganit",
    },
    {
      "title": "त्रिकोणमिति",
      "image": "assets/images/trignometry.jpeg",
      "routeName": "trigonometry",
    },
    {
      "title": "कैलकुलस",
      "image": "assets/images/calculas.jpeg",
      "routeName": "calculus",
    },
    {
      "title": "ज्यामिति और निर्देशांक ज्यामिति",
      "image": "assets/images/geometry.jpeg",
      "routeName": "geometry",
    },
  ];

  final List<Map<String, String>> books2 = [
    {
      "title": "गति विज्ञान",
      "image": "assets/images/dynamics.jpeg",
      "routeName": "dynamics",
    },
    {
      "title": "स्थिति विज्ञान और सदिश विश्लेषण",
      "image": "assets/images/statics.jpeg",
      "routeName": "statics",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
    _loadBooks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedAdaptive) {
      _requestedAdaptive = true;
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _loadTopBanner();
      _loadBottomBanner();
    }
    // Check if we're returning from another screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndReloadAds();
    });
  }

  Future<void> _loadBooks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("algebra")
          .get();

      if (mounted) {
        setState(() {
          final booksdetail = snapshot.docs.map((doc) => doc.data()).toList();
          algebrapdf = booksdetail.first['link'];
          print(algebrapdf);
        });
      }
    } catch (e) {
      debugPrint("Error loading books: $e");
      if (mounted) {}
    }
  }

  void _checkAndReloadAds() {
    // Only reload ads if they're not already loaded and not currently loading
    if (!AdManager().isAdValid('dashboard', position: 0) &&
        !AdManager().isAdLoading('dashboard', position: 0)) {
      debugPrint("Dashboard reloading native ad");
      _loadAd();
    }
    if (_rewardedAd == null) {
      debugPrint("Dashboard reloading rewarded ad");
      _loadRewardedAd();
    }
    // Reload banner ads if not loaded
    if (!_isTopBannerLoaded) {
      _loadTopBanner();
    }
    if (!_isBottomBannerLoaded) {
      _loadBottomBanner();
    }
  }

  Future<void> _loadTopBanner() async {
    _topBanner?.dispose();
    setState(() {
      _isTopBannerLoaded = false;
    });

    try {
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();
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
              debugPrint('Dashboard top banner failed to load: $error');
            }
            ad.dispose();
            if (mounted && _topBannerRetryCount < _maxRetries) {
              _topBannerRetryCount++;
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
        debugPrint('Error loading dashboard top banner: $e');
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
    _bottomBanner?.dispose();
    setState(() {
      _isBottomBannerLoaded = false;
    });

    try {
      final AdSize bannerSize = await _getAdaptiveOrFallbackSize();
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
              debugPrint('Dashboard bottom banner failed to load: $error');
            }
            ad.dispose();
            if (mounted && _bottomBannerRetryCount < _maxRetries) {
              _bottomBannerRetryCount++;
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
        debugPrint('Error loading dashboard bottom banner: $e');
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
    _disposeAds();

    super.dispose();
  }

  void _disposeAds() {
    debugPrint("Dashboard disposing ads");
    AdManager().disposeAllAdsForScreen('dashboard');
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _topBanner?.dispose();
    _bottomBanner?.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("Dashboard app resumed, checking ads");
      AdManager().clearErrorsForScreen('dashboard');
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _checkAndReloadAds();
      _loadTopBanner();
      _loadBottomBanner();
    } else if (state == AppLifecycleState.paused) {
      debugPrint("Dashboard app paused, disposing rewarded ads only");
      _rewardedAd?.dispose();
      _rewardedAd = null;
    }
  }

  void _loadAd() {
    _loadAdWithRetry();
  }

  // Debug method to test ad loading (can be called from debug console)
  void debugRetryAds() {
    debugPrint("Debug: Force retrying all ads");
    AdManager().forceRetryAdsForScreen('dashboard');
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _loadRewardedAd();
  }

  void _loadAdWithRetry({int retryCount = 0}) {
    const maxRetries = 3;

    debugPrint("Dashboard loading ad (attempt ${retryCount + 1})");

    // First dispose any existing ad to prevent conflicts
    AdManager().disposeAd('dashboard', position: 0);

    // Small delay to ensure disposal is complete
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        AdManager().createNativeAd(
          'dashboard',
          position: 0,
          onAdLoaded: () {
            debugPrint("Dashboard ad loaded successfully");
            if (mounted) {
              setState(() {});
            }
          },
        );
      }
    });

    // If ad fails to load, retry after a delay
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted &&
          !AdManager().isAdValid('dashboard', position: 0) &&
          retryCount < maxRetries) {
        debugPrint("Retrying dashboard ad load (attempt ${retryCount + 1})");
        _loadAdWithRetry(retryCount: retryCount + 1);
      } else if (mounted && !AdManager().isAdValid('dashboard', position: 0)) {
        debugPrint("Dashboard ad failed to load after $maxRetries attempts");
        // Force refresh the ad widget to show placeholder
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void _loadRewardedAd() {
    // Don't reload if already loading or loaded
    if (_rewardedAd != null) {
      debugPrint("Dashboard rewarded ad already loaded, skipping reload");
      return;
    }

    debugPrint("Dashboard loading rewarded ad");
    _rewardedAd?.dispose();
    _rewardedAd = null;

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("Dashboard rewarded ad loaded successfully");
          if (!mounted) {
            ad.dispose();
            return;
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("Dashboard rewarded ad dismissed, reloading");
              ad.dispose();
              _rewardedAd = null;
              // Reload immediately after dismissal
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadRewardedAd();
                }
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                "Dashboard rewarded ad failed to show: $error, reloading",
              );
              ad.dispose();
              _rewardedAd = null;
              // Reload on failure
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _loadRewardedAd();
                }
              });
            },
          );

          if (mounted) {
            setState(() {
              _rewardedAd = ad;
            });
          }
        },
        onAdFailedToLoad: (err) {
          debugPrint("Dashboard rewarded ad failed to load: $err");
          _rewardedAd = null;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _rewardedAd == null) {
              debugPrint("Dashboard retrying rewarded ad load");
              _loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  void _showRewardedAdThenNavigate({
    required String routeName,
    required String title,
  }) async {
    // For dashboard navigation, use dashboard-specific frequency check
    // This prevents ads from showing on every book tap
    final shouldShowAd = await AdFrequencyManager.shouldShowAdForDashboard();

    if (shouldShowAd && _rewardedAd != null) {
      debugPrint(
        "Dashboard showing rewarded ad (dashboard frequency check passed)",
      );
      final ad = _rewardedAd!;
      _rewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("Dashboard ad dismissed, navigating and reloading");
          ad.dispose();
          // Reload rewarded ad for next time
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _loadRewardedAd();
            }
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailPage(routeName: routeName, title: title),
            ),
          );
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            "Dashboard ad failed to show: $error, navigating and reloading",
          );
          ad.dispose();
          // Reload rewarded ad for next time
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _loadRewardedAd();
            }
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailPage(routeName: routeName, title: title),
            ),
          );
        },
      );

      ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            "Dashboard user earned reward: ${reward.amount} ${reward.type}",
          );
        },
      );
    } else {
      debugPrint(
        "Dashboard navigating directly to DetailPage (no ad shown - dashboard frequency: $shouldShowAd, ad loaded: ${_rewardedAd != null})",
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(routeName: routeName, title: title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,

        title: Text(
          "All Old Books",
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
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFE3F2FD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(
                          title: book["title"]!,
                          image: book["image"]!,
                          onTap: () {
                            _showRewardedAdThenNavigate(
                              routeName: book["routeName"]!,
                              title: book["title"]!,
                            );
                          },
                        );
                      },
                    ),

                    // Always show the smart ad widget - it will handle loading, error, and success states
                    Container(
                      key: const ValueKey('dashboard_ad_container'),
                      margin: const EdgeInsets.all(16),
                      height: MediaQuery.of(context).size.width,
                      child: AdManager().createSmartAdWidget(
                        'dashboard',
                        position: 0,
                      ),
                    ),
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: books2.length,
                      itemBuilder: (context, index) {
                        final book = books2[index];
                        return BookCard(
                          title: book["title"]!,
                          image: book["image"]!,
                          onTap: () {
                            _showRewardedAdThenNavigate(
                              routeName: book["routeName"]!,
                              title: book["title"]!,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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

class BookCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
