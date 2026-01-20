// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:old_book/Addfile/ad_helper.dart';
import 'package:old_book/Addfile/ad_manager.dart';
import 'package:old_book/utils/ad_frequency_manager.dart';
import 'package:shimmer/shimmer.dart';

class DetailPage extends StatefulWidget {
  final String routeName;
  final String title;

  const DetailPage({super.key, required this.routeName, required this.title});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> booksdetail = [];
  bool _isLoading = true;
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

  /// Mapping of route name -> Firestore collection
  final Map<String, String> _collectionMap = {
    "beejganit": "algebra",
    "trigonometry": "trignometry_old_book",
    "calculus": "calculus",
    "geometry": "co_ordinate_geometry",
    "dynamics": "dynamics",
    "statics": "statics",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint("DetailPage initState called for ${widget.routeName}");
    _loadSingleAd();
    _loadBooks();
    _loadRewardedAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("DetailPage didChangeDependencies called");
    if (!_requestedAdaptive) {
      _requestedAdaptive = true;
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _loadTopBanner();
      _loadBottomBanner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint("DetailPage dispose called for ${widget.routeName}");
    AdManager().disposeAllAdsForScreen('detail');
    _rewardedAd?.dispose();
    _topBanner?.dispose();
    _bottomBanner?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _topBannerRetryCount = 0;
      _bottomBannerRetryCount = 0;
      _loadTopBanner();
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
              debugPrint('DetailPage top banner failed to load: $error');
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
        debugPrint('Error loading detail page top banner: $e');
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
              debugPrint('DetailPage bottom banner failed to load: $error');
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
        debugPrint('Error loading detail page bottom banner: $e');
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

  void _loadRewardedAd() {
    // Don't reload if already loading or loaded
    if (_rewardedAd != null) {
      debugPrint("DetailPage rewarded ad already loaded, skipping reload");
      return;
    }

    debugPrint("DetailPage loading rewarded ad");
    _rewardedAd?.dispose();
    _rewardedAd = null;

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("DetailPage rewarded ad loaded successfully");
          if (!mounted) {
            ad.dispose();
            return;
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("DetailPage rewarded ad dismissed, reloading");
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
                "DetailPage rewarded ad failed to show: $error, reloading",
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
        onAdFailedToLoad: (error) {
          debugPrint("DetailPage rewarded ad failed to load: $error");
          _rewardedAd = null;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _rewardedAd == null) {
              debugPrint("DetailPage retrying rewarded ad load");
              _loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  void _showRewardedAdThenNavigate(String pdfUrl, String chapter) async {
    // Check if we should show an ad based on frequency
    // Detail page has its own frequency check to prevent too many ads
    final shouldShowAd = await AdFrequencyManager.shouldShowAd();

    if (shouldShowAd && _rewardedAd != null) {
      debugPrint("DetailPage showing rewarded ad (frequency check passed)");
      final ad = _rewardedAd!;
      _rewardedAd = null; // Clear immediately to prevent showing same ad twice

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint(
            "DetailPage rewarded ad dismissed, navigating to OpenPdf and reloading",
          );
          ad.dispose();
          // Reload rewarded ad for next time
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _loadRewardedAd();
            }
          });
          _navigateToPdf(pdfUrl, chapter);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint(
            "DetailPage rewarded ad failed to show: $error, navigating to OpenPdf and reloading",
          );
          ad.dispose();
          // Reload rewarded ad for next time
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _loadRewardedAd();
            }
          });
          _navigateToPdf(pdfUrl, chapter);
        },
      );
      ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            "DetailPage user earned reward: ${reward.amount} ${reward.type}",
          );
        },
      );
    } else {
      debugPrint(
        "DetailPage navigating directly to OpenPdf (no ad shown - frequency: $shouldShowAd, ad loaded: ${_rewardedAd != null})",
      );
      _navigateToPdf(pdfUrl, chapter);
    }
  }

  void _navigateToPdf(String pdfUrl, String chapter) {
    Get.toNamed('/open_pdf', arguments: {"pdf": pdfUrl, "chapter": chapter});
  }

  Future<void> _loadBooks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final collectionName = _collectionMap[widget.routeName];
      if (collectionName == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();

      if (mounted) {
        setState(() {
          booksdetail = snapshot.docs.map((doc) => doc.data()).toList();
          _isLoading = false;
        });

        // Sort books after setting state
        if (booksdetail.isNotEmpty) {
          booksdetail.sort(
            (a, b) => int.parse(
              a['id'].toString(),
            ).compareTo(int.parse(b['id'].toString())),
          );
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Error loading books: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          debugPrint("DetailPage PopScope triggered");
          AdManager().disposeAllAdsForScreen('detail');
          // Don't dispose dashboard ads - let them persist
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              debugPrint("DetailPage back button pressed");
              AdManager().disposeAllAdsForScreen('detail');
              // Don't dispose dashboard ads - let them persist
              Get.back(result: true);
            },
          ),
        ),
        backgroundColor: Colors.white,
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
            Expanded(child: _buildBody()),
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
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading books..."),
          ],
        ),
      );
    }

    if (booksdetail.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No books found", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // Calculate the middle position for the ad
    final middleIndex = booksdetail.length ~/ 2;

    return ListView.builder(
      itemCount: booksdetail.length + 1, // +1 for the ad
      itemBuilder: (context, index) {
        // Show ad in the middle
        if (index == middleIndex) {
          return _buildAdWidget();
        }

        // Adjust book index to account for the ad
        final bookIndex = index > middleIndex ? index - 1 : index;
        return _buildBookCard(bookIndex);
      },
    );
  }

  Widget _buildBookCard(int index) {
    final book = booksdetail[index];
    final pdfUrl = book['link'] ?? book['link'] ?? '';
    final chapter = book['chapter'] ?? book['chapter'] ?? "";

    return GestureDetector(
      onTap: () {
        if (pdfUrl.isNotEmpty) {
          _showRewardedAdThenNavigate(pdfUrl, chapter);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF URL not available')),
          );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${book['id']}.  ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      book['chapter'] ?? 'No chapter title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (book['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  book['description'],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      height: MediaQuery.of(context).size.width * 0.8,
      child: AdManager().createSmartAdWidget('detail', position: 0),
    );
  }

  void _loadSingleAd() {
    debugPrint("DetailPage loading single ad for detail screen");

    // Clear any existing errors first
    AdManager().clearErrorsForScreen('detail');

    // Load only 1 ad at position 0
    _loadAdWithRetry('detail', 0);
  }

  void _loadAdWithRetry(String screenId, int position, {int retryCount = 0}) {
    const maxRetries = 2;

    AdManager().createNativeAd(
      screenId,
      position: position,
      onAdLoaded: () {
        debugPrint("DetailPage ad loaded successfully at position $position");
        if (mounted) {
          setState(() {});
        }
      },
    );

    // If ad fails to load, retry after a delay
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted &&
          !AdManager().isAdValid(screenId, position: position) &&
          retryCount < maxRetries) {
        debugPrint(
          "Retrying ad load for $screenId at position $position (attempt ${retryCount + 1})",
        );
        _loadAdWithRetry(screenId, position, retryCount: retryCount + 1);
      }
    });
  }
}
