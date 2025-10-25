import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/video/video_bloc.dart';
import '../blocs/video/video_event.dart';
import '../blocs/video/video_state.dart';
import '../services/agora_service.dart';
import '../utils/app_loader.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
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
    _videoBloc = VideoBloc(_service)
      ..add(InitVideo());

    _setupCallEndCallback();

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
    await Future.delayed(const Duration(milliseconds: 500));

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
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Switch camera error: $e')));
    }
  }

  Future<void> _toggleScreenShare() async {
    try {
      _videoBloc.add(ToggleScreenShare());
      if (!mounted) return;

      final message = _service.isScreenSharing
          ? 'Screen sharing started'
          : 'Screen sharing stopped';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screen share error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _endCall({bool isRemoteInitiated = false}) async {
    if (_isCallEnded) {
      Logger.i('End call already in progress, skipping...');
      return;
    }

    _isCallEnded = true;

    try {
      Logger.i('Ending call... (remote initiated: $isRemoteInitiated)');

      if (!isRemoteInitiated) {
        _videoBloc.add(LeaveChannel());
        await _service.leaveChannel();
      }

      await _service.dispose();

      Logger.i('Call ended successfully');
    } catch (e) {
      Logger.i('Error ending call: $e');
      debugPrint('Error ending call: $e');
    }

    if (!mounted) return;

    if (isRemoteInitiated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Call ended by other participant'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<bool> _showEndCallDialog() async {
    if (_isCallEnded) {
      return true;
    }

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: AppColors.backgroundDark,
            title: const Text(
              'End Call?',
              style: TextStyle(color: AppColors.textWhite),
            ),
            content: const Text(
              'Are you sure you want to end this call?',
              style: TextStyle(color: AppColors.textMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error),
                child: const Text(
                  'End Call',
                  style: TextStyle(color: AppColors.textWhite),
                ),
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
          if (didPop) {
            return;
          }
          await _showEndCallDialog();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              AppStrings.videoCallTitle,
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
              onPressed: () => _showEndCallDialog(),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              AppStrings.errorTitle,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _videoBloc.add(InitVideo()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(AppStrings.retryButton),
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
          top: 20,
          right: 20,
          width: 130,
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textWhite.withValues(alpha: 0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
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
                        size: 32,
                      ),
                    ),
                  ),
                  // Screen share indicator badge
                  if (state.isScreenSharing)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.screen_share,
                              size: 12,
                              color: Colors.black,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Sharing',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
              const SizedBox(height: 24),
              const Text(
                AppStrings.waitingMessage,
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Channel: $_currentChannel',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else
              ...[
                const Icon(
                  Icons.video_call,
                  size: 80,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.readyMessage,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  const SizedBox(width: 14),
                  _controlButton(
                    icon: videoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: videoEnabled ? AppColors.textWhite : AppColors.error,
                    onTap: isScreenSharing
                        ? null // Disable when screen sharing
                        : () {
                      setState(() => videoEnabled = !videoEnabled);
                      _service.toggleVideo(videoEnabled);
                      _videoBloc.add(ToggleVideoEvent(videoEnabled));
                    },
                  ),
                  const SizedBox(width: 14),
                  _controlButton(
                    icon: Icons.switch_camera,
                    color: AppColors.textWhite,
                    onTap: isScreenSharing ? null : _switchCamera,
                  ),
                  const SizedBox(width: 14),
                  // NEW: Screen Share Button
                  _controlButton(
                    icon: isScreenSharing
                        ? Icons.stop_screen_share
                        : Icons.screen_share,
                    color: isScreenSharing
                        ? AppColors.primary
                        : AppColors.textWhite,
                    onTap: _currentChannel != null ? _toggleScreenShare : null,
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => _showEndCallDialog(),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.error,
                      child: Icon(
                        Icons.call_end,
                        color: AppColors.textWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
        const Text(
          AppStrings.joinPrompt,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _channelController,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: AppStrings.channelHint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.textWhite.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            prefixIcon: const Icon(
              Icons.meeting_room,
              color: AppColors.textMuted,
            ),
          ),
          onFieldSubmitted: (_) => _joinChannel(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _joinChannel,
            child: const Text(
              AppStrings.joinButton,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.bothUsersHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildConnectedLabel(bool isScreenSharing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.connectedTo,
                style: TextStyle(color: AppColors.textMuted),
              ),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.screen_share,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Screen sharing active',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        opacity: isDisabled ? 0.4 : 1.0,
        child: CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.textWhite.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}