import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_providers.dart';
import 'presentation/providers/sync_providers.dart';
import 'presentation/providers/theme_providers.dart';
import 'presentation/screens/auth/pin_lock_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/shell/synprod_shell.dart';
import 'presentation/widgets/synprod_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SynProdLiteApp(),
    ),
  );
}

class SynProdLiteApp extends ConsumerWidget {
  const SynProdLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) =>
            ref.read(authControllerProvider.notifier).recordActivity(),
        child: MaterialApp(
          title: 'SynProd Lite',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate>
    with WidgetsBindingObserver {
  bool _warningDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authStatus = ref.read(authControllerProvider).status;
    if (authStatus != AuthStatus.unlocked) return;

    if (state == AppLifecycleState.resumed) {
      ref.read(syncControllerProvider.notifier).start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(syncControllerProvider.notifier).stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.unlocked &&
          next.sessionExpiringSoon &&
          !(previous?.sessionExpiringSoon ?? false) &&
          !_warningDialogOpen) {
        _showSessionWarningDialog(next.remainingBeforeLock);
      }
    });

    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: SynProdCanvas(
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      case AuthStatus.needsOnboarding:
        return const OnboardingScreen();
      case AuthStatus.locked:
      case AuthStatus.revoked:
        return const PinLockScreen();
      case AuthStatus.unlocked:
        return const SynProdShell();
    }
  }

  Future<void> _showSessionWarningDialog(Duration? remaining) async {
    _warningDialogOpen = true;
    final mins = remaining?.inMinutes ?? 15;

    await showSynProdDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SynProdDialog(
        icon: Icons.timer_outlined,
        title: 'Session Expiring Soon',
        content: Text(
          'Your session will auto-lock in $mins minute${mins == 1 ? '' : 's'} due to inactivity.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).lockNow();
            },
            child: const Text('Log Out'),
          ),
          SynProdGradientButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).extendSession();
            },
            child: const Text('Stay Unlocked'),
          ),
        ],
      ),
    );

    _warningDialogOpen = false;
  }
}
