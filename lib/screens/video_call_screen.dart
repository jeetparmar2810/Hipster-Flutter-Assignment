import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_inc_assignment/utils/network/network_utils.dart';
import 'package:hipster_inc_assignment/widgets/video_screen_widget/export.dart';

import '../blocs/video/video_bloc.dart';
import '../blocs/video/video_event.dart';
import '../blocs/video/video_state.dart';
import '../routes/app_routes.dart';
import '../services/agora_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_loader.dart';
import '../utils/app_strings.dart';
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

  void _showNetworkError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.noInternet),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: AppDimens.duration5MS),
      ),
    );
  }

  Future<bool> _checkNetwork() async {
    final hasInternet = await NetworkUtils.hasInternet();
    if (!hasInternet && mounted) {
      _showNetworkError();
      return false;
    }
    return true;
  }

  Future<void> _joinChannel() async {
    if (!await _checkNetwork()) {
      return;
    }

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
    if (!await _checkNetwork()) {
      return;
    }

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
    AppRoutes.navigateToLogin(context);
  }

  Future<bool> _showEndCallDialog() async {
    if (_isCallEnded) return true;

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(AppStrings.endCallTitle, style: AppTextStyles.title),
        content:
        const Text(AppStrings.endCallContent, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
            const Text(AppStrings.cancelButton, style: AppTextStyles.body),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.endCallButton,
                style: AppTextStyles.button),
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
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: const Text(AppStrings.videoCallTitle, style: AppTextStyles.title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
        onPressed: () => _showEndCallDialog(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
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
                    return VideoErrorWidget(
                      message: state.message,
                      onRetry: () => _videoBloc.add(InitVideo()),
                    );
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
    );
  }

  Widget _buildVideoLayout(VideoReady state) {
    return Stack(
      children: [
        Positioned.fill(
          child: state.hasRemoteUser && state.remoteVideoWidget != null
              ? state.remoteVideoWidget!
              : VideoWaitingScreen(currentChannel: _currentChannel),
        ),
        VideoPreviewWidget(
          localVideoWidget: state.localVideoWidget,
          videoEnabled: videoEnabled,
          isScreenSharing: state.isScreenSharing,
        ),
      ],
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
            color: Colors.black
                .withValues(alpha: AppDimens.alphaControlBackgroundVideoCall),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusTopVideoCall)),
          ),
          child: Column(
            children: [
              _buildControlButtons(isScreenSharing),
              const SizedBox(height: AppDimens.marginVideoCallMedium),
              if (_loading) const AppLoader(),
              if (!_loading && _currentChannel == null)
                ChannelInputWidget(
                  controller: _channelController,
                  onJoinChannel: _joinChannel,
                ),
              if (_currentChannel != null && !_loading)
                ConnectedLabelWidget(
                  channelName: _currentChannel!,
                  isScreenSharing: isScreenSharing,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(bool isScreenSharing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VideoControlButton(
          icon: audioEnabled ? Icons.mic : Icons.mic_off,
          color: audioEnabled ? AppColors.textWhite : AppColors.error,
          onTap: () {
            setState(() => audioEnabled = !audioEnabled);
            _service.toggleAudio(audioEnabled);
            _videoBloc.add(ToggleAudioEvent(audioEnabled));
          },
        ),
        const SizedBox(width: AppDimens.marginVideoCallMedium),
        VideoControlButton(
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
        VideoControlButton(
          icon: Icons.switch_camera,
          color: AppColors.textWhite,
          onTap: isScreenSharing ? null : _switchCamera,
        ),
        const SizedBox(width: AppDimens.marginVideoCallMedium),
        VideoControlButton(
          icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
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
                color: AppColors.textWhite, size: AppDimens.iconSizeVideoCall),
          ),
        ),
      ],
    );
  }
}