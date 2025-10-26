import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/video/video_bloc.dart';
import '../blocs/video/video_event.dart';
import '../blocs/video/video_state.dart';
import '../services/agora_service.dart';
import '../services/push_notification_service.dart';
import '../utils/app_loader.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import '../utils/logger.dart';

class VideoCallScreen extends StatefulWidget {
  final String? channelName;

  const VideoCallScreen({super.key, this.channelName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late AgoraService _service;
  late VideoBloc _videoBloc;
  final PushNotificationService _notificationService = PushNotificationService();

  bool audioEnabled = true;
  bool videoEnabled = true;
  bool _loading = false;
  String? _currentChannel;
  bool _isCallEnded = false;

  final TextEditingController _channelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = AgoraService();
    _videoBloc = VideoBloc(_service)..add(InitVideo());

    _setupCallEndCallback();
    _setupNotifications();

    if (widget.channelName != null) {
      _currentChannel = widget.channelName;
      _channelController.text = widget.channelName!;
    }
  }

  void _setupCallEndCallback() {
    _service.onCallEnded = () {
      Logger.i(
        'Call ended callback triggered - remote user left or connection lost',
      );
      if (mounted && !_isCallEnded) {
        _isCallEnded = true;
        _endCall(isRemoteInitiated: true);
      }
    };
  }

  Future<void> _setupNotifications() async {
    try {
      await _notificationService.initialize();
      await _notificationService.requestPermissions();

      _notificationService.onIncomingCall = (callData) {
        if (mounted && _currentChannel == null) {
          _notificationService.showIncomingCallNotification(context, callData);
        } else if (mounted && _currentChannel != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incoming call from ${callData.callerName}'),
              duration: Duration(seconds: AppDimens.durationVideoCallMS),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  _notificationService.showIncomingCallNotification(context, callData);
                },
              ),
            ),
          );
        }
      };

      _notificationService.onNotificationTapped = (notificationId) {
        try {
          final callData = _notificationService.getCallHistory().lastWhere(
                (call) => call.notificationId == notificationId,
          );

          if (mounted) {
            setState(() {
              _currentChannel = callData.channelName;
              _channelController.text = callData.channelName;
            });
            _joinChannel();
          }
        } catch (e) {
          Logger.e('Error handling notification tap', e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to join call from notification'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      };

      Logger.i('Notifications setup complete');
    } catch (e) {
      Logger.e('Failed to setup notifications', e);
    }
  }

  @override
  void dispose() {
    if (!_isCallEnded) {
      _service.leaveChannel();
      _service.dispose();
    }
    _videoBloc.close();
    _channelController.dispose();
    super.dispose();
  }

  Future<void> _joinChannel() async {
    final channel = _channelController.text.trim();

    if (channel.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseEnterChannel),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _currentChannel = channel;
    });

    _videoBloc.add(JoinChannel(channel));
    await Future.delayed(
        const Duration(milliseconds: AppDimens.durationLongVideoCallMS));

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _switchCamera() async {
    try {
      await _service.switchCamera();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.cameraSwitched),
          duration: Duration(seconds: AppDimens.durationOneSecondVideoCall),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.cameraSwitched} error: $e')),
      );
    }
  }

  Future<void> _toggleScreenShare() async {
    try {
      _videoBloc.add(ToggleScreenShare());
      if (!mounted) return;

      final message = _service.isScreenSharing
          ? AppStrings.screenSharingStarted
          : AppStrings.screenSharingStopped;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: AppDimens.durationVideoCallMS),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.screenSharingStopped} error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    final testChannel = _channelController.text.trim().isEmpty
        ? 'test_channel_${DateTime.now().millisecondsSinceEpoch}'
        : _channelController.text.trim();

    await _notificationService.simulateIncomingCall(
      callerName: 'Test User',
      callerId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      channelName: testChannel,
    );

    Logger.i('Test notification sent for channel: $testChannel');
  }

  Future<void> _endCall({bool isRemoteInitiated = false}) async {
    if (_isCallEnded) return;

    _isCallEnded = true;

    try {
      if (!isRemoteInitiated) {
        _videoBloc.add(LeaveChannel());
        await _service.leaveChannel();
      }

      await _service.dispose();
    } catch (e) {
      Logger.i('Error ending call: $e');
    }

    if (!mounted) return;

    if (isRemoteInitiated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.callEndedByOther),
          duration: Duration(seconds: AppDimens.durationVideoCallMS),
          backgroundColor: AppColors.error,
        ),
      );
      await Future.delayed(
          Duration(milliseconds: AppDimens.durationLongVideoCallMS));
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool> _showEndCallDialog() async {
    if (_isCallEnded) return true;

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(AppStrings.endCallTitle, style: AppTextStyles.title),
        content: const Text(AppStrings.endCallContent, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancelButton, style: AppTextStyles.body),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.endCallButton, style: AppTextStyles.button),
          ),
        ],
      ),
    );

    if (shouldEnd == true && mounted && !_isCallEnded) {
      await _endCall(isRemoteInitiated: false);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _videoBloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          await _showEndCallDialog();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title:
            const Text(AppStrings.videoCallTitle, style: AppTextStyles.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
              onPressed: () => _showEndCallDialog(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notification_add, color: AppColors.textWhite),
                onPressed: _testNotification,
                tooltip: AppStrings.testNotification,
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<VideoBloc, VideoState>(
                      builder: (context, state) {
                        if (state is VideoLoading) {
                          return const Center(child: AppLoader());
                        }
                        if (state is VideoError) {
                          return _buildErrorState(state.message);
                        }
                        if (state is VideoReady) {
                          return _buildVideoLayout(state);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  _buildControls(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingVideoCallLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: AppDimens.iconXXLargeVideoCall, color: AppColors.error),
            const SizedBox(height: AppDimens.marginVideoCallMedium),
            const Text(AppStrings.errorTitle, style: AppTextStyles.title),
            const SizedBox(height: AppDimens.marginVideoCallSmall),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: AppDimens.marginVideoCallMedium),
            ElevatedButton(
              onPressed: () => _videoBloc.add(InitVideo()),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text(AppStrings.retryButton, style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayout(VideoReady state) {
    return Stack(
      children: [
        Positioned.fill(
          child: state.hasRemoteUser && state.remoteVideoWidget != null
              ? state.remoteVideoWidget!
              : _buildWaitingScreen(),
        ),
        Positioned(
          top: AppDimens.positionVideoCallTop,
          right: AppDimens.positionVideoCallRight,
          width: AppDimens.videoPreviewWidth,
          height: AppDimens.videoPreviewHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textWhite.withValues(alpha: AppDimens.alphaBorderVideoCall),
                  width: AppDimens.borderWidthVideoCall,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppDimens.alphaShadowVideoCall),
                    blurRadius: AppDimens.blurRadiusVideoCall,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  (videoEnabled || state.isScreenSharing)
                      ? state.localVideoWidget
                      : Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: AppColors.textMuted,
                        size: AppDimens.iconMediumVideoCall,
                      ),
                    ),
                  ),
                  if (state.isScreenSharing)
                    Positioned(
                      bottom: AppDimens.positionVideoCallBottom,
                      left: AppDimens.positionVideoCallLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingVideoCallSmall,
                          vertical: AppDimens.paddingVideoCallTiny,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppDimens.radiusTinyVideoCall),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.screen_share,
                                size: AppDimens.iconTinyVideoCall, color: Colors.black),
                            SizedBox(width: AppDimens.marginVideoCallTiny),
                            Text(AppStrings.sharing,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppDimens.textTinyVideoCall,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: AppColors.backgroundDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentChannel != null) ...[
              const AppLoader(),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              const Text(AppStrings.waitingMessage, style: AppTextStyles.body),
              const SizedBox(height: AppDimens.marginVideoCallSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingVideoCallLarge,
                  vertical: AppDimens.paddingVideoCallMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: AppDimens.alphaLowVideoCall),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLargeVideoCall),
                ),
                child: Text(
                  '${AppStrings.channelPrefix}$_currentChannel',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppDimens.textLargeVideoCall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              const Icon(Icons.video_call,
                  size: AppDimens.iconXXLargeVideoCall, color: AppColors.textMuted),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              const Text(AppStrings.readyMessage, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        final isScreenSharing = state is VideoReady && state.isScreenSharing;

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingVideoCallLarge,
              vertical: AppDimens.paddingVideoCallMedium),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: AppDimens.alphaControlBackgroundVideoCall),
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusTopVideoCall)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(
                    icon: audioEnabled ? Icons.mic : Icons.mic_off,
                    color: audioEnabled ? AppColors.textWhite : AppColors.error,
                    onTap: () {
                      setState(() => audioEnabled = !audioEnabled);
                      _service.toggleAudio(audioEnabled);
                      _videoBloc.add(ToggleAudioEvent(audioEnabled));
                    },
                  ),
                  const SizedBox(width: AppDimens.marginVideoCallMedium),
                  _controlButton(
                    icon: videoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: videoEnabled ? AppColors.textWhite : AppColors.error,
                    onTap: isScreenSharing
                        ? null
                        : () {
                      setState(() => videoEnabled = !videoEnabled);
                      _service.toggleVideo(videoEnabled);
                      _videoBloc.add(ToggleVideoEvent(videoEnabled));
                    },
                  ),
                  const SizedBox(width: AppDimens.marginVideoCallMedium),
                  _controlButton(
                    icon: Icons.switch_camera,
                    color: AppColors.textWhite,
                    onTap: isScreenSharing ? null : _switchCamera,
                  ),
                  const SizedBox(width: AppDimens.marginVideoCallMedium),
                  _controlButton(
                    icon: isScreenSharing
                        ? Icons.stop_screen_share
                        : Icons.screen_share,
                    color: isScreenSharing ? AppColors.primary : AppColors.textWhite,
                    onTap: _currentChannel != null ? _toggleScreenShare : null,
                  ),
                  const SizedBox(width: AppDimens.marginVideoCallMedium),
                  GestureDetector(
                    onTap: () => _showEndCallDialog(),
                    child: const CircleAvatar(
                      radius: AppDimens.avatarRadiusSmallVideoCall,
                      backgroundColor: AppColors.error,
                      child: Icon(Icons.call_end,
                          color: AppColors.textWhite,
                          size: AppDimens.iconSizeVideoCall),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              if (_loading) const AppLoader(),
              if (!_loading && _currentChannel == null) _buildChannelInput(),
              if (_currentChannel != null && !_loading)
                _buildConnectedLabel(isScreenSharing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelInput() {
    return Column(
      children: [
        const Text(AppStrings.joinPrompt, style: AppTextStyles.body),
        const SizedBox(height: AppDimens.marginVideoCallSmall),
        TextFormField(
          controller: _channelController,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: AppStrings.channelHint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor:
            AppColors.textWhite.withValues(alpha: AppDimens.alphaLowVideoCall),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppDimens.radiusMediumVideoCall),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            prefixIcon:
            const Icon(Icons.meeting_room, color: AppColors.textMuted),
          ),
          onFieldSubmitted: (_) => _joinChannel(),
        ),
        const SizedBox(height: AppDimens.marginVideoCallSmall),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingVideoCallMedium),
            ),
            onPressed: _joinChannel,
            child: const Text(AppStrings.joinButton, style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: AppDimens.marginVideoCallTiny),
        const Text(
          AppStrings.bothUsersHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  Widget _buildConnectedLabel(bool isScreenSharing) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingVideoCallMedium),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: AppDimens.alphaLowVideoCall),
        borderRadius: BorderRadius.circular(AppDimens.radiusMediumVideoCall),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimens.statusDotSizeVideoCall,
                height: AppDimens.statusDotSizeVideoCall,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.marginVideoCallSmall),
              const Text(AppStrings.connectedTo, style: AppTextStyles.body),
              Flexible(
                child: Text(
                  _currentChannel!,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (isScreenSharing) ...[
            const SizedBox(height: AppDimens.marginVideoCallSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.screen_share,
                    size: AppDimens.iconSmallVideoCall, color: AppColors.primary),
                SizedBox(width: AppDimens.marginVideoCallTiny),
                Text(AppStrings.screenSharingActive,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: AppDimens.textSmallVideoCall,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? AppDimens.opacityDisabledVideoCall : AppDimens.opacityEnabledVideoCall,
        child: CircleAvatar(
          radius: AppDimens.avatarRadiusSmallVideoCall,
          backgroundColor:
          AppColors.textWhite.withValues(alpha: AppDimens.alphaBackgroundVideoCall),
          child: Icon(icon, color: color, size: AppDimens.iconSizeVideoCall),
        ),
      ),
    );
  }
}