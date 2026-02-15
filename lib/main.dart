import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colors.dart';
import 'dart:async';
import 'l10n/app_localizations.dart';
import 'services/ip_service.dart';
import 'services/vpn_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vulcain VPN',
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MyColors.myOrange),
        useMaterial3: false,
      ),
      home: const VpnHomePage(),
    );
  }
}

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});

  @override
  State<VpnHomePage> createState() => _VpnHomePageState();
}

class _VpnHomePageState extends State<VpnHomePage> {
  String _connectionState = 'disconnected';
  int _connectionSeconds = 0;
  Timer? _timer;
  Timer? _ipCheckTimer;
  String _currentIp = '';
  bool _isLoadingIp = true;
  StreamSubscription<bool>? _vpnSubscription;

  @override
  void initState() {
    super.initState();
    _fetchCurrentIp();

    _vpnSubscription = VpnService.statusStream.listen((isConnected) {
      if (!mounted) return;

      setState(() {
        if (isConnected) {
          _connectionState = 'connected';
          _connectionSeconds = 0;

          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _connectionSeconds++;
            });
          });
        } else {
          _connectionState = 'disconnected';
          _connectionSeconds = 0;
          _timer?.cancel();
        }
      });

      _fetchCurrentIp();
    });
  }

  Future<void> _fetchCurrentIp() async {
    setState(() {
      _isLoadingIp = true;
    });

    final ip = await IpService.getPublicIp();

    setState(() {
      _currentIp = ip;
      _isLoadingIp = false;
    });

    if (_currentIp == 'Unknown') {
      _ipCheckTimer?.cancel();
      _ipCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        final newIp = await IpService.getPublicIp();
        if (newIp != 'Unknown') {
          setState(() {
            _currentIp = newIp;
          });
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ipCheckTimer?.cancel();
    _vpnSubscription?.cancel();
    super.dispose();
  }

  void _toggleConnection() async {
    if (_connectionState == 'disconnected') {
      setState(() {
        _connectionState = 'connecting';
      });

      try {
        final success = await VpnService.startVpn();

        if (success) {
          setState(() {
            _connectionState = 'connected';
            _connectionSeconds = 0;
          });

          _fetchCurrentIp();

          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _connectionSeconds++;
            });
          });
        } else {
          setState(() {
            _connectionState = 'disconnected';
          });

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Connection Failed'),
                content: const Text('Failed to start VPN. Please check permissions.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _connectionState = 'disconnected';
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Connection Error'),
              content: Text('Failed to start VPN: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      await VpnService.stopVpn();

      _timer?.cancel();
      setState(() {
        _connectionState = 'disconnected';
        _connectionSeconds = 0;
      });

      _fetchCurrentIp();
    }
  }

  Future<void> _showEnableNotificationsDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications Required"),
        content: const Text("Please enable notifications in settings to use the VPN."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              const String url = 'android.settings.APP_NOTIFICATION_SETTINGS';
              try {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open settings: $e')),
                );
              }
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showLanguageDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(loc.english),
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                onTap: () {
                  MyApp.setLocale(context, const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(loc.french),
                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                onTap: () {
                  MyApp.setLocale(context, const Locale('fr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.myOrange,
        title: Text(loc.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showLanguageDialog,
            tooltip: loc.settings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _connectionState == 'connected'
                  ? Icons.shield
                  : Icons.shield_outlined,
              size: 140,
              color: _connectionState == 'connected'
                  ? Colors.green
                  : _connectionState == 'connecting'
                      ? MyColors.myOrange
                      : Colors.grey,
            ),
            const SizedBox(height: 40),

            Text(
              _connectionState == 'connected'
                  ? loc.connected
                  : _connectionState == 'connecting'
                      ? loc.connecting
                      : loc.disconnected,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${loc.location}: ${loc.france} 🇫🇷 ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                if (_isLoadingIp)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '($_currentIp)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            if (_connectionState == 'connected')
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '${loc.duration}: ${_formatTime(_connectionSeconds)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),

            if (_connectionState == 'connected')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  loc.secureConnection,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ),

            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: _connectionState == 'connecting'
                  ? null
                  : _toggleConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: _connectionState == 'connected'
                    ? Colors.red
                    : MyColors.myOrange,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: Text(
                _connectionState == 'connected'
                    ? loc.disconnect
                    : _connectionState == 'connecting'
                        ? loc.connectingBtn
                        : loc.connect,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
