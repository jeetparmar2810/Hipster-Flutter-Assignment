import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hipster_inc_assignment/utils/app_colors.dart';
import '../utils/logger.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // Callbacks
  Function(IncomingCallData callData)? onIncomingCall;
  Function(String notificationId)? onNotificationTapped;

  bool _isInitialized = false;
  final List<IncomingCallData> _callHistory = [];

  /// Initialize the push notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.i('Push notifications already initialized');
      return;
    }

    try {
      Logger.i('Initializing push notification service (mocked)...');

      // Simulate FCM/APNs initialization
      await Future.delayed(const Duration(milliseconds: 500));

      _isInitialized = true;
      Logger.i('Push notification service initialized successfully');
    } catch (e) {
      Logger.e('Failed to initialize push notifications', e);
      rethrow;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    Logger.i('Requesting notification permissions (mocked)...');

    // Simulate permission request
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock: Always grant permission
    Logger.i('Notification permissions granted');
    return true;
  }

  /// Get FCM/APNs token (mocked)
  Future<String> getDeviceToken() async {
    Logger.i('Getting device token (mocked)...');

    await Future.delayed(const Duration(milliseconds: 200));

    // Generate a mock token
    final token = 'mock_token_${Random().nextInt(999999)}';
    Logger.i('Device token: $token');

    return token;
  }

  /// Simulate receiving an incoming call notification
  Future<void> simulateIncomingCall({
    required String callerName,
    required String callerId,
    required String channelName,
  }) async {
    if (!_isInitialized) {
      Logger.w('Push notification service not initialized');
      return;
    }

    final callData = IncomingCallData(
      notificationId: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerName: callerName,
      callerId: callerId,
      channelName: channelName,
      timestamp: DateTime.now(),
    );

    _callHistory.add(callData);

    Logger.i('Simulating incoming call from: $callerName');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Trigger callback
    onIncomingCall?.call(callData);
  }

  /// Show incoming call notification UI
  void showIncomingCallNotification(
      BuildContext context,
      IncomingCallData callData,
      ) {
    // Check if context is still valid
    if (!context.mounted) {
      Logger.w('Context not mounted, cannot show notification');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => IncomingCallDialog(
          callData: callData,
          onAccept: () {
            Logger.i('Call accepted: ${callData.channelName}');
            // Safely pop dialog
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            onNotificationTapped?.call(callData.notificationId);
          },
          onDecline: () {
            Logger.i('Call declined from: ${callData.callerName}');
            // Safely pop dialog
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
        ),
      );
    } catch (e) {
      Logger.e('Error showing notification dialog', e);
    }
  }

  /// Get call history
  List<IncomingCallData> getCallHistory() {
    return List.unmodifiable(_callHistory);
  }

  /// Clear call history
  void clearCallHistory() {
    _callHistory.clear();
    Logger.i('Call history cleared');
  }

  /// Dispose the service
  void dispose() {
    _isInitialized = false;
    _callHistory.clear();
    onIncomingCall = null;
    onNotificationTapped = null;
    Logger.i('Push notification service disposed');
  }
}

/// Data model for incoming call
class IncomingCallData {
  final String notificationId;
  final String callerName;
  final String callerId;
  final String channelName;
  final DateTime timestamp;

  IncomingCallData({
    required this.notificationId,
    required this.callerName,
    required this.callerId,
    required this.channelName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'callerName': callerName,
      'callerId': callerId,
      'channelName': channelName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory IncomingCallData.fromJson(Map<String, dynamic> json) {
    return IncomingCallData(
      notificationId: json['notificationId'] as String,
      callerName: json['callerName'] as String,
      callerId: json['callerId'] as String,
      channelName: json['channelName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Incoming call dialog widget
class IncomingCallDialog extends StatelessWidget {
  final IncomingCallData callData;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallDialog({
    super.key,
    required this.callData,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.video_call,
              size: 64,
              color: AppColors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Incoming Video Call',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              callData.callerName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Channel: ${callData.channelName}',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button
                GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),
                // Accept button
                GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}