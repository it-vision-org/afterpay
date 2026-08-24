import 'package:flutter/material.dart';

/// Shown while the auth session is being restored, right after the native
/// launch screen hands off to Flutter. Crossfades from the first splash
/// image to the second, then stays on the second (same background as the
/// native launch screen) so the transition into the app is seamless.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _firstSplashDuration = Duration(milliseconds: 900);

  bool _showFirstSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(_firstSplashDuration, () {
      if (mounted) setState(() => _showFirstSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Image(
              key: ValueKey(_showFirstSplash),
              image: AssetImage(
                _showFirstSplash
                    ? 'assets/images/splash-screen0.png'
                    : 'assets/images/splash-screen.png',
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
