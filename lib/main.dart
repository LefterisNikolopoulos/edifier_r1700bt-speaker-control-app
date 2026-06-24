import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:home_widget/home_widget.dart';

String? _extractWidgetAction(Uri uri) {
  final host = uri.host.trim();
  if (host.isNotEmpty && host != 'action') {
    return host;
  }

  if (uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }

  final queryAction = uri.queryParameters['action'];
  if (queryAction != null && queryAction.isNotEmpty) {
    return queryAction;
  }

  return null;
}

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (uri == null) return;

  const String homeAssistantUrl = 'http://YOUR_HOME_ASSISTANT_IP:8123';
  const String accessToken = 'YOUR_LONG_LIVED_ACCESS_TOKEN';

  final action = _extractWidgetAction(uri);

  String? entityId;
  if (action == 'power') {
    entityId = 'button.esp32_ir_remote_control_edifier_power';
  } else if (action == 'vol_down') {
    entityId = 'button.esp32_ir_remote_control_edifier_volume_down';
  } else if (action == 'mute') {
    entityId = 'button.esp32_ir_remote_control_edifier_mute';
  } else if (action == 'vol_up') {
    entityId = 'button.esp32_ir_remote_control_edifier_volume_up';
  }

  if (entityId != null) {
    try {
      await http.post(
        Uri.parse('$homeAssistantUrl/api/services/button/press'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: '{"entity_id": "$entityId"}',
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      // Silent error handling in background
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.registerInteractivityCallback(backgroundCallback);
  runApp(const EdifierApp());
}

class EdifierApp extends StatelessWidget {
  const EdifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edifier Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),
          surface: Color(0xFF121212),
          background: Color(0xFF121212),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const RemoteScreen(),
    );
  }
}

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({super.key});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> with TickerProviderStateMixin {
  final String homeAssistantUrl = 'http://YOUR_HOME_ASSISTANT_IP:8123';
  final String accessToken = 'YOUR_LONG_LIVED_ACCESS_TOKEN';
  
  late AnimationController _feedbackController;
  Timer? _volumeTimer;
  
  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _volumeTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendCommand(String entityId, String action) async {
    HapticFeedback.lightImpact();
    _feedbackController.forward().then((_) => _feedbackController.reverse());
    
    try {
      await http.post(
        Uri.parse('$homeAssistantUrl/api/services/button/press'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: '{"entity_id": "$entityId"}',
      );
    } catch (e) {
      // Silent error handling
    }
  }

  void _startVolumeChange(String entityId, String action) {
    _sendCommand(entityId, action);
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _sendCommand(entityId, action);
    });
  }

  void _stopVolumeChange() {
    _volumeTimer?.cancel();
    _volumeTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edifier Remote',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.speaker_rounded,
                      size: 48,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Edifier Speakers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Power Button
              _RemoteButton(
                icon: Icons.power_settings_new_rounded,
                label: 'Power',
                onPressed: () => _sendCommand(
                  'button.esp32_ir_remote_control_edifier_power',
                  'Power toggled',
                ),
                controller: _feedbackController,
              ),
              
              const SizedBox(height: 16),
              
              // Volume Row
              Row(
                children: [
                  Expanded(
                    child: _VolumeButton(
                      icon: Icons.volume_down_rounded,
                      label: 'Volume -',
                      onStart: () => _startVolumeChange(
                        'button.esp32_ir_remote_control_edifier_volume_down',
                        'Volume decreased',
                      ),
                      onStop: _stopVolumeChange,
                      controller: _feedbackController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _VolumeButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Volume +',
                      onStart: () => _startVolumeChange(
                        'button.esp32_ir_remote_control_edifier_volume_up',
                        'Volume increased',
                      ),
                      onStop: _stopVolumeChange,
                      controller: _feedbackController,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Mute Button
              _RemoteButton(
                icon: Icons.volume_off_rounded,
                label: 'Mute',
                onPressed: () => _sendCommand(
                  'button.esp32_ir_remote_control_edifier_mute',
                  'Mute toggled',
                ),
                controller: _feedbackController,
              ),
              
              const SizedBox(height: 24),
              
              // Input Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Input Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Input Row
              Row(
                children: [
                  Expanded(
                    child: _RemoteButton(
                      icon: Icons.bluetooth_rounded,
                      label: 'Bluetooth',
                      onPressed: () => _sendCommand(
                        'button.esp32_ir_remote_control_edifier_bluetooth',
                        'Bluetooth selected',
                      ),
                      controller: _feedbackController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RemoteButton(
                      icon: Icons.cable_rounded,
                      label: 'AUX',
                      onPressed: () => _sendCommand(
                        'button.esp32_ir_remote_control_edifier_aux_line_in',
                        'AUX selected',
                      ),
                      controller: _feedbackController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final AnimationController controller;

  const _VolumeButton({
    required this.icon,
    required this.label,
    required this.onStart,
    required this.onStop,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (controller.value * 0.05),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTapDown: (_) => onStart(),
                onTapUp: (_) => onStop(),
                onTapCancel: onStop,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RemoteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final AnimationController controller;

  const _RemoteButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (controller.value * 0.05),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}