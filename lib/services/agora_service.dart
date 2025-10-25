import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = '6830ee2b7b324d3f80a4823ee3eab00e';

  RtcEngine? _engine;
  int? remoteUid;
  bool isJoined = false;
  String? currentChannel;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserLeft;
  Function()? onLocalUserJoined;
  Function(String error)? onError;

  // ───────────────────────────────────────────────
  // INITIALIZATION
  // ───────────────────────────────────────────────

  Future<void> initialize() async {
    debugPrint('🔧 Initializing Agora...');

    try {
      // Request permissions safely before creating engine
      final statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted ||
          statuses[Permission.camera] != PermissionStatus.granted) {
        throw Exception('Microphone or camera permission denied');
      }

      _engine = createAgoraRtcEngine();

      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      debugPrint('✅ Agora engine created');

      // Register event handlers
      _registerEventHandlers();

      await _engine!.enableVideo();
      await _engine!.startPreview();

      debugPrint('✅ Video enabled and preview started');
    } catch (e) {
      debugPrint('❌ Failed to initialize Agora: $e');
      onError?.call('Initialization failed: $e');
      rethrow;
    }
  }

  // ───────────────────────────────────────────────
  // EVENT HANDLERS
  // ───────────────────────────────────────────────

  void _registerEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('✅ Local user ${connection.localUid} joined channel');
          isJoined = true;
          onLocalUserJoined?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('👤 Remote user $remoteUid joined');
          this.remoteUid = remoteUid;
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('🚪 Remote user $remoteUid left (reason: $reason)');
          if (this.remoteUid == remoteUid) this.remoteUid = null;
          onUserLeft?.call(remoteUid);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('📤 Left channel');
          isJoined = false;
          remoteUid = null;
          currentChannel = null;
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('❌ Agora Error: $err - $msg');
          onError?.call('Error $err: $msg');
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('🔗 Connection changed: $state (reason: $reason)');
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  // CORE METHODS
  // ───────────────────────────────────────────────

  Future<void> joinChannel(String channelName) async {
    if (_engine == null) {
      throw Exception('Engine not initialized. Call initialize() first');
    }

    try {
      debugPrint('🚪 Joining channel: $channelName');
      currentChannel = channelName;

      await _engine!.joinChannel(
        token: '', // Empty for testing
        channelId: channelName,
        uid: 0, // Auto-assign
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      debugPrint('✅ Join channel request sent');
    } catch (e) {
      debugPrint('❌ Failed to join channel: $e');
      onError?.call('Join channel failed: $e');
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    debugPrint('📤 Leaving channel...');
    try {
      await _engine?.leaveChannel();
    } catch (e) {
      debugPrint('⚠️ Error while leaving channel: $e');
    }
    isJoined = false;
    remoteUid = null;
    currentChannel = null;
  }

  Future<void> toggleAudio(bool enabled) async {
    await _engine?.muteLocalAudioStream(!enabled);
    debugPrint('🎤 Audio ${enabled ? "enabled" : "muted"}');
  }

  Future<void> toggleVideo(bool enabled) async {
    await _engine?.muteLocalVideoStream(!enabled);
    debugPrint('📹 Video ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    debugPrint('🔄 Camera switched');
  }

  // ───────────────────────────────────────────────
  // VIDEO WIDGETS
  // ───────────────────────────────────────────────

  Widget getLocalVideoWidget() {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget getRemoteVideoWidget() {
    if (_engine == null || remoteUid == null || currentChannel == null) {
      return const Center(
        child: Text(
          'Waiting for remote user...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: currentChannel!),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // CLEANUP
  // ───────────────────────────────────────────────

  Future<void> dispose() async {
    debugPrint('🧹 Disposing Agora service...');
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      debugPrint('⚠️ Error during dispose: $e');
    }

    _engine = null;
    isJoined = false;
    remoteUid = null;
    currentChannel = null;
  }
}