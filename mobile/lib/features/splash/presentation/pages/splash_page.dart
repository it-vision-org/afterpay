import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Shown while the auth session is being restored, right after the native
/// launch screen hands off to Flutter.
///
/// Two phases:
///  1. Entrance — the icon scales/fades into the center, then the icon and
///     wordmark slide left together as the wordmark blurs into place.
///  2. Loading — since restoring a session is a single network round trip
///     (no byte-level progress to report, and the backend can take a while
///     to wake up from a cold start on the free hosting tier) a simulated
///     progress bar eases toward ~92% so the user always sees *some*
///     forward motion, with the status label upgrading if the wait drags on.
///     It's topped off to 100% the moment the real session-restore call
///     actually resolves, whatever [authControllerProvider]'s state is.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  // Matches the reference animation: icon pops/settles over 1.2s, with the
  // wordmark starting its own 0.6s reveal at the 0.6s mark (so both finish
  // together).
  static const _introDuration = Duration(milliseconds: 1200);
  static const _iconSettleEnd = 0.45; // fraction of _introDuration
  static const _wordRevealStart = 0.5; // 0.6s / 1.2s

  static const _iconWidth = 84.0;
  static const _wordWidth = 210.0;
  static const _lockupGap = 14.0;
  static const _iconShift = (_lockupGap + _wordWidth) / 2;

  // Simulated progress: eases toward _progressCap and never claims to be
  // done until the real request actually finishes.
  static const _progressCap = 0.92;
  static const _progressTimeConstant = 4.5; // seconds

  late final AnimationController _introController;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconTranslateX;
  late final Animation<double> _wordOpacity;
  late final Animation<double> _wordBlur;
  late final Animation<double> _wordTranslateX;
  late final Animation<double> _loaderOpacity;

  late final Ticker _progressTicker;
  final Stopwatch _stopwatch = Stopwatch();
  double _progress = 0;
  String _statusLabel = 'Getting things ready…';
  bool _completing = false;
  AnimationController? _completionController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: _introDuration,
    )..forward();

    final iconSettleCurve = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, _iconSettleEnd, curve: Curves.easeOut),
    );
    _iconOpacity = iconSettleCurve;
    _iconScale = Tween<double>(
      begin: 1.4,
      end: 1.0,
    ).animate(iconSettleCurve);
    _iconTranslateX = Tween<double>(begin: _iconShift, end: 0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(_iconSettleEnd, 1.0, curve: Curves.easeOut),
      ),
    );

    final wordRevealCurve = CurvedAnimation(
      parent: _introController,
      curve: const Interval(_wordRevealStart, 1.0, curve: Curves.easeOut),
    );
    _wordOpacity = wordRevealCurve;
    _wordBlur = Tween<double>(begin: 6.0, end: 0.0).animate(wordRevealCurve);
    _wordTranslateX = Tween<double>(
      begin: 24.0,
      end: 0.0,
    ).animate(wordRevealCurve);

    _loaderOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _stopwatch.start();
    _progressTicker = createTicker(_onProgressTick)..start();
  }

  void _onProgressTick(Duration _) {
    if (_completing) return;
    final elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000;
    setState(() {
      _progress =
          _progressCap *
          (1 - math.exp(-elapsedSeconds / _progressTimeConstant));
      _statusLabel = _labelFor(elapsedSeconds);
    });
  }

  String _labelFor(double elapsedSeconds) {
    if (elapsedSeconds < 2.5) return 'Getting things ready…';
    if (elapsedSeconds < 8) return 'Connecting to your account…';
    return 'Still working — the server is waking up…';
  }

  void _completeProgress() {
    if (_completing) return;
    _completing = true;
    _stopwatch.stop();
    _progressTicker.stop();

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _completionController = controller;
    final animation = Tween<double>(begin: _progress, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    animation.addListener(() {
      if (mounted) setState(() => _progress = animation.value);
    });
    if (mounted) setState(() => _statusLabel = 'Ready');
    controller.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _progressTicker.dispose();
    _completionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    if (!authState.isLoading) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _completeProgress();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _introController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(_iconTranslateX.value, 0),
                        child: Transform.scale(
                          scale: _iconScale.value,
                          child: Opacity(
                            opacity: _iconOpacity.value,
                            child: Image.asset(
                              'assets/icons/app_icon.png',
                              width: _iconWidth,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _lockupGap),
                      Transform.translate(
                        offset: Offset(_wordTranslateX.value, 0),
                        child: Opacity(
                          opacity: _wordOpacity.value,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _wordBlur.value,
                              sigmaY: _wordBlur.value,
                            ),
                            child: Image.asset(
                              'assets/images/splash-screen-text.png',
                              width: _wordWidth,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _loaderOpacity,
                child: _ProgressLoader(
                  progress: _progress,
                  statusLabel: _statusLabel,
                  width: _iconWidth + _lockupGap + _wordWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A slim gradient progress bar with a soft glow at its leading edge and a
/// status label underneath, styled to match the app's fintech palette.
class _ProgressLoader extends StatelessWidget {
  const _ProgressLoader({
    required this.progress,
    required this.statusLabel,
    required this.width,
  });

  final double progress;
  final String statusLabel;
  final double width;

  static const _trackHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            child: Container(
              height: _trackHeight,
              color: AppColors.border,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clamped,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              statusLabel,
              key: ValueKey(statusLabel),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
