import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../app/theme.dart';
import '../../utils/external_apps.dart';

/// Star map. Opens the Stellarium Mobile app when it's installed; otherwise
/// shows Stellarium Web (the official free browser version, same sky
/// engine) right here.
///
/// Operator asks (2026-10-03): auto tracking on by default (the sky follows
/// where the phone points, like Stellarium Mobile's sensor mode, which
/// Stellarium Web doesn't have), and no prompts to download the app (the
/// "GET APP" button is gone; the site's cookie banner and any app prompt are
/// dismissed automatically). The page also gets the phone's real GPS
/// location instead of an IP-based guess.
class StellariumScreen extends StatefulWidget {
  const StellariumScreen({super.key});

  /// The menu calls this: hands off to the real app if present, else pushes
  /// the in-app web version.
  /// Takes the NavigatorState, not a BuildContext: the menu closes the
  /// drawer first, and the drawer's context is gone by the time the
  /// installed-app check returns.
  static Future<void> open(NavigatorState navigator) async {
    if (await ExternalApps.open(ExternalApps.stellarium)) return;
    await navigator.push(
        MaterialPageRoute(builder: (_) => const StellariumScreen()));
  }

  @override
  State<StellariumScreen> createState() => _StellariumScreenState();
}

/// Injected into Stellarium Web once it has loaded.
///
/// Tracking: `deviceorientationabsolute` gives the phone's attitude (W3C
/// alpha/beta/gamma, alpha from north; relative readings as a fallback). The back of the phone points along
/// minus the third column of R = Rz(alpha)·Rx(beta)·Ry(gamma), in an
/// east/north/up frame; Stellarium's `core.yaw` is that direction's compass
/// bearing (0 = north, 90° = east, checked on the engine) and `core.pitch`
/// its altitude. Smoothed so sensor noise doesn't make the sky shake.
const _injected = r'''
(() => {
  if (window.__rkTrack) return;
  const st = window.__rkTrack = { on: true, v: null, events: 0 };

  const tidy = () => {
    for (const b of document.querySelectorAll('button, .v-btn')) {
      if ((b.innerText || '').trim().toUpperCase() === 'I AGREE') b.click();
    }
    for (const el of document.querySelectorAll('.v-snackbar, .v-dialog, .v-overlay__content')) {
      if (/stellarium (mobile|plus)|get (the )?app|download the app|app store|google play/i
          .test(el.innerText || '')) el.remove();
    }
  };
  tidy();
  setInterval(tidy, 1500);

  const onOrientation = (e) => {
    if (e.alpha == null || e.beta == null || e.gamma == null) return;
    st.events++;
    const c = window._stel && window._stel.core;
    if (!st.on || !c) return;
    const d = Math.PI / 180, a = e.alpha * d, b = e.beta * d, g = e.gamma * d;
    const x = -(Math.cos(a) * Math.sin(g) + Math.sin(a) * Math.sin(b) * Math.cos(g));
    const y = -(Math.sin(a) * Math.sin(g) - Math.cos(a) * Math.sin(b) * Math.cos(g));
    const z = -(Math.cos(b) * Math.cos(g));
    const k = 0.25;
    st.v = st.v ? [st.v[0] + k * (x - st.v[0]), st.v[1] + k * (y - st.v[1]), st.v[2] + k * (z - st.v[2])]
                : [x, y, z];
    const [vx, vy, vz] = st.v;
    const n = Math.hypot(vx, vy, vz) || 1;
    c.yaw = Math.atan2(vx, vy);
    c.pitch = Math.asin(Math.max(-1, Math.min(1, vz / n)));
  };
  // Compass-referenced readings when the phone has a rotation-vector
  // sensor (most do). Without one (seen on the emulator) only relative
  // readings arrive: still use them after 1.5 s, so tilting and turning move
  // the sky, though north may then be offset.
  let absoluteSeen = false;
  const started = Date.now();
  window.addEventListener('deviceorientationabsolute', (e) => {
    absoluteSeen = true;
    onOrientation(e);
  });
  window.addEventListener('deviceorientation', (e) => {
    if (e.absolute) { absoluteSeen = true; onOrientation(e); return; }
    if (!absoluteSeen && Date.now() - started > 1500) onOrientation(e);
  });
})();
''';

class _StellariumScreenState extends State<StellariumScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _tracking = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) async {
          await _controller.runJavaScript(_injected);
          // Orientation events only reach a focused page.
          await ExternalApps.focusWebViews();
          await _controller.runJavaScript(
              'window.__rkTrack && (window.__rkTrack.on = $_tracking);');
          if (mounted) setState(() => _loading = false);
        },
      ));
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      // Let "Use Autolocation" use the phone's GPS (the app already holds
      // the location permission for the ISS pass alerts).
      platform.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (_) async =>
            const GeolocationPermissionsResponse(allow: true, retain: true),
      );
    }
    _controller.loadRequest(Uri.parse('https://stellarium-web.org/'));
  }

  Future<void> _toggleTracking() async {
    setState(() => _tracking = !_tracking);
    await _controller.runJavaScript(
        'window.__rkTrack && (window.__rkTrack.on = $_tracking);');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STAR MAP'),
        actions: [
          IconButton(
            onPressed: _toggleTracking,
            tooltip: _tracking
                ? 'Auto tracking on: the sky follows your phone. Tap to '
                    'move it by hand.'
                : 'Auto tracking off. Tap to follow your phone again.',
            icon: Icon(
              _tracking ? Icons.explore : Icons.explore_off_outlined,
              color: _tracking ? AppTheme.accent : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.accent)),
        ],
      ),
    );
  }
}
